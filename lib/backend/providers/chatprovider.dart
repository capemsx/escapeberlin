import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/providers/communicationprovider.dart';

class ChatProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _username = '';
  String _currentHideout = '';

  // Singleton-Muster für den ChatProvider
  static final ChatProvider _instance = ChatProvider._internal();
  factory ChatProvider() => _instance;
  ChatProvider._internal();

  String getHideout() {
  return _currentHideout;
}

  // Username setzen
  void setUsername(String username) {
    _username = username;
  }

  // Benutzernamen abrufen
  String getUsername() {
    return _username;
  }

  // Aktuelles Versteck (Hideout) setzen
  void setHideout(String hideoutId) {
    _currentHideout = hideoutId;
  }

  // Einem Chat beitreten
  void joinChat(String hideoutId) {
    if (_username.isEmpty) {
      throw Exception('Benutzername muss gesetzt sein, bevor ein Chat betreten werden kann');
    }
    _currentHideout = hideoutId;
  }

  // Nachricht senden
  Future<void> sendMessage(String message) async {
    if (_username.isEmpty || _currentHideout.isEmpty) {
      throw Exception('Benutzername und Hideout müssen gesetzt sein, um Nachrichten zu senden');
    }

    if (message.trim().isEmpty) return;

    final chatMessage = {
      'username': _username,
      'message': message.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection('lobbies')
        .doc(_currentHideout)
        .collection('messages')
        .add(chatMessage);
  }

  Future<void> sendWhisperMessage(String message, String recipientUsername) async {
  if (_username.isEmpty || _currentHideout.isEmpty) {
    throw Exception('Benutzername und Hideout müssen gesetzt sein, um Nachrichten zu senden');
  }

  if (message.trim().isEmpty) return;

  final chatMessage = {
    'username': _username,
    'message': message.trim(),
    'timestamp': DateTime.now().toIso8601String(),
    'recipient': recipientUsername,
  };

  await _firestore
      .collection('lobbies')
      .doc(_currentHideout)
      .collection('messages')
      .add(chatMessage);
}

  // Systemnachricht senden
  Future<void> sendSystemMessage(String message) async {
    if (_currentHideout.isEmpty) {
      throw Exception('Hideout muss gesetzt sein, um Systemnachrichten zu senden');
    }

    if (message.trim().isEmpty) return;

    final chatMessage = {
      'username': 'System',
      'message': message.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection('lobbies')
        .doc(_currentHideout)
        .collection('messages')
        .add(chatMessage);
  }

  // Stream mit allen Nachrichten
  Stream<List<ChatMessage>> getMessages() {
    if (_currentHideout.isEmpty) {
      // Leeren Stream zurückgeben, wenn kein Hideout gesetzt ist
      return Stream.value([]);
    }

    return _firestore
        .collection('lobbies')
        .doc(_currentHideout)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          username: data['username'] ?? 'Unbekannt',
          message: data['message'] ?? '',
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).toList();
    });
  }

  // Einzeln ankommende Nachrichten
  Stream<ChatMessage> onMessage() {
    if (_currentHideout.isEmpty) {
      // Leeren Stream zurückgeben, wenn kein Hideout gesetzt ist
      return Stream.empty();
    }

    return _firestore
        .collection('lobbies')
        .doc(_currentHideout)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .expand((snapshot) {
          return snapshot.docChanges
              .where((change) => change.type == DocumentChangeType.added)
              .map((change) {
            final data = change.doc.data()!;
            return ChatMessage(
              username: data['username'] ?? 'Unbekannt',
              message: data['message'] ?? '',
              timestamp: DateTime.parse(data['timestamp']),
              recipient: data['recipient'], // Hier wird das recipient-Feld hinzugefügt
            );
          }).toList();
        });
  }

  // Ressourcen freigeben
  void dispose() {
    _currentHideout = '';
    // Username behalten wir, falls der Nutzer in einen anderen Chat wechselt
  }

  // ChatPage benötigt aktuellen Benutzernamen
  String getCurrentUsername() {
    return _username;
  }
}

// Globale Instanz für einfachen Zugriff
final chatProvider = ChatProvider();