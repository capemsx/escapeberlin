import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/player.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:flutter/material.dart';
import 'package:escapeberlin/backend/providers/chatprovider.dart';
import 'package:escapeberlin/backend/providers/roundprovider.dart';

class DocumentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatProvider _chatProvider = chatProvider;
  
  // Singleton-Muster für den DocumentProvider
  static final DocumentProvider _instance = DocumentProvider._internal();
  factory DocumentProvider() => _instance;
  DocumentProvider._internal();
  
  // Spielerdokumente basierend auf Rolle
  Map<Role, List<String>> _roleDocuments = {};
  
  // Status des Dokument-Sharings pro Runde
  Map<int, bool> _hasSharedDocumentInRound = {};
  
  // Initialisiert die verfügbaren Dokumente für jede Rolle
  void initializeDocuments() {
    _roleDocuments = {
      Role.refugee: ['refugee_doc_1', 'refugee_doc_2', 'refugee_doc_3'],
      Role.spy: ['spy_doc_1', 'spy_doc_2', 'spy_doc_3'],
      Role.smuggler: ['smuggler_doc_1', 'smuggler_doc_2', 'smuggler_doc_3'],
      Role.coordinator: ['coordinator_doc_1', 'coordinator_doc_2', 'coordinator_doc_3'],
      Role.counterfeiter: ['counterfeiter_doc_1', 'counterfeiter_doc_2', 'counterfeiter_doc_3'],
      Role.escapeHelper: ['escapehelper_doc_1', 'escapehelper_doc_2', 'escapehelper_doc_3'],
    };
  }
  
  // Gibt alle verfügbaren Dokumente für eine bestimmte Rolle zurück
  List<String> getDocumentsForRole(Role role) {
    return _roleDocuments[role] ?? [];
  }
  
  // Prüft, ob ein Spieler ein Dokument in der aktuellen Runde teilen darf
  bool canShareDocument(int currentRound) {
    return !_hasSharedDocumentInRound.containsKey(currentRound) || 
           !_hasSharedDocumentInRound[currentRound]!;
  }
  
  // Teilt ein Dokument im Chat
  Future<bool> shareDocument(String documentId, String hideoutId, int currentRound) async {
    if (!canShareDocument(currentRound)) {
      return false; // Bereits ein Dokument in dieser Runde geteilt
    }
    
    try {
      // Dokumentinhalt abrufen (später implementieren)
      String documentContent = await _getDocumentContent(documentId);
      
      // Dokument als Systemnachricht im Chat teilen
      final username = _chatProvider.getUsername();
      final message = "$username teilt ein Dokument:\n\n$documentContent";
      
      final chatMessage = {
        'username': 'System',
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isSystem': true,
        'isDocument': true,
        'documentId': documentId
      };
      
      await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('messages')
          .add(chatMessage);
      
      // Status aktualisieren
      _hasSharedDocumentInRound[currentRound] = true;
      notifyListeners();
      
      return true;
    } catch (e) {
      print("Fehler beim Teilen des Dokuments: $e");
      return false;
    }
  }
  
  // Dokument-Inhalte abrufen (Platzhalter)
  Future<String> _getDocumentContent(String documentId) async {
    // In der finalen Implementation würden hier die tatsächlichen Dokumente geladen
    return "Inhalt des Dokuments $documentId wird später hinzugefügt.";
  }
  
  // Status zurücksetzen am Ende einer Runde
  void resetForNewRound(int newRound) {
    if (_hasSharedDocumentInRound.containsKey(newRound - 1)) {
      _hasSharedDocumentInRound.remove(newRound - 1);
    }
    notifyListeners();
  }
}