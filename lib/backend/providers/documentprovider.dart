import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/backend/types/player.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class DocumentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton-Muster für den DocumentProvider
  static final DocumentProvider _instance = DocumentProvider._internal();
  factory DocumentProvider() => _instance;
  DocumentProvider._internal();
  
  // Status des Dokument-Sharings pro Runde
  Map<int, bool> _hasSharedDocumentInRound = {};

  // Liste der geteilten Dokumente pro Runde
  Map<int, List<GameDocument>> _sharedDocumentsPerRound = {};
  
  // Getter für geteilte Dokumente
  List<GameDocument> getSharedDocumentsForRound(int round) {
    return _sharedDocumentsPerRound[round] ?? [];
  }
  
  // Methode zum Hinzufügen eines geteilten Dokuments
  void addSharedDocument(GameDocument document, int round) {
    if (!_sharedDocumentsPerRound.containsKey(round)) {
      _sharedDocumentsPerRound[round] = [];
    }
    
    // Prüfen, ob das Dokument bereits geteilt wurde
    if (!_sharedDocumentsPerRound[round]!.any((doc) => doc.id == document.id)) {
      _sharedDocumentsPerRound[round]!.add(document);
      _hasSharedDocumentInRound[round] = true;
      notifyListeners();
    }
  }
  
  // Gibt alle verfügbaren Dokumente für eine bestimmte Rolle und Runde zurück
  List<GameDocument> getDocumentsForRoleAndRound(Role role, int round) {
    return documentRepo.getDocumentsForRoleAndRound(role, round);
  }
  
  
  // Prüft, ob ein Spieler ein Dokument in der aktuellen Runde teilen darf
  bool canShareDocument(int currentRound) {
    return !_hasSharedDocumentInRound.containsKey(currentRound) || 
           !_hasSharedDocumentInRound[currentRound]!;
  }

  // In lib/backend/providers/documentprovider.dart

Stream<List<GameDocument>> streamSharedDocumentsForRound(int round) {
  // Zugriff auf die Firestore-Collection für geteilte Dokumente
  return _firestore
      .collection('lobbies')
      .doc(chatProvider.getHideout())
      .collection('sharedDocuments')
      .where('round', isEqualTo: round)
      .snapshots()
      .map((snapshot) {
        final List<GameDocument> documents = snapshot.docs.map((doc) {
          final data = doc.data();
          return GameDocument(
            id: doc.id,
            title: data['title'] ?? '',
            content: data['content'] ?? '',
            roleRequirement: data['roleRequirement'] ?? '',
            sharedBy: data['sharedBy'] ?? 'Unbekannt', // Benutzername extrahieren
          );
        }).toList();
        
        // Sortiere die Liste für konsistente Anzeige
        documents.sort((a, b) => a.title.compareTo(b.title));
        return documents;
      });
}
  
  // Teilt ein Dokument im Chat
  Future<bool> shareDocument(String documentId, String hideoutId, int currentRound) async {
    if (!canShareDocument(currentRound)) {
      return false; // Bereits ein Dokument in dieser Runde geteilt
    }
    
    try {
      // Dokumentinhalt abrufen
      final document = documentRepo.getDocumentById(documentId);
      
      // Dokument zur Liste der geteilten Dokumente hinzufügen
      addSharedDocument(document, currentRound);
      
      // Dokument als Systemnachricht im Chat teilen
      final username = chatProvider.getUsername();
      final message = "$username teilt ein Dokument:\n\nTitel: ${document.title}\n\n${document.content}";
      
      
      final chatMessage = {
        'username': 'System',
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isSystem': true,
        'isDocument': true,
        'documentId': documentId,
        'documentTitle': document.title,
        'documentContent': document.content
      };
      
      await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('messages')
          .add(chatMessage);
      
      await _firestore
      .collection('lobbies')
      .doc(hideoutId)
      .collection('sharedDocuments')
      .add({
        'documentId': document.id,
        'title': document.title,
        'content': document.content,
        'roleRequirement': document.roleRequirement,
        'round': currentRound,
        'sharedBy': chatProvider.getUsername(),
        'sharedAt': DateTime.now().toIso8601String(),
      });
      
      // Status aktualisieren
      _hasSharedDocumentInRound[currentRound] = true;
      notifyListeners();
      
      return true;
    } catch (e) {
      print("Fehler beim Teilen des Dokuments: $e");
      return false;
    }
  }
  
  // Status zurücksetzen am Ende einer Runde
  void resetForNewRound(int newRound) {
    if (_hasSharedDocumentInRound.containsKey(newRound - 1)) {
      _hasSharedDocumentInRound.remove(newRound - 1);
    }
    notifyListeners();
  }
}