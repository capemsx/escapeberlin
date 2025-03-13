// in lib/backend/types/chatmessage.dart
class ChatMessage {
  final String username;
  final String message;
  final DateTime timestamp;
  final String? recipient; // Optional, für Flüsternachrichten
  final bool isSystem; // Flag für Systemnachrichten
  final bool isDocument; // Kennzeichnet Dokument-Mitteilungen

  ChatMessage({
    required this.username,
    required this.message,
    required this.timestamp,
    this.recipient,
    this.isSystem = false,
    this.isDocument = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (recipient != null) 'recipient': recipient,
      if (isSystem) 'isSystem': true,
      if (isDocument) 'isDocument': true,
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      username: json['username'] ?? 'Unbekannt',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      recipient: json['recipient'],
      isSystem: json['isSystem'] ?? false,
      isDocument: json['isDocument'] ?? false,
    );
  }

  // Factory-Methode zum Erstellen aus Firestore-Daten
  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      username: data['username'] ?? 'Unbekannt',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] != null 
          ? DateTime.parse(data['timestamp']) 
          : DateTime.now(),
      recipient: data['recipient'],
      isSystem: data['isSystem'] ?? false,
      isDocument: data['isDocument'] ?? false,
    );
  }

  // Umwandlung in Map für Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (recipient != null) 'recipient': recipient,
      if (isSystem) 'isSystem': true,
      if (isDocument) 'isDocument': true,
    };
  }
}