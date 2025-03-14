import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/gamephase.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/backend/types/vote.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';

class VotingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton-Muster für den VotingProvider
  static final VotingProvider _instance = VotingProvider._internal();
  factory VotingProvider() => _instance;
  
  // Stream-Controller für allgemeine Statusänderungen
  final _streamController = StreamController<void>.broadcast();
  Stream<void> get stream => _streamController.stream;
  
  VotingProvider._internal();
  
  // Status-Variablen
bool _isVotingActive = false;
DateTime? _votingEndTime;
String? _currentVote;
String? _shadowBannedPlayer;
List<VoteResult> _voteResults = [];
List<String> _eliminatedPlayers = []; // Diese Zeile hinzufügen
  
  // Getter
  bool get isVotingActive => _isVotingActive;
  DateTime? get votingEndTime => _votingEndTime;
  String? get currentVote => _currentVote;
  String? get shadowBannedPlayer => _shadowBannedPlayer;
  List<VoteResult> get voteResults => _voteResults;

  // Prüft, ob ein Spieler geshadowbanned ist
  bool isPlayerShadowBanned(String playerName) {
    return _shadowBannedPlayer == playerName;
  }
  
  // Verbesserte Version des voteResultsStream mit besserer Fehlerbehandlung
  Stream<List<VoteResult>> voteResultsStream(String hideoutId, int round) {
    return _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('votes')
        .where('round', isEqualTo: round)
        .snapshots()
        .map((snapshot) {
      try {
        // Zähle Stimmen für jeden Spieler
        Map<String, int> voteCount = {};
        
        for (var doc in snapshot.docs) {
          final voteData = doc.data();
          if (voteData != null) {
            final vote = Vote.fromMap(voteData);
            if (vote.targetName.isNotEmpty) {  // Stelle sicher, dass der Name nicht leer ist
              voteCount[vote.targetName] = (voteCount[vote.targetName] ?? 0) + 1;
            }
          }
        }
        
        // Konvertiere Map zu einer sortierten Liste von VoteResult
        List<VoteResult> results = voteCount.entries
            .map((entry) => VoteResult(
                  targetName: entry.key,
                  voteCount: entry.value,
                ))
            .toList();
        
        // Sortiere nach Anzahl der Stimmen (absteigend)
        results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
        
        // Aktualisiere lokale Variable
        _voteResults = results;
        
        notifyListeners();
        return results;
      } catch (e) {
        print('Fehler bei der Verarbeitung der Abstimmungsergebnisse: $e');
        return <VoteResult>[];  // Leere Liste zurückgeben im Fehlerfall
      }
    }).handleError((error) {
      print('Fehler im voteResultsStream: $error');
      return <VoteResult>[];  // Leere Liste zurückgeben im Fehlerfall
    });
  }
  
  // Verbesserte Version des votingActiveStream mit direktem Gaming-State-Abgleich
  Stream<bool> votingActiveStream(String hideoutId, int round) {
    return StreamGroup.merge([
      // Stream aus Firestore hideouts collection
      _firestore
        .collection('hideouts')
        .doc(hideoutId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            final phase = snapshot.data()?['currentPhase'] ?? 'playing';
            final isVoting = phase == 'voting';
            
            // Nur Status ändern wenn sich wirklich was geändert hat
            if (_isVotingActive != isVoting) {
              _isVotingActive = isVoting;
              
              // Falls aktiv, auch EndTime auslesen
              if (isVoting) {
                final endTimeMillis = snapshot.data()?['roundEndTime'];
                if (endTimeMillis != null) {
                  _votingEndTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
                }
              } else {
                // Bei Ende der Abstimmung, Signal für Status-Reset
                _votingEndTime = null;
              }
              
              notifyListeners();
              _streamController.add(null);
            }
            
            return isVoting;
          }
          return false;
        }),
      
      // Stream vom roundProvider - direkter Zugriff auf GamePhase
      roundProvider.phaseStream.map((phase) {
        final isVoting = phase == GamePhase.voting;
        
        // Nur Status ändern wenn sich wirklich was geändert hat
        if (_isVotingActive != isVoting) {
          _isVotingActive = isVoting;
          
          if (isVoting) {
            // Bei Votingphase auch die Endzeit vom roundProvider abrufen
            roundProvider.roundEndTimeStream.listen((endTime) {
              _votingEndTime = endTime;
              notifyListeners();
              _streamController.add(null);
            });
          } else {
            // Bei Ende der Abstimmung, Signal für Status-Reset
            _votingEndTime = null;
          }
          
          notifyListeners();
          _streamController.add(null);
        }
        
        return isVoting;
      })
    ]).distinct().asBroadcastStream();
  }
  
  // Starte eine neue Abstimmungsphase
  Future<void> startVoting(String hideoutId, int round, int durationInSeconds) async {
    final endTime = DateTime.now().add(Duration(seconds: durationInSeconds));
    
    await _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('votingPhases')
        .doc('round_$round')
        .set({
          'isActive': true,
          'startTime': DateTime.now().toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'round': round,
        });
    
    // Systembenachrichtigung für Abstimmungsbeginn
    await chatProvider.sendSystemMessage(
      "Eine Abstimmungsphase hat begonnen! Wer ist der Spitzel? Stimmt ab!",
    );
    
    _isVotingActive = true;
    _votingEndTime = endTime;
    notifyListeners();
  }

