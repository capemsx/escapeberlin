import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/types/gamephase.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/backend/types/roundobjective.dart';
import 'package:escapeberlin/frontend/pages/game/gameresult.dart';
import 'package:escapeberlin/frontend/pages/lobby.dart';
import 'package:escapeberlin/frontend/widgets/chat/inventory_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/player_list_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/round_objective_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/shared_documents_view.dart';
import 'package:escapeberlin/frontend/widgets/chat/voting_panel.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String? _currentUsername;
  String? _currentHideout;
  String? _selectedRecipient;
  List<String> _players = [];

  // Runden-Variablen
  int _currentRound = 1;
  RoundObjective? _currentObjective;
  int _remainingSeconds = 120; // 2 Minuten
  Timer? _countdownTimer;
  StreamSubscription? _roundSubscription;
  StreamSubscription? _endTimeSubscription;

  // Abstimmungsvariablen
  bool _isVotingActive = false;
  bool _isShadowBanned = false;
  // Bei den anderen Abstimmungsvariablen
  bool _permanentlyBanned =
      false; // Speichert dauerhaften Ban-Status zwischen Runden
  bool _shadowBanDialogShown = false; // Neue Variable zur Kontrolle des Dialogs
  StreamSubscription? _votingStatusSubscription;
  StreamSubscription? _shadowBanSubscription;

  // Zustandsvariablen für das UI
  bool _isObjectiveExpanded = false;

  // Key für das Voting Panel
  final GlobalKey _votingPanelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentUsername = communicationProvider.currentPlayer?.name;
    chatProvider.setUsername(_currentUsername!);
    _currentHideout = communicationProvider.currentPlayer?.hideoutId;
    chatProvider.setHideout(_currentHideout!);
    _setupChatListener();
    _loadPlayers();
    _initializeRoundSystem();
    _initializeVotingSystem();
    // Listener für Rundenübergänge
    roundProvider.roundStream.listen((newRound) {
      if (roundProvider.getCurrentPhase() == GamePhase.finished && mounted) {
        // Navigation zur Ergebnisseite
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GameResultPage()));
        return;
      }

      documentProvider.resetForNewRound(newRound);
      if (_currentHideout != null) {
        votingProvider.resetVotes(_currentHideout!, newRound - 1);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    // Sicherstellen, dass Timer und Subscriptions ordnungsgemäß beendet werden
    _countdownTimer?.cancel();
    _roundSubscription?.cancel();
    _endTimeSubscription?.cancel();
    _votingStatusSubscription?.cancel();
    _shadowBanSubscription?.cancel();

    super.dispose();
  }

  void _initializeRoundSystem() {
    if (_currentHideout != null) {
      _endTimeSubscription = roundProvider.roundEndTimeStream.listen((endTime) {
        _updateCountdown(endTime);
      });

      _roundSubscription = roundProvider.roundStream.listen((round) {
        setState(() {
          _currentRound = round;
          _currentObjective = documentRepo.getRoundObjective(round);
        });
        _initializeVotingSystem();
      });

      roundProvider.initializeRound(_currentHideout!);
    }
  }

  void _initializeVotingSystem() {
  // Bestehende Streams abbrechen
  _votingStatusSubscription?.cancel();
  _shadowBanSubscription?.cancel();

  if (_currentHideout != null && _currentUsername != null) {
    // Status nicht zurücksetzen, wenn bereits permanent gebannt
    if (!_permanentlyBanned) {
      _isShadowBanned = false;
      _shadowBanDialogShown = false;
    }

    // HIER NEU: Direkter Check der aktuellen GamePhase
    GamePhase currentPhase = roundProvider.getCurrentPhase();
    bool isVotingActive = currentPhase == GamePhase.voting;
    
    // Status sofort setzen, ohne auf Stream-Events zu warten
    setState(() {
      _isVotingActive = isVotingActive;
    });
    
    if (isVotingActive && !_permanentlyBanned) {
      _checkIfPlayerIsBanned();
      // Kurze Verzögerung für UI-Update
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted && !_permanentlyBanned) {
          setState(() {}); // Widget neu aufbauen
          _scrollToVotingPanel();
        }
      });
    }

      // GamePhase-Stream für Abstimmungsstatus
      _votingStatusSubscription = roundProvider.phaseStream.listen((phase) {
        bool isVotingActive = phase == GamePhase.voting;
        print("Neue Spielphase: $phase (Voting aktiv: $isVotingActive)");

        bool wasActive = _isVotingActive;

        setState(() {
          _isVotingActive = isVotingActive;
        });

        // Nur für nicht gebannte Spieler aktiv werden
        if (!wasActive && isVotingActive && !_permanentlyBanned) {

          // Bei neuer Abstimmungsphase den Ausschlussstatus erneut prüfen
          // nur wenn nicht bereits gebannt
          if (!_permanentlyBanned) {
            _checkIfPlayerIsBanned();
          }

          // Kurze Verzögerung, um sicherzustellen, dass das VotingPanel korrekt initialisiert wird
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted && !_permanentlyBanned) {
              setState(() {}); // Widget neu aufbauen
              _scrollToVotingPanel();
            }
          });
        }
      });

      // Shadow-Ban-Status nur laden wenn nicht bereits gebannt
      if (!_permanentlyBanned) {
        _loadAndWatchShadowBanStatus();
      }
    }
  }

  void _checkIfPlayerIsBanned() {
    if (_currentHideout != null && !_permanentlyBanned) {
      // Aktiven Status direkt aus dem VotingProvider abrufen
      final bannedPlayer = votingProvider.shadowBannedPlayer;
      print(
          "Prüfe Ausschluss: Banned-Player=$bannedPlayer, Current-Player=$_currentUsername");

      if (bannedPlayer != null && bannedPlayer == _currentUsername) {
        print("MATCH: Du bist ausgeschlossen!");
        _setBannedStatus(true);
        return;
      }

      // Firestore nur prüfen, wenn nicht bereits gebannt
      _checkBannedStatusInDatabase();
    }
  }

  void _setBannedStatus(bool isBanned) {
    // Wenn bereits als gebannt markiert, nichts tun
    if (_permanentlyBanned) return;

    setState(() {
      _isShadowBanned = isBanned;
      _permanentlyBanned = isBanned; // Setzt den permanenten Ban-Status
    });

    // Dialog nur anzeigen, wenn noch nicht angezeigt wurde
    if (isBanned && !_shadowBanDialogShown && mounted) {
      _shadowBanDialogShown = true;
      _showShadowBanNotification();
    }
  }

  // Neue Methode zur direkten Datenbankabfrage
  void _checkBannedStatusInDatabase() async {
    if (_currentHideout == null || _currentUsername == null) return;

    try {
      // Erste Prüfung: Direkt nach ausgeschlossenen Spielern suchen
      // (Diese überprüft alle Ausschlüsse, auch die aus früheren Runden)
      final hideoutDoc = await FirebaseFirestore.instance
          .collection('hideouts')
          .doc(_currentHideout)
          .get();

      if (hideoutDoc.exists && hideoutDoc.data() != null) {
        // Prüfe eliminatedPlayers-Liste
        final data = hideoutDoc.data()!;

        // Prüfung der eliminatedPlayers-Liste (dauerhafter Ausschluss)
        if (data.containsKey('eliminatedPlayers') &&
            data['eliminatedPlayers'] is List) {
          final List<dynamic> eliminatedPlayers = data['eliminatedPlayers'];
          if (eliminatedPlayers.contains(_currentUsername)) {
            print(
                "Spieler $_currentUsername auf eliminatedPlayers-Liste gefunden");
            // Verwende diesen Code:
            _setBannedStatus(true);
            return;
          }
        }

        // Prüfe einzelnes bannedPlayer-Feld (ältere Implementierung)
        if (data.containsKey('bannedPlayer') &&
            data['bannedPlayer'] == _currentUsername) {
          print("MATCH im Hideout-Dokument: Du bist ausgeschlossen!");
          setState(() {
            _isShadowBanned = true;
          });

          if (!_shadowBanDialogShown) {
            // Nur einmalig anzeigen
            _showShadowBanNotification();
          }
          return;
        }
      }

      // 2. Prüfe Player-Dokument (direkter Status im Spielerdokument)
      final playerQuery = await FirebaseFirestore.instance
          .collection('hideouts')
          .doc(_currentHideout)
          .collection('players')
          .where('name', isEqualTo: _currentUsername)
          .get();

      for (var doc in playerQuery.docs) {
        if ((doc.data().containsKey('eliminated') &&
                doc.data()['eliminated'] == true) ||
            (doc.data().containsKey('shadowBanned') &&
                doc.data()['shadowBanned'] == true)) {
          print("MATCH in Player-Dokument: Du bist ausgeschlossen!");
          // Verwende diesen Code:
          _setBannedStatus(true);
          return;
        }
      }

      // 3. Prüfe in der shadowBans-Collection
      final bannedDocs = await FirebaseFirestore.instance
          .collection('lobbies')
          .doc(_currentHideout)
          .collection('shadowBans')
          .get(); // Alle shadowBan-Dokumente prüfen

      for (var doc in bannedDocs.docs) {
        if (doc.exists && doc.data()['playerName'] == _currentUsername) {
          print("MATCH in shadowBans-Collection: Du bist ausgeschlossen!");
          // Verwende diesen Code:
          _setBannedStatus(true);
          return;
        }
      }

      print("Keine Übereinstimmung gefunden - du bist nicht ausgeschlossen.");
    } catch (e) {
      print("Fehler beim Prüfen des Ausschlussstatus: $e");
    }
  }

  // Komplett neue Methode für Shadow-Ban-Überwachung
  void _loadAndWatchShadowBanStatus() {
    if (_currentHideout != null) {
      // Für alle bisherigen Runden den Status laden
      for (int i = 1; i <= _currentRound; i++) {
        votingProvider.loadShadowBanStatus(_currentHideout!, i);
      }

      // Stream für den Shadow-Ban-Status
      _shadowBanSubscription = votingProvider.stream.listen((_) {
        final bannedPlayer = votingProvider.shadowBannedPlayer;
        print(
            "Shadow-Ban-Status aktualisiert: Ausgeschlossener Spieler=$bannedPlayer");

        if (bannedPlayer != null &&
            bannedPlayer == _currentUsername &&
            !_isShadowBanned) {
          print("Shadow-Ban erkannt: Du bist ausgeschlossen!");
          setState(() {
            _isShadowBanned = true;
          });

          if (!_shadowBanDialogShown) {
            // Nur einmalig anzeigen
            _showShadowBanNotification();
          }
        }
      });

      // Stream direkt vom Firestore für eliminatedPlayers-Liste
      FirebaseFirestore.instance
          .collection('hideouts')
          .doc(_currentHideout!)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;

          // Prüfung der eliminatedPlayers-Liste
          if (data.containsKey('eliminatedPlayers') &&
              data['eliminatedPlayers'] is List) {
            final List<dynamic> eliminatedPlayers = data['eliminatedPlayers'];
            if (eliminatedPlayers.contains(_currentUsername) &&
                !_isShadowBanned) {
              print(
                  "Spieler $_currentUsername auf eliminatedPlayers-Liste gefunden (Stream)");
              setState(() {
                _isShadowBanned = true;
              });

              if (!_shadowBanDialogShown) {
                // Nur einmalig anzeigen
                _showShadowBanNotification();
              }
            }
          }

          // Prüfung des bannedPlayer-Feldes
          if (data.containsKey('bannedPlayer') &&
              data['bannedPlayer'] == _currentUsername &&
              !_isShadowBanned) {
            print("Direkter Firestore-Stream zeigt Ausschluss!");
            setState(() {
              _isShadowBanned = true;
            });

            if (!_shadowBanDialogShown) {
              // Nur einmalig anzeigen
              _showShadowBanNotification();
            }
          }
        }
      });
    }
  }

  void _updateCountdown(DateTime endTime) {
    // Bestehenden Timer abbrechen, falls vorhanden
    _countdownTimer?.cancel();

    // Initiale Berechnung der verbleibenden Zeit
    final remaining = endTime.difference(DateTime.now()).inSeconds;
    setState(() {
      _remainingSeconds = remaining > 0 ? remaining : 0;
    });

    // Neuen Timer starten, der jede Sekunde aktualisiert
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = endTime.difference(DateTime.now()).inSeconds;

      // setState nur aufrufen, wenn Widget noch mounted ist
      if (mounted) {
        setState(() {
          _remainingSeconds = remaining > 0 ? remaining : 0;
        });
      }

      // Timer stoppen, wenn Zeit abgelaufen
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _loadPlayers() {
    // Initialisiere mit einer leeren Liste
    setState(() => _players = []);

    // Dann auf Updates hören
    communicationProvider.playerListStream.listen((playerList) {
      if (mounted) {
        setState(() {
          // Stelle sicher, dass die Liste nicht null ist
          _players = playerList
              .where((player) => player != null && player.isNotEmpty)
              .toList();
        });
      }
    });

    communicationProvider.listenToPlayerChanges(_currentHideout!);
  }

  void _setupChatListener() {
    chatProvider.onMessage().listen((message) {
      setState(() {
        _messages.add(message);
      });

      // Auto-scroll nach unten bei neuen Nachrichten
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _sendMessage() {
    // Wenn ShadowBanned, dann täusche Senden vor, aber sende nicht wirklich
    if (_isShadowBanned) {
      // Füge lokal eine Nachricht hinzu, die nur der geshadowbannte Spieler sieht
      final message = ChatMessage(
        username: _currentUsername!,
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        recipient: _selectedRecipient,
      );

      setState(() {
        _messages.add(message);
        _messageController.clear();
      });

      // Auto-scroll nach unten simulieren
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      return; // Frühzeitig beenden - keine echte Nachricht senden
    }

    // Normale Nachrichtenverarbeitung für nicht geshadowbannte Spieler
    if (_messageController.text.trim().isNotEmpty) {
      if (_selectedRecipient != null) {
        chatProvider.sendWhisperMessage(
            _messageController.text.trim(), _selectedRecipient!);
      } else {
        chatProvider.sendMessage(_messageController.text.trim());
      }
      _messageController.clear();
    }
  }

  void _showRoundObjectiveDialog() {
    showDialog(
      context: context,
      builder: (context) => RoundObjectiveDialog(
        currentRound: _currentRound,
        objective: _currentObjective,
        remainingSeconds: _remainingSeconds,
      ),
    );
  }

  void _showInventoryDialog() {
    // Wenn ShadowBanned, zeige einen Hinweis an statt das Inventar
    if (_isShadowBanned) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Du stehst unter Beobachtung und kannst nicht auf dein Inventar zugreifen."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final playerRole =
        communicationProvider.currentPlayer?.role ?? Role.coordinator;
    showDialog(
      context: context,
      builder: (context) => InventoryDialog(
        hideoutId: _currentHideout!,
        playerRole: playerRole,
      ),
    );
  }

  void _showPlayerListDialog() {
    showDialog(
      context: context,
      builder: (context) => PlayerListDialog(
        players: _players,
        currentUsername: _currentUsername!,
        selectedRecipient: _selectedRecipient,
        onSelectRecipient: (recipient) {
          // Wenn ShadowBanned, erlaube das Auswählen, aber ignoriere es später beim Senden
          setState(() {
            _selectedRecipient = recipient;
          });
        },
      ),
    );
  }

  void _showShadowBanNotification() {
    if (mounted) {
      // Dialog-Status setzen, um wiederholte Anzeige zu vermeiden
      _shadowBanDialogShown = true;

      // Permanenter Dialog für ausgeschlossene Spieler
      
    }
  }



  // Hilfsmethode zum Scrollen zum Abstimmungsbereich
  void _scrollToVotingPanel() {
    final RenderObject? renderObject =
        _votingPanelKey.currentContext?.findRenderObject();
    if (renderObject != null) {
      Scrollable.ensureVisible(
        _votingPanelKey.currentContext!,
        alignment: 0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isCurrentUser = message.username == _currentUsername;
    final isWhisper = message.recipient != null;
    final isWhisperToMe = message.recipient == _currentUsername;
    final isWhisperFromMe = isWhisper && isCurrentUser;
    final isSystem = message.isSystem;

    // Farbe je nach Nachrichtentyp
    Color messageColor;
    if (isSystem) {
      messageColor = Colors.amber.withOpacity(0.3);
    } else if (isWhisperFromMe || isWhisperToMe) {
      messageColor = Colors.purple;
    } else if (isCurrentUser) {
      messageColor = foregroundColor;
    } else {
      messageColor = foregroundColor.withOpacity(0.3);
    }

    return Align(
      alignment: isSystem
          ? Alignment.center
          : (isCurrentUser ? Alignment.centerRight : Alignment.centerLeft),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: isSystem
              ? double.infinity
              : MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isSystem ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (!isSystem)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser || isWhisper
                            ? backgroundColor
                            : foregroundColor,
                      ),
                    ),
                  ),
                  if (isWhisper)
                    Icon(
                      Icons.sms,
                      size: 14,
                      color: backgroundColor,
                    ),
                ],
              ),
            if (isWhisper && !isSystem)
              Text(
                isWhisperFromMe ? "An: ${message.recipient}" : "Privat",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                  color: backgroundColor.withOpacity(0.8),
                ),
              ),
            if (!isSystem) const SizedBox(height: 5),
            Text(
              message.message,
              style: TextStyle(
                color: isSystem
                    ? foregroundColor
                    : (isCurrentUser || isWhisper
                        ? backgroundColor
                        : foregroundColor),
                fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
                fontWeight: isSystem ? FontWeight.w500 : FontWeight.normal,
              ),
              textAlign: isSystem ? TextAlign.center : TextAlign.left,
            ),
            if (!isSystem) const SizedBox(height: 3),
            if (!isSystem)
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: (isCurrentUser || isWhisper)
                      ? backgroundColor.withOpacity(0.7)
                      : foregroundColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.right,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "ChatPage Build: _isVotingActive=$_isVotingActive, _isShadowBanned=$_isShadowBanned, Runde=$_currentRound");

    Widget votingPanelWidget;

    // Voting Panel - nur anzeigen wenn aktiv
    if (_isVotingActive &&
        _players.isNotEmpty &&
        _currentUsername != null &&
        _currentHideout != null &&
        !_permanentlyBanned) {
      votingPanelWidget = Container(
        key: _votingPanelKey,
        constraints: BoxConstraints(maxHeight: 400),
        child: VotingPanel(
          key: ValueKey(
              "voting_panel_$_currentRound"), // Key mit Runde für korrektes Rebuild
          hideoutId: _currentHideout!,
          currentRound: _currentRound,
          currentUsername: _currentUsername!,
          players: _players,
        ),
      );
    } else {
      votingPanelWidget = SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              "KOMMUNIKATOR",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_isShadowBanned) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      "Überwacht",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Kompakter Header mit Timer und Rundenziel
          _buildTimerWithObjective(),
    
          // Voting Panel mit korrektem Key
          votingPanelWidget,
    
          // Chat-Nachrichten Bereich - wird größer, wenn kein Voting Panel
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.8),
                border: Border.all(
                  color: _isShadowBanned
                      ? Colors.red.withOpacity(0.7)
                      : foregroundColor,
                  width: _isShadowBanned ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Chat-Nachrichten
                  _messages.isEmpty
                      ? Center(
                          child: Text(
                            "Keine Nachrichten",
                            style: TextStyle(
                                color: foregroundColor.withOpacity(0.7)),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 6),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            if (message.recipient == null ||
                                message.recipient == _currentUsername ||
                                message.username == _currentUsername ||
                                message.isSystem) {
                              return _buildMessage(message);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
    
                  // ShadowBan Overlay - subtil an der Seite anzeigen
                  if (_isShadowBanned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, size: 12, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              "Überwacht: Deine Nachrichten werden nicht gesendet",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    
          // Geteilte Dokumente anzeigen
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.8),
              border: Border.all(color: foregroundColor, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 80,
            child: SharedDocumentsView(currentRound: _currentRound),
          ),
    
          // Nachrichteneingabe mit Flüster-Indikator
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: foregroundColor.withOpacity(0.1),
              border: Border.all(
                color: _isShadowBanned
                    ? Colors.red
                    : (_selectedRecipient != null
                        ? Colors.purple
                        : foregroundColor),
                width: (_isShadowBanned || _selectedRecipient != null) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                // Spielerliste-Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.people_alt_outlined,
                    color: _isShadowBanned
                        ? Colors.red
                        : (_selectedRecipient != null
                            ? Colors.purple
                            : foregroundColor),
                    size: 20,
                  ),
                  onPressed: _showPlayerListDialog,
                  tooltip: 'Spielerliste anzeigen',
                ),
    
                SizedBox(width: 8),
    
                // Inventar-Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.inventory_2_outlined,
                    color: _isShadowBanned ? Colors.red : foregroundColor,
                    size: 20,
                  ),
                  onPressed: _showInventoryDialog,
                  tooltip: 'Inventar öffnen',
                ),
    
                SizedBox(width: 8),
    
                // Textfeld für Nachrichteneingabe
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: foregroundColor),
                    decoration: InputDecoration(
                      hintText: _isShadowBanned
                          ? "Du wurdest isoliert..."
                          : (_selectedRecipient != null
                              ? "An ${_selectedRecipient}..."
                              : "Nachricht eingeben..."),
                      hintStyle: TextStyle(
                        color: _isShadowBanned
                            ? Colors.red.withOpacity(0.7)
                            : (_selectedRecipient != null
                                ? Colors.purple.withOpacity(0.7)
                                : foregroundColor.withOpacity(0.5)),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
    
                // Senden-Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    _isShadowBanned
                        ? Icons.warning
                        : (_selectedRecipient != null
                            ? Icons.send
                            : Icons.send_outlined),
                    color: _isShadowBanned
                        ? Colors.red
                        : (_selectedRecipient != null
                            ? Colors.purple
                            : foregroundColor),
                    size: 20,
                  ),
                  onPressed: _sendMessage,
                  tooltip: _isShadowBanned
                      ? 'Isoliert'
                      : (_selectedRecipient != null ? 'Flüstern' : 'Senden'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kompakter Timer und Rundenziel Header
  Widget _buildTimerWithObjective() {
    // Timer-Farbe basierend auf verbleibender Zeit
    Color timerColor = _remainingSeconds > 30
        ? Colors.green
        : (_remainingSeconds > 10 ? Colors.orange : Colors.red);

    // Formatierte Zeit
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: _showRoundObjectiveDialog,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.2),
          border: Border.all(color: Colors.amber.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rundenindikator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Runde $_currentRound",
                    style: TextStyle(
                      color: backgroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                Spacer(),

                // Timer
                Row(
                  children: [
                    Icon(Icons.timer, color: timerColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Info-Icon für Rundenziel
                SizedBox(width: 8),
                Icon(
                  Icons.info_outline,
                  color: Colors.amber,
                  size: 16,
                ),
              ],
            ),

            // Kompaktes Rundenziel
            if (_currentObjective != null) ...[
              SizedBox(height: 4),
              Text(
                _currentObjective!.title,
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _currentObjective!.description.split('.').first +
                    '...', // Nur erster Satz
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
