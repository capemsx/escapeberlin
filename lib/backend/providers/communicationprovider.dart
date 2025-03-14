import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/player.dart';
import 'package:escapeberlin/backend/types/role.dart';

class CommunicationProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _playerCountController = StreamController<int>.broadcast();
  Stream<int> get playerCountStream => _playerCountController.stream;

  final StreamController<List<String>> _playerListController = StreamController<List<String>>.broadcast();
Stream<List<String>> get playerListStream => _playerListController.stream;

  Player? currentPlayer;
  String? hostName; // Hinzufügen der hostName-Eigenschaft

  Future<void> createHideout(String hideoutId, String playerName) async {
    final playerId = _generatePlayerId();
    currentPlayer =
        Player(id: playerId, name: playerName, hideoutId: hideoutId);

    hostName = playerName;
  
  await _firestore.collection('hideouts').doc(hideoutId).set({
    'playerCount': 1,
    'players': [currentPlayer!.toJson()],
    'hostName': playerName, // Speichere auch in Firestore
  });
    return;
  }



  Future<void> joinHideout(String hideoutId, String playerName) async {
    final playerId = _generatePlayerId();
    currentPlayer =
        Player(id: playerId, name: playerName, hideoutId: hideoutId);

    final hideoutDoc = _firestore.collection('hideouts').doc(hideoutId);
    final hideoutData = await hideoutDoc.get();

    

    if (hideoutData.exists) {
      final players = List<Map<String, dynamic>>.from(hideoutData['players']);
      players.add(currentPlayer!.toJson());
hostName = hideoutData['hostName'];
      await hideoutDoc.update({
        'playerCount': players.length,
        'players': players,
      });
    }
    return;
  }

  Future<void> assignRoles(String hideoutId) async {
    final hideoutDoc = _firestore.collection('hideouts').doc(hideoutId);
    final hideoutData = await hideoutDoc.get();

    if (hideoutData.exists) {
      final players = List<Map<String, dynamic>>.from(hideoutData['players']);
      final roles = Role.values.toList()..shuffle();

      for (int i = 0; i < players.length; i++) {
        players[i]['role'] = roles[i].name;
      }

      hideoutDoc.update({
        'players': players,
      });
    }
    return;
  }

  Future<void> joinOrCreateHideout(String hideoutId, String playerName) async {
  final hideoutDoc = _firestore.collection('hideouts').doc(hideoutId);
  final hideoutData = await hideoutDoc.get();

  if (hideoutData.exists) {
    await joinHideout(hideoutId, playerName);
  } else {
    await createHideout(hideoutId, playerName);
  }

  listenToPlayerChanges(hideoutId);
  return;
}

  void listenToPlayerChanges(String hideoutId) {
  final hideoutDoc = _firestore.collection('hideouts').doc(hideoutId);
  hideoutDoc.snapshots().listen((snapshot) {
    if (snapshot.exists) {
      final players =
          List<Map<String, dynamic>>.from(snapshot.data()?['players']);
      final currentPlayerData = players.firstWhere(
          (player) => player['id'] == currentPlayer?.id,
          orElse: () => {});
      if (currentPlayerData.isNotEmpty) {
        final newRole = Role.values
            .firstWhere((role) => role.name == currentPlayerData['role']);
        currentPlayer?.updateRole(newRole);
        print('New role: ${currentPlayer?.role}');
      }
      // Aktualisiere die Spieler-Liste
      final playerNames = players.map((player) => player['name'] as String).toList();
      updatePlayerList(playerNames);
    }
  });
}

  Future<bool> isHideoutFull(String hideoutId) async {
    final hideoutDoc =
        await _firestore.collection('hideouts').doc(hideoutId).get();
    if (hideoutDoc.exists) {
      final playerCount = hideoutDoc.data()?['playerCount'] ?? 0;
      return playerCount >= 6;
    }
    return false;
  }

  void listenToPlayerCount(String hideoutId) {
    _firestore
        .collection('hideouts')
        .doc(hideoutId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _playerCountController.add(snapshot.data()?['playerCount'] ?? 1);
      }
    });
  }

  void updatePlayerList(List<String> newPlayers) {
  _playerListController.add(newPlayers);
}

  void leaveHideout(String hideoutId, String playerName) async {
    final hideoutDoc = _firestore.collection('hideouts').doc(hideoutId);
    final hideoutData = await hideoutDoc.get();

    if (hideoutData.exists) {
      final players = List<Map<String, dynamic>>.from(hideoutData['players']);
      players.removeWhere((player) => player['name'] == playerName);

      hideoutDoc.update({
        'playerCount': players.length,
        'players': players,
      });

      if (players.isEmpty) {
        hideoutDoc.delete();
      }
    }
  }

  String _generatePlayerId() {
    return 'player_${DateTime.now().millisecondsSinceEpoch}';
  }

  void dispose() {
    _playerCountController.close();
  }

  // Getter für die Liste der Player-Objekte
Future<List<Player>> get players async {
  final List<Player> playerList = [];
  if (currentPlayer?.hideoutId == null) return playerList;
  
  try {
    // Spielerliste aus dem Firestore holen
    final hideoutDoc = await _firestore
        .collection('hideouts')
        .doc(currentPlayer!.hideoutId)
        .get();
    
    if (hideoutDoc.exists && hideoutDoc.data() != null) {
      final playersData = List<Map<String, dynamic>>.from(hideoutDoc.data()!['players'] ?? []);
      
      for (var playerData in playersData) {
        final player = Player(
          id: playerData['id'] ?? '',
          name: playerData['name'] ?? '',
          hideoutId: currentPlayer!.hideoutId,
        );
        
        // Rolle setzen wenn verfügbar
        if (playerData.containsKey('role')) {
          player.updateRole(Role.values.firstWhere(
            (r) => r.name == playerData['role'], 
            orElse: () => Role.coordinator
          ));
        }
        
        playerList.add(player);
      }
    }
    return playerList;
  } catch (e) {
    print("Fehler beim Laden der Spieler: $e");
    return playerList;
  }
}
}