// Prüft, ob der Spitzel ausgeschlossen wurde
Future<bool> wasSpyEliminated() async {
  try {
    // Spielerliste holen
    final players = await communicationProvider.players;
    
    // Laden der aktuellen eliminatedPlayers Liste
    final hideoutId = chatProvider.getHideout();
    final hideoutDoc = await _firestore.collection('hideouts').doc(hideoutId).get();
    
    if (hideoutDoc.exists && hideoutDoc.data() != null) {
      final data = hideoutDoc.data()!;
      if (data.containsKey('eliminatedPlayers') && data['eliminatedPlayers'] is List) {
        _eliminatedPlayers = List<String>.from(data['eliminatedPlayers']);
      }
    }
    
    // Suche nach einem ausgeschlossenen Spieler mit Rolle "Spy"
    for (var player in players) {
      if (player.role == Role.spy && _eliminatedPlayers.contains(player.name)) {
        return true;
      }
    }
    return false;
  } catch (e) {
    print("Fehler beim Überprüfen des Spy-Eliminierungsstatus: $e");
    return false;
  }
}

  // Überarbeitete Methode zum Beenden der Abstimmung und Ausschließen des Spielers
  Future<void> endVoting(String hideoutId, int round) async {
    try {
      print("Beende Abstimmung für Hideout $hideoutId, Runde $round");
      
      // Voting-Status aktualisieren
      await updateVotingStatus(hideoutId, round, false);
      
      // GamePhase in hideouts zurücksetzen
      await _firestore
          .collection('hideouts')
          .doc(hideoutId)
          .update({
            'currentPhase': 'playing',
          });
      
      // Ergebnisse ermitteln
      List<VoteResult> results = await _calculateVoteResults(hideoutId, round);
      print("Abstimmungsergebnisse: $results");
      
      // Systembenachrichtigung für Abstimmungsende
      if (results.isNotEmpty) {
        // Der Spieler mit den meisten Stimmen wird ausgeschlossen
        final topVote = results.first;
        _shadowBannedPlayer = topVote.targetName;
        
        print("Spieler mit meisten Stimmen: ${topVote.targetName} (${topVote.voteCount} Stimmen)");
        
        // Speichern des Ausschluss-Status in Firestore (mehrere Stellen für Redundanz)
        // 1. In shadowBans Collection
        await _firestore
            .collection('lobbies')
            .doc(hideoutId)
            .collection('shadowBans')
            .doc('round_$round')
            .set({
              'playerName': _shadowBannedPlayer,
              'voteCount': topVote.voteCount,
              'timestamp': DateTime.now().toIso8601String(),
              'eliminated': true,
            });
        
        print("Shadow-Ban in Firestore gespeichert");
            
        // 2. Direkter Status im players-Dokument
        try {
          final playerQuery = await _firestore
              .collection('hideouts')
              .doc(hideoutId)
              .collection('players')
              .where('name', isEqualTo: _shadowBannedPlayer)
              .get();
              
          if (playerQuery.docs.isNotEmpty) {
            for (var doc in playerQuery.docs) {
              print("Markiere Spieler ${doc.id} als ausgeschlossen");
              await doc.reference.update({
                'eliminated': true,
                'shadowBanned': true,
                'eliminatedInRound': round
              });
            }
          } else {
            print("Spieler $_shadowBannedPlayer nicht in der players Collection gefunden");
          }
        } catch (e) {
          print("Fehler beim Markieren des Spielers als ausgeschlossen: $e");
        }
        
        // 3. Auch im Hideout-Dokument direkt eine Liste der ausgeschlossenen Spieler pflegen
        try {
          final hideoutDoc = await _firestore
              .collection('hideouts')
              .doc(hideoutId)
              .get();
              
          List<String> eliminatedPlayers = [];
          if (hideoutDoc.exists && hideoutDoc.data() != null) {
            final data = hideoutDoc.data()!;
            if (data.containsKey('eliminatedPlayers') && data['eliminatedPlayers'] is List) {
              eliminatedPlayers = List<String>.from(data['eliminatedPlayers']);
            }
          }
          
          if (!eliminatedPlayers.contains(_shadowBannedPlayer)) {
            eliminatedPlayers.add(_shadowBannedPlayer!);
            await _firestore
              .collection('hideouts')
              .doc(hideoutId)
              .update({
                'eliminatedPlayers': eliminatedPlayers,
                'bannedPlayer': _shadowBannedPlayer // Auch hier für Kompatibilität setzen
              });
              
            print("Spieler $_shadowBannedPlayer zur eliminatedPlayers-Liste hinzugefügt");
            
            // Systembenachrichtigung im Chat senden
            await chatProvider.sendSystemMessage(
              "⚠️ ABSTIMMUNG BEENDET ⚠️\n${topVote.targetName} wurde mit ${topVote.voteCount} Stimmen als Spitzel identifiziert und isoliert!"
            );
          }
        } catch (e) {
          print("Fehler beim Aktualisieren der eliminatedPlayers-Liste: $e");
        }
      } else {
        await chatProvider.sendSystemMessage(
          "Die Abstimmung ist beendet. Es wurden keine Stimmen abgegeben."
        );
        
        print("Keine Stimmen abgegeben, niemand wird ausgeschlossen");
      }
      
      _isVotingActive = false;
      notifyListeners();
      _streamController.add(null);
    } catch (e) {
      print("Fehler beim Beenden der Abstimmung: $e");
    }
  }
  
  Future<List<VoteResult>> _calculateVoteResults(String hideoutId, int round) async {
    final snapshot = await _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('votes')
        .where('round', isEqualTo: round)
        .get();
    
    Map<String, int> voteCount = {};
    
    for (var doc in snapshot.docs) {
      final vote = Vote.fromMap(doc.data());
      voteCount[vote.targetName] = (voteCount[vote.targetName] ?? 0) + 1;
    }
    
    List<VoteResult> results = voteCount.entries
        .map((entry) => VoteResult(
              targetName: entry.key,
              voteCount: entry.value,
            ))
        .toList();
    
    results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    
    return results;
  }
  
  // Aktualisiere den Abstimmungsstatus
  Future<void> updateVotingStatus(String hideoutId, int round, bool isActive) async {
  try {
    print("Aktualisiere Voting-Status: hideoutId=$hideoutId, round=$round, isActive=$isActive");
    
    final docRef = _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('votingPhases')
        .doc('round_$round');
    
    // Mehr Daten hinzufügen, damit das Dokument komplett ist
    await docRef.set({
      'isActive': isActive,
      'round': round,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    print("Voting-Status erfolgreich aktualisiert");
  } catch (e) {
    print("Fehler beim Aktualisieren des Voting-Status: $e");
    throw e;  // Fehler weiterleiten zur besseren Diagnose
  }
}
  
  // Verbesserte voteForPlayer-Methode mit zusätzlicher Prüfung gegen Selbst-Abstimmung
  // und Prüfung, ob der Spieler bereits ausgeschlossen ist
  Future<bool> voteForPlayer(String voterId, String voterName, String targetId, String targetName, int round) async {
    try {
      if (!_isVotingActive) return false;
      if (targetName.isEmpty || voterId.isEmpty) {
        print("Ungültige Parameter bei der Abstimmung");
        return false;
      }
      
      // Prüfe, ob jemand für sich selbst stimmen möchte - verbieten
      if (voterName == targetName) {
        print("Selbst-Abstimmung nicht erlaubt");
        return false;
      }
      
      final hideoutId = chatProvider.getHideout();
      if (hideoutId == null || hideoutId.isEmpty) {
        print("Kein gültiges Hideout für die Abstimmung");
        return false;
      }
      
      // Prüfen, ob bereits abgestimmt wurde
      final existingVote = await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('votes')
          .where('voterId', isEqualTo: voterId)
          .where('round', isEqualTo: round)
          .get();
      
      // Vorherige Stimme löschen, falls vorhanden
      for (var doc in existingVote.docs) {
        await doc.reference.delete();
      }
      
      // Neue Stimme speichern
      final vote = Vote(
        voterId: voterId,
        voterName: voterName,
        targetId: targetId, 
        targetName: targetName,
        timestamp: DateTime.now(),
        round: round,
      );
      
      await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('votes')
          .add(vote.toMap());
      
      _currentVote = targetName;
      notifyListeners();
      
      return true;
    } catch (e) {
      print("Fehler beim Abstimmen: $e");
      return false;
    }
  }
  
  // Löschen aller Abstimmungen für eine bestimmte Runde
  Future<void> resetVotes(String hideoutId, int round) async {
    final snapshot = await _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('votes')
        .where('round', isEqualTo: round)
        .get();
    
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    
    // Auch den Shadow-Ban zurücksetzen
    await _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('shadowBans')
        .doc('round_$round')
        .delete();
    
    _currentVote = null;
    _shadowBannedPlayer = null;
    _voteResults = [];
    notifyListeners();
  }
  
  // Verbesserte Methode zum Laden des Shadow-Ban-Status
  Future<void> loadShadowBanStatus(String hideoutId, int round) async {
    try {
      final doc = await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('shadowBans')
          .doc('round_$round')
          .get();
      
      if (doc.exists && doc.data() != null) {
        _shadowBannedPlayer = doc.data()?['playerName'];
        print('Shadow-Ban-Status geladen: $_shadowBannedPlayer ist ausgeschlossen');
        notifyListeners();
        _streamController.add(null);
      } else {
        print('Kein Shadow-Ban für Runde $round gefunden');
      }
    } catch (e) {
      print('Fehler beim Laden des Shadow-Ban-Status: $e');
    }
  }
  
  // Neue Methode zum Abrufen aller Stimmen für eine bestimmte Runde
  Future<List<Vote>> getVotesForRound(String hideoutId, int round) async {
    try {
      final snapshot = await _firestore
          .collection('lobbies')
          .doc(hideoutId)
          .collection('votes')
          .where('round', isEqualTo: round)
          .get();
      
      List<Vote> votes = [];
      for (var doc in snapshot.docs) {
        votes.add(Vote.fromMap(doc.data()));
      }
      
      print("Votes für Runde $round geladen: ${votes.length} Stimmen");
      return votes;
    } catch (e) {
      print('Fehler beim Laden der Stimmen für Runde $round: $e');
      return [];
    }
  }
  
  // Aufräumen bei App-Ende
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
