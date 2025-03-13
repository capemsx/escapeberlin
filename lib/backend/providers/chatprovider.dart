import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Private Felder für Benutzername und Hideout-ID
  String? _username;
  String? _hideout;
  
  // Singleton-Muster für ChatProvider
  static final ChatProvider _instance = ChatProvider._internal();
  factory ChatProvider() => _instance;
  ChatProvider._internal();

  // Getter für username und hideout
  String getUsername() => _username ?? 'Unbekannt';
  String getHideout() => _hideout ?? '';

  // Setter für username und hideout
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setHideout(String hideout) {
    _hideout = hideout;
    notifyListeners();
  }

  // Methode zum Senden einer Nachricht
  Future<void> sendMessage(String message) async {
    if (_username == null || _hideout == null) {
      return;
    }

    final chatMessage = ChatMessage(
      username: _username!,
      message: message,
      timestamp: DateTime.now(),
    );

    // Nachricht in Firestore speichern
    await _firestore
        .collection('lobbies')
        .doc(_hideout)
        .collection('messages')
        .add(chatMessage.toMap());
  }

  // Methode zum Senden einer Flüsternachricht
  Future<void> sendWhisperMessage(String message, String recipient) async {
    if (_username == null || _hideout == null) {
      return;
    }

    final chatMessage = ChatMessage(
      username: _username!,
      message: message,
      recipient: recipient,
      timestamp: DateTime.now(),
    );

    // Nachricht in Firestore speichern
    await _firestore
        .collection('lobbies')
        .doc(_hideout)
        .collection('messages')
        .add(chatMessage.toMap());
  }

  // Methode zum Senden einer Systemnachricht
  Future<void> sendSystemMessage(String message) async {
    if (_hideout == null) {
      return;
    }

    final chatMessage = ChatMessage(
      username: "System",
      message: message,
      timestamp: DateTime.now(),
      isSystem: true,
    );

    // Systemnachricht in Firestore speichern
    await _firestore
        .collection('lobbies')
        .doc(_hideout)
        .collection('messages')
        .add(chatMessage.toMap());
  }

  // Stream für eingehende Nachrichten
  Stream<ChatMessage> onMessage() {
    if (_hideout == null) {
      // Wenn kein Hideout festgelegt ist, gib einen leeren Stream zurück
      return Stream.empty();
    }

    return _firestore
        .collection('lobbies')
        .doc(_hideout)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .expand((snapshot) {
          // Bei der ersten Abfrage alle vorhandenen Nachrichten zurückgeben
          if (snapshot.metadata.isFromCache && snapshot.docChanges.isEmpty) {
            return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data()));
          }
          
          // Bei Updates nur die neuen/geänderten Nachrichten zurückgeben
          return snapshot.docChanges
              .where((change) => change.type == DocumentChangeType.added)
              .map((change) => ChatMessage.fromMap(change.doc.data()!));
        });
  }
}