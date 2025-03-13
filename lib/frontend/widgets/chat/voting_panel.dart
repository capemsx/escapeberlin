import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/gamephase.dart';
import 'package:escapeberlin/backend/types/vote.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class VotingPanel extends StatefulWidget {
  final String hideoutId;
  final int currentRound;
  final List<String> players;
  final String currentUsername;
  
  const VotingPanel({
    Key? key,
    required this.hideoutId,
    required this.currentRound,
    required this.players,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<VotingPanel> createState() => _VotingPanelState();
}

class _VotingPanelState extends State<VotingPanel> with SingleTickerProviderStateMixin {
  StreamSubscription? _votingStatusSubscription;
  StreamSubscription? _voteResultsSubscription;
  StreamSubscription? _phaseSubscription;
  StreamSubscription? _eliminatedPlayersSubscription; // Neuer Stream für ausgeschlossene Spieler
  List<VoteResult> _results = [];
  bool _isVotingActive = false;
  DateTime? _votingEndTime;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  String? _selectedPlayer;
  List<String> _eliminatedPlayers = []; // Liste der ausgeschlossenen Spieler

  // Hinzufügen eines AnimationController für Aufmerksamkeit
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation für Aufmerksamkeit hinzufügen
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Wiederholt die Animation, um Aufmerksamkeit zu erregen
    _animationController.repeat(reverse: true);
    
    _initStreams();
  }

  @override
  void didUpdateWidget(VotingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Wenn sich die Runde geändert hat, Streams neu initialisieren
    if (oldWidget.currentRound != widget.currentRound) {
      print("Runde geändert von ${oldWidget.currentRound} zu ${widget.currentRound}, initialisiere Streams neu");
      
      // Streams abbrechen und neu initialisieren
      _votingStatusSubscription?.cancel();
      _voteResultsSubscription?.cancel();
      _phaseSubscription?.cancel();
      _initStreams();
      
      // Zurücksetzen des ausgewählten Spielers für die neue Runde
      _selectedPlayer = null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _votingStatusSubscription?.cancel();
    _voteResultsSubscription?.cancel();
    _phaseSubscription?.cancel();
    _eliminatedPlayersSubscription?.cancel(); // Neuen Stream abbrechen
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initStreams() {
    // Stream für ausgeschlossene Spieler abonnieren
    _eliminatedPlayersSubscription = FirebaseFirestore.instance
      .collection('hideouts')
      .doc(widget.hideoutId)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey('eliminatedPlayers')) {
          final data = snapshot.data()!;
          if (data['eliminatedPlayers'] is List) {
            setState(() {
              _eliminatedPlayers = List<String>.from(data['eliminatedPlayers']);
            });
            print("Ausgeschlossene Spieler aktualisiert: $_eliminatedPlayers");
          }
        } else {
          setState(() {
            _eliminatedPlayers = [];
          });
        }
      });
    
    // Stream für die Spielphase - kombinierter Ansatz
    _phaseSubscription = roundProvider.phaseStream.listen((phase) {
      final isActive = phase == GamePhase.voting;
      
      if (mounted) {
        setState(() {
          _isVotingActive = isActive;
          // Bei Phase-Änderung auch Endzeit abrufen
          if (isActive) {
            // Wir nutzen firstWhere mit leerer Startzeit als Fallback
            roundProvider.roundEndTimeStream.first.then((endTime) {
              if (mounted) {
                setState(() {
                  _votingEndTime = endTime;
                  _updateCountdown();
                });
              }
            }).catchError((_) {
              print("Fehler beim Abrufen der Endzeit");
            });
          }
        });
      }
    });
    
    // Stream für den Abstimmungsstatus als Backup
    _votingStatusSubscription = votingProvider.votingActiveStream(
      widget.hideoutId, 
      widget.currentRound
    ).listen((isActive) {
      if (mounted) {
        setState(() {
          _isVotingActive = isActive;
          _votingEndTime = votingProvider.votingEndTime;
          if (_votingEndTime != null) {
            _updateCountdown();
          }
        });
      }
      
      // Aktuelle Stimme setzen
      _selectedPlayer = votingProvider.currentVote;
    });
    
    // Stream für die Abstimmungsergebnisse mit verbessertem Error-Handling
    _voteResultsSubscription = votingProvider.voteResultsStream(
      widget.hideoutId,
      widget.currentRound
    ).listen(
      (results) {
        if (mounted) {
          print("Neue Abstimmungsergebnisse für Runde ${widget.currentRound}: $results");
          setState(() {
            _results = results;
          });
        }
      }, 
      onError: (error) {
        print("Fehler im voteResultsStream: $error");
      }
    );

    // Zustand initial setzen
    _isVotingActive = roundProvider.getCurrentPhase() == GamePhase.voting;
    if (_isVotingActive) {
      _updateCountdown();
    }
    
    // Shadow-Ban-Status laden
    _loadEliminatedPlayers();
    
    // Aktuelle Stimme setzen
    _loadCurrentVotes();
  }

  // Neue Methode zum Laden der ausgeschlossenen Spieler
  void _loadEliminatedPlayers() async {
    try {
      final hideoutDoc = await FirebaseFirestore.instance
          .collection('hideouts')
          .doc(widget.hideoutId)
          .get();
          
      if (hideoutDoc.exists && hideoutDoc.data() != null) {
        final data = hideoutDoc.data()!;
        if (data.containsKey('eliminatedPlayers') && data['eliminatedPlayers'] is List) {
          setState(() {
            _eliminatedPlayers = List<String>.from(data['eliminatedPlayers']);
          });
          print("Ausgeschlossene Spieler geladen: $_eliminatedPlayers");
        }
      }
    } catch (e) {
      print("Fehler beim Laden der ausgeschlossenen Spieler: $e");
    }
  }

  // Neue Methode zur Abfrage der aktuellen Stimmen für diese Runde
  void _loadCurrentVotes() async {
    try {
      final votes = await votingProvider.getVotesForRound(widget.hideoutId, widget.currentRound);
      print("Geladene Stimmen für Runde ${widget.currentRound}: $votes");
      
      // Aktuelle Stimme des Spielers setzen
      final currentPlayer = communicationProvider.currentPlayer;
      if (currentPlayer != null) {
        final myVote = votes.firstWhere(
          (vote) => vote.voterId == currentPlayer.id, 
          orElse: () => Vote(
            voterId: "", 
            voterName: "", 
            targetId: "", 
            targetName: "", 
            timestamp: DateTime.now(), 
            round: widget.currentRound
          )
        );
        
        if (myVote.voterId.isNotEmpty) {
          setState(() {
            _selectedPlayer = myVote.targetName;
          });
          print("Eigene Stimme gefunden: $_selectedPlayer");
        }
      }
    } catch (e) {
      print("Fehler beim Laden der aktuellen Stimmen: $e");
    }
  }

  void _updateCountdown() {
    // Bestehenden Timer stoppen
    _countdownTimer?.cancel();
    
    if (_votingEndTime != null) {
      // Initiale Berechnung
      final remaining = _votingEndTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        _remainingSeconds = remaining > 0 ? remaining : 0;
      });
      
      // Timer für regelmäßige Updates
      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_votingEndTime != null) {
          final remaining = _votingEndTime!.difference(DateTime.now()).inSeconds;
          
          if (mounted) {
            setState(() {
              _remainingSeconds = remaining > 0 ? remaining : 0;
            });
          }
          
          if (_remainingSeconds <= 0) {
            timer.cancel();
          }
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _voteForPlayer(String playerName) async {
    final currentPlayer = communicationProvider.currentPlayer;
    if (currentPlayer == null || !_isVotingActive) return;
    
    // Prüfen, ob der Spieler für sich selbst abstimmen möchte
    if (currentPlayer.name == playerName) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Du kannst nicht für dich selbst stimmen!"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          )
        );
      }
      return;
    }
    
    // Spieler-ID ist in diesem Fall sein Name (kann später durch echte IDs ersetzt werden)
    final targetId = playerName;
    
    final success = await votingProvider.voteForPlayer(
      currentPlayer.id,
      currentPlayer.name,
      targetId,
      playerName,
      widget.currentRound,
    );
    
    if (success) {
      setState(() {
        _selectedPlayer = playerName;
      });
      
      // Öffentliche Bekanntgabe der Abstimmung im Chat
      chatProvider.sendSystemMessage(
        "📊 ${currentPlayer.name} hat für $playerName als Spitzel gestimmt."
      );
      
      // Zeige Bestätigung
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Du hast für $playerName gestimmt. Der Spieler mit den meisten Stimmen wird am Ende ausgeschlossen!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          )
        );
      }
    }
  }

  // Füge diese Debug-Methode hinzu, um den aktuellen Zustand auszugeben
  void _logCurrentState() {
    print("VotingPanel - Aktueller Zustand:");
    print("- isVotingActive: $_isVotingActive");
    print("- selectedPlayer: $_selectedPlayer");
    print("- votingEndTime: $_votingEndTime");
    print("- remainingSeconds: $_remainingSeconds");
    print("- Ergebnisse: $_results");
  }

  @override
  Widget build(BuildContext context) {
    // Debug-Ausgabe
    _logCurrentState();
    
    // Wenn keine aktive Abstimmung läuft, zeige nichts an
    if (!_isVotingActive) {
      return const SizedBox.shrink(); // Komplett unsichtbar
    }
    
    // Timer-Farbe basierend auf verbleibender Zeit
    Color timerColor = _remainingSeconds > 30 
        ? Colors.green 
        : (_remainingSeconds > 10 ? Colors.orange : Colors.red);
    
    // Container mit Animation für mehr Aufmerksamkeit während aktiver Abstimmung
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              border: Border.all(
                color: Colors.red.withOpacity(0.7),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header mit Titel und Timer
                Row(
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      color: Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "ABSTIMMUNG LÄUFT!",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (_votingEndTime != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: timerColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: timerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: timerColor, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: timerColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                Divider(color: foregroundColor.withOpacity(0.3), thickness: 1.5),
                
                // Abstimmungsbereich
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.privacy_tip, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Wer ist der Spitzel? Stimme jetzt ab!",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Der Spieler mit den meisten Stimmen wird als Spitzel identifiziert und AUS DEM SPIEL AUSGESCHLOSSEN!",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Spielerliste für Abstimmung mit Stimmzählung
                _buildVotingList(),
                
                SizedBox(height: 10),
                
                // Aktuelle Auswahl anzeigen
                if (_selectedPlayer != null) 
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Du hast für $_selectedPlayer gestimmt",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Du hast noch nicht abgestimmt!",
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Überarbeitete Version des _buildVotingList()-Widgets mit Null-Sicherheit, Ausschluss-Filterung und Scrolling
  Widget _buildVotingList() {
    // Map für aktuelle Stimmen pro Spieler erstellen - mit Null-Sicherheit
    Map<String, int> voteCounts = {};
    
    // Befüllen der Map mit den aktuellen Stimmen für alle bekannten Spieler
    for (var player in widget.players) {
      voteCounts[player] = 0; // Initialisierung mit 0 Stimmen für alle Spieler (auch den eigenen)
    }
    
    // Dann aktuelle Abstimmungsergebnisse eintragen
    for (var result in _results) {
      voteCounts[result.targetName] = result.voteCount;
    }
    
    // Liste der aktiven Spieler (ohne ausgeschlossene)
    final activePlayers = widget.players
        .where((player) => !_eliminatedPlayers.contains(player))
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Für wen stimmst du?",
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: foregroundColor.withOpacity(0.3)),
          ),
          // Begrenze die Höhe des Containers, um Scrolling zu ermöglichen
          constraints: BoxConstraints(maxHeight: 220),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                activePlayers.length,
                (index) {
                  final playerName = activePlayers[index]; // Aktiver Spieler
                  final isCurrentUser = playerName == widget.currentUsername;
                  final isSelected = _selectedPlayer == playerName;
                  // Sichere Abfrage mit Fallback auf 0
                  final voteCount = voteCounts[playerName] ?? 0;
                  
                  return Column(
                    children: [
                      if (index > 0)
                        Divider(
                          height: 1,
                          color: foregroundColor.withOpacity(0.2),
                          indent: 10,
                          endIndent: 10,
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red.withOpacity(0.2) : 
                                (isCurrentUser ? Colors.grey.withOpacity(0.1) : Colors.transparent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            // Zeige unterschiedliches Icon basierend auf Status
                            Icon(
                              isSelected ? Icons.check_circle : 
                              (isCurrentUser ? Icons.person : Icons.radio_button_unchecked),
                              color: isSelected ? Colors.red : 
                                    (isCurrentUser ? foregroundColor.withOpacity(0.5) : foregroundColor.withOpacity(0.7)),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                playerName + (isCurrentUser ? " (Du)" : ""),
                                style: TextStyle(
                                  color: isCurrentUser ? foregroundColor.withOpacity(0.7) : foregroundColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16,
                                  fontStyle: isCurrentUser ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: voteCount > 0 
                                    ? Colors.amber.withOpacity(0.3) 
                                    : foregroundColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$voteCount ${voteCount == 1 ? 'Stimme' : 'Stimmen'}",
                                style: TextStyle(
                                  color: voteCount > 0 ? Colors.amber : foregroundColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: voteCount > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            // Für andere Spieler als den aktuellen: Abstimmungsbutton
                            if (!isCurrentUser)
                              IconButton(
                                icon: Icon(
                                  isSelected ? Icons.how_to_vote : Icons.how_to_vote_outlined,
                                  color: isSelected ? Colors.red : foregroundColor.withOpacity(0.7),
                                ),
                                onPressed: () => _voteForPlayer(playerName),
                                tooltip: 'Für ${playerName} stimmen',
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Überarbeitete Ergebnisanzeige
  Widget _buildVoteResults() {
    final shadowBannedPlayer = votingProvider.shadowBannedPlayer;
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Abstimmungsergebnis",
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              final isTopVote = index == 0;
              final isShadowBanned = result.targetName == shadowBannedPlayer;
              
              return Container(
                margin: EdgeInsets.only(bottom: 6),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: isShadowBanned 
                      ? Colors.red.withOpacity(0.2) 
                      : (isTopVote ? Colors.amber.withOpacity(0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isShadowBanned 
                        ? Colors.red.withOpacity(0.7) 
                        : (isTopVote ? Colors.amber.withOpacity(0.5) : Colors.transparent),
                  ),
                ),
                child: Row(
                  children: [
                    if (isShadowBanned)
                      Icon(Icons.visibility, size: 16, color: Colors.red)
                    else if (isTopVote)
                      Icon(Icons.warning, size: 16, color: Colors.amber)
                    else
                      Text(
                        "${index + 1}.",
                        style: TextStyle(
                          color: foregroundColor.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.targetName,
                        style: TextStyle(
                          color: foregroundColor,
                          fontWeight: isShadowBanned || isTopVote ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isShadowBanned 
                            ? Colors.red.withOpacity(0.6) 
                            : (isTopVote ? Colors.amber.withOpacity(0.3) : foregroundColor.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${result.voteCount} ${result.voteCount == 1 ? 'Stimme' : 'Stimmen'}",
                        style: TextStyle(
                          color: isShadowBanned 
                              ? Colors.white 
                              : (isTopVote ? Colors.amber.shade900 : foregroundColor),
                          fontSize: 13,
                          fontWeight: isShadowBanned || isTopVote ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
