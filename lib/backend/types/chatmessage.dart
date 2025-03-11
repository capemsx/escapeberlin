// in lib/backend/types/chatmessage.dart
class ChatMessage {
  final String username;
  final String message;
  final DateTime timestamp;
  final String? recipient; // Optional, für Flüsternachrichten
  final String? hideoutId; // Optional, für Raum-Identifizierung
  final bool isSystem; // Flag für Systemnachrichten

  ChatMessage({
    required this.username,
    required this.message,
    required this.timestamp,
    this.recipient,
    this.hideoutId,
    this.isSystem = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (recipient != null) 'recipient': recipient,
      if (hideoutId != null) 'hideoutId': hideoutId,
      if (isSystem) 'isSystem': true,
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      username: json['username'] ?? 'Unbekannt',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      recipient: json['recipient'],
      hideoutId: json['hideoutId'],
      isSystem: json['isSystem'] ?? false,
    );
  }
}