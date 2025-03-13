import 'dart:async';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/backend/types/roundobjective.dart';
import 'package:escapeberlin/frontend/widgets/chat/inventory_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/player_list_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/round_objective_dialog.dart';
import 'package:escapeberlin/frontend/widgets/chat/shared_documents_view.dart';
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

  // Zustandsvariablen für das UI
  bool _isObjectiveExpanded = false;

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

    // Listener für Rundenübergänge
    roundProvider.roundStream.listen((newRound) {
      documentProvider.resetForNewRound(newRound);
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
      });

      roundProvider.initializeRound(_currentHideout!);
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
    communicationProvider.playerListStream.listen((playerList) {
      setState(() => _players = playerList);
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
    final playerRole = communicationProvider.currentPlayer?.role ?? Role.refugee;
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
          setState(() {
            _selectedRecipient = recipient;
          });
        },
      ),
    );
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
      alignment: isSystem ? Alignment.center : (isCurrentUser ? Alignment.centerRight : Alignment.centerLeft),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: isSystem ? double.infinity : MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isSystem ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (!isSystem) Row(
              children: [
                Expanded(
                  child: Text(
                    message.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser || isWhisper ? backgroundColor : foregroundColor,
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
                color: isSystem ? foregroundColor : (isCurrentUser || isWhisper ? backgroundColor : foregroundColor),
                fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
                fontWeight: isSystem ? FontWeight.w500 : FontWeight.normal,
              ),
              textAlign: isSystem ? TextAlign.center : TextAlign.left,
            ),
            if (!isSystem) const SizedBox(height: 3),
            if (!isSystem) Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: (isCurrentUser || isWhisper) ? backgroundColor.withOpacity(0.7) : foregroundColor.withOpacity(0.7),
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
          ],
        ),
        centerTitle: true,
        // Entferne den Inventar-Button aus der AppBar
      ),
      body: Column(
        children: [
          // Kompakter Header mit Timer und Rundenziel
          _buildTimerWithObjective(),
          
          // Chat-Nachrichten - mehr Platz zuweisen
          Expanded(
            flex: 3, // Mehr Platz für Nachrichten
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.8),
                border: Border.all(color: foregroundColor, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _messages.isEmpty
                ? Center(
                    child: Text(
                      "Keine Nachrichten",
                      style: TextStyle(color: foregroundColor.withOpacity(0.7)),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
            ),
          ),

          // Geteilte Dokumente anzeigen - kompakter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.8),
              border: Border.all(color: foregroundColor, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 80, // Weniger Höhe
            child: SharedDocumentsView(currentRound: _currentRound),
          ),

          // Nachrichteneingabe mit Flüster-Indikator
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: foregroundColor.withOpacity(0.1),
              border: Border.all(
                color: _selectedRecipient != null ? Colors.purple : foregroundColor,
                width: _selectedRecipient != null ? 2 : 1,
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
                    color: _selectedRecipient != null ? Colors.purple : foregroundColor,
                    size: 20,
                  ),
                  onPressed: _showPlayerListDialog,
                  tooltip: 'Spielerliste anzeigen',
                ),
                
                SizedBox(width: 8),

                // Inventar-Button - neu positioniert bei der Textzeile
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.inventory_2_outlined,
                    color: foregroundColor,
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
                      hintText: _selectedRecipient != null
                          ? "An ${_selectedRecipient}..."
                          : "Nachricht eingeben...",
                      hintStyle: TextStyle(
                        color: _selectedRecipient != null
                            ? Colors.purple.withOpacity(0.7)
                            : foregroundColor.withOpacity(0.5),
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
                    _selectedRecipient != null ? Icons.send : Icons.send_outlined,
                    color: _selectedRecipient != null ? Colors.purple : foregroundColor,
                    size: 20,
                  ),
                  onPressed: _sendMessage,
                  tooltip: _selectedRecipient != null ? 'Flüstern' : 'Senden',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Neues Widget für kombinierten Timer und Rundenziel
  Widget _buildTimerWithObjective() {
    // Timer-Farbe basierend auf verbleibender Zeit
    Color timerColor = _remainingSeconds > 30 
      ? Colors.green 
      : (_remainingSeconds > 10 ? Colors.orange : Colors.red);
    
    // Formatierte Zeit
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return GestureDetector(
      onTap: _showRoundObjectiveDialog, // Öffnet das Detail-Dialog beim Tippen
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
                _currentObjective!.description.split('.').first + '...', // Nur erster Satz
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
