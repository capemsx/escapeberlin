import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/types/player.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/frontend/widgets/chat/inventory.dart';
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
  bool _isLoadingPlayers = true;

  // Runden-Variablen
  int _currentRound = 1;
  int _remainingSeconds = 120; // 2 Minuten
  Timer? _countdownTimer;
  StreamSubscription? _roundSubscription;
  StreamSubscription? _endTimeSubscription;

  @override
  void initState() {
    super.initState();
    _currentUsername = communicationProvider.currentPlayer?.name;
    chatProvider.setUsername(_currentUsername!);
    _currentHideout = communicationProvider.currentPlayer?.hideoutId;
    chatProvider.setHideout(_currentHideout!);
    _setupChatListener();
    _loadPlayers();

    // Initialisierung sofort ausführen
    _initializeRoundSystem();

    // In der initState-Methode von _ChatPageState ergänzen:

// Listener für Rundenübergänge
roundProvider.roundStream.listen((newRound) {
  // Dokument-Sharing-Status zurücksetzen
  documentProvider.resetForNewRound(newRound);
});
  }

// Neue Methode zur Initialisierung des Rundensystems
  void _initializeRoundSystem() {
    if (_currentHideout != null) {
      print("Initialisiere Rundensystem für Hideout: $_currentHideout");

      // Timer-Stream sofort abonnieren
      _endTimeSubscription = roundProvider.roundEndTimeStream.listen((endTime) {
        print("Neue Endzeit erhalten: $endTime");
        _updateCountdown(endTime);
      });

      // Rundenstream abonnieren
      _roundSubscription = roundProvider.roundStream.listen((round) {
        print("Neue Runde erhalten: $round");
        setState(() {
          _currentRound = round;
        });
      });

      // Dann erst initializeRound aufrufen
      roundProvider.initializeRound(_currentHideout!).then((_) {
        print("Rundensystem initialisiert");
        // Force-Update des Timers durch direkte Abfrage
        final currentEndTime = DateTime.fromMillisecondsSinceEpoch(
            FirebaseFirestore.instance
                    .collection('hideouts')
                    .doc(_currentHideout)
                    .get()
                    .then((snapshot) => snapshot.data()?['roundEndTime'] ?? 0)
                as int);
        if (currentEndTime != null) {
          _updateCountdown(currentEndTime);
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
      _countdownTimer = null;
    }
    if (_roundSubscription != null) {
      _roundSubscription!.cancel();
      _roundSubscription = null;
    }
    if (_endTimeSubscription != null) {
      _endTimeSubscription!.cancel();
      _endTimeSubscription = null;
    }
    super.dispose();
  }

  // Countdown-Timer aktualisieren
  void _updateCountdown(DateTime endTime) {
    // Bestehenden Timer stoppen
    _countdownTimer?.cancel();

    // Neuen Timer starten
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = endTime.difference(DateTime.now()).inSeconds;

      setState(() {
        _remainingSeconds = remaining > 0 ? remaining : 0;
      });

      // Wenn der Timer abgelaufen ist, stoppen wir ihn
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _loadPlayers() {
    _isLoadingPlayers = true;

    // Direkte Abfrage aus Firestore
    if (_currentHideout != null) {
      print("Versuche Spielerliste zu laden aus Hideout: $_currentHideout");

      FirebaseFirestore.instance
          .collection('hideouts')
          .doc(_currentHideout)
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;

        if (snapshot.exists) {
          try {
            final List<dynamic> playersData = snapshot.data()?['players'] ?? [];
            final playerNames =
                playersData.map((player) => player['name'] as String).toList();

            print("Spielerliste geladen: $playerNames");

            setState(() {
              _players = playerNames;
              _isLoadingPlayers = false;
            });
          } catch (e) {
            print("Fehler beim Laden der Spielerliste: $e");
            setState(() {
              _isLoadingPlayers = false;
            });
          }
        } else {
          print("Hideout existiert nicht");
          setState(() {
            _isLoadingPlayers = false;
          });
        }
      }, onError: (error) {
        print("Fehler beim Abrufen des Hideouts: $error");
        setState(() {
          _isLoadingPlayers = false;
        });
      });
    }
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
    if (_messageController.text.trim().isNotEmpty) {
      // Wenn ein Empfänger ausgewählt ist, sendWhisperMessage verwenden, sonst normale sendMessage
      if (_selectedRecipient != null) {
        chatProvider.sendWhisperMessage(
            _messageController.text.trim(), _selectedRecipient!);
      } else {
        chatProvider.sendMessage(_messageController.text.trim());
      }
      _messageController.clear();
    }
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        // Debug-Info für Spielerliste
        if (_isLoadingPlayers)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Lade Spielerliste...",
              style: TextStyle(color: foregroundColor),
            ),
          ),

        // Wenn keine Spieler geladen wurden oder die Liste leer ist
        if (!_isLoadingPlayers && _players.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Keine anderen Spieler gefunden",
              style: TextStyle(color: foregroundColor.withOpacity(0.7)),
            ),
          ),

        // Dropdown für Empfängerauswahl
        if (_players.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: foregroundColor.withOpacity(0.1),
              border: Border.all(color: foregroundColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  "An: ",
                  style: TextStyle(color: foregroundColor),
                ),
                Expanded(
                  child: DropdownButton<String?>(
                    dropdownColor: backgroundColor,
                    underline: Container(),
                    value: _selectedRecipient,
                    hint: Text(
                      "Alle",
                      style: TextStyle(color: foregroundColor.withOpacity(0.7)),
                    ),
                    style: TextStyle(color: foregroundColor),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          "Alle",
                          style: TextStyle(color: foregroundColor),
                        ),
                      ),
                      ..._players
                          .where((player) => player != _currentUsername)
                          .map((player) => DropdownMenuItem<String>(
                                value: player,
                                child: Text(
                                  player,
                                  style: TextStyle(color: foregroundColor),
                                ),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRecipient = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

        // Nachrichteneingabe
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: foregroundColor.withOpacity(0.1),
            border: Border.all(
              color:
                  _selectedRecipient != null ? Colors.purple : foregroundColor,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: foregroundColor),
                  decoration: InputDecoration(
                    hintText: _selectedRecipient != null
                        ? "Flüstern an ${_selectedRecipient}..."
                        : "Nachricht eingeben...",
                    hintStyle: TextStyle(
                      color: _selectedRecipient != null
                          ? Colors.purple.withOpacity(0.7)
                          : foregroundColor.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: Icon(
                  _selectedRecipient != null ? Icons.sms : Icons.send,
                  color: _selectedRecipient != null
                      ? Colors.purple
                      : foregroundColor,
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventory() {
    // Hole die Rolle des aktuellen Spielers (muss entsprechend implementiert sein)
    Role playerRole = communicationProvider.currentPlayer?.role ?? Role.refugee;

    return InventoryWidget(
      hideoutId: _currentHideout!,
      playerRole: playerRole,
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isCurrentUser = message.username == _currentUsername;
    final isWhisper = message.recipient != null;
    final isWhisperToMe = message.recipient == _currentUsername;
    final isWhisperFromMe = isWhisper && isCurrentUser;

    // Farbe je nach Nachrichtentyp
    Color messageColor;
    if (isWhisperFromMe || isWhisperToMe) {
      // Flüsternachricht - lila
      messageColor = Colors.purple;
    } else if (isCurrentUser) {
      // Eigene Nachricht
      messageColor = foregroundColor;
    } else {
      // Fremde Nachricht
      messageColor = foregroundColor.withOpacity(0.3);
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (isWhisper)
              Text(
                isWhisperFromMe ? "An: ${message.recipient}" : "Privat",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                  color: backgroundColor.withOpacity(0.8),
                ),
              ),
            const SizedBox(height: 5),
            Text(
              message.message,
              style: TextStyle(
                color: isCurrentUser || isWhisper
                    ? backgroundColor
                    : foregroundColor,
              ),
            ),
            const SizedBox(height: 3),
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

  // Timer-Widget für die Rundenanzeige
  Widget _buildRoundTimer() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Farbe je nach verbleibender Zeit
    Color timerColor;
    if (_remainingSeconds > 30) {
      timerColor = Colors.green;
    } else if (_remainingSeconds > 10) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        border: Border.all(color: foregroundColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'RUNDE $_currentRound',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: timerColor,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                timeStr,
                style: TextStyle(
                  color: timerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "VERSCHLÜSSELTE KOMMUNIKATION",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 10),
            _buildRoundTimer(),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: foregroundColor),
      ),
      body: Column(
        children: [
          // Chat-Nachrichten
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.8),
                border: Border.all(color: foregroundColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        "Keine Nachrichten",
                        style:
                            TextStyle(color: foregroundColor.withOpacity(0.7)),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        // Zeige nur Nachrichten an, die für alle oder für mich bestimmt sind
                        if (message.recipient == null ||
                            message.recipient == _currentUsername ||
                            message.username == _currentUsername) {
                          return _buildMessage(message);
                        } else {
                          return const SizedBox
                              .shrink(); // Verstecke Flüsternachrichten für andere
                        }
                      },
                    ),
            ),
          ),

          // Nachrichteneingabe mit Empfängerauswahl
          _buildInventory(),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
