import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/providers/communicationprovider.dart';

class ChatProvider {
  final CommunicationProvider _communicationProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _username = '';
  String _currentHideout = '';

  ChatProvider(this._communicationProvider);

  void setUsername(String username) {
    _username = username;
  }

  void joinChat(String hideoutId, String username) {
    _currentHideout = hideoutId;
    _communicationProvider.joinHideout(hideoutId, username);
  }

  void sendMessage(String message) {
    if (_username.isEmpty || _currentHideout.isEmpty) return;

    final chatMessage = {
      'username': _username,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _firestore.collection('lobbies').doc(_currentHideout).collection('messages').add(chatMessage);
  }

  Stream<ChatMessage> onMessage() {
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
          username: data['username'],
          message: data['message'],
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).toList();
    }).expand((messages) => messages);
  }

  void dispose() {
    _currentHideout = '';
    _username = '';
  }
}