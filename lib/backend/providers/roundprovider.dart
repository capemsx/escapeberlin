import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapeberlin/backend/types/gamephase.dart';
import 'package:escapeberlin/globals.dart';

class RoundProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<int> _roundController =
      StreamController<int>.broadcast();
  final StreamController<DateTime> _roundEndTimeController =
      StreamController<DateTime>.broadcast();
  final StreamController<GamePhase> _phaseController =
      StreamController<GamePhase>.broadcast();

  Stream<int> get roundStream => _roundController.stream;
  Stream<DateTime> get roundEndTimeStream => _roundEndTimeController.stream;
  Stream<GamePhase> get phaseStream => _phaseController.stream;

  Timer? _roundTimer;
  int _currentRound = 1;
  DateTime? _roundEndTime;
  GamePhase _currentPhase = GamePhase.playing;

  // Singleton-Muster
  static final RoundProvider _instance = RoundProvider._internal();
  factory RoundProvider() => _instance;
  RoundProvider._internal();

  // Dauer einer Runde in Sekunden
  static const int roundDuration = 300; // 2 Minuten
  static const int votingDuration = 90; // 30 Sekunden

  // Aktuelle Spielphase abrufen
  GamePhase getCurrentPhase() {
    return _currentPhase;
  }

  // Initiale Runde starten oder einer laufenden Runde beitreten
  Future<void> initializeRound(String hideoutId) async {
    final hideoutDoc =
        await _firestore.collection('hideouts').doc(hideoutId).get();

    if (hideoutDoc.exists) {
      // Prüfen, ob bereits eine laufende Runde existiert
      if (hideoutDoc.data()!.containsKey('currentRound') &&
          hideoutDoc.data()!.containsKey('roundEndTime') &&
          hideoutDoc.data()!.containsKey('currentPhase')) {
        _currentRound = hideoutDoc.data()!['currentRound'];
        final endTimeMillis = hideoutDoc.data()!['roundEndTime'];
        _roundEndTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
        _currentPhase = _parseGamePhase(hideoutDoc.data()!['currentPhase']);

        // Nur Timer starten, wenn die Runde noch nicht vorbei ist
        final now = DateTime.now();
        if (_roundEndTime!.isAfter(now)) {
          if (_currentPhase == GamePhase.playing) {
            _startRoundTimer(_roundEndTime!.difference(now).inSeconds);
          } else {
            _startVotingTimer(_roundEndTime!.difference(now).inSeconds);
          }
        } else {
          // Wenn die Phase bereits vorbei sein sollte, nächste Phase starten
          if (_currentPhase == GamePhase.playing) {
            _startVotingPhase(hideoutId);
          } else {
            _advanceToNextRound(hideoutId);
          }
        }
      } else {
        // Keine laufende Runde, neue starten
        _startNewRound(hideoutId);
      }
    } else {
      print("Fehler: Hideout existiert nicht");
    }

    // Listener für Rundenänderungen einrichten
    _firestore
        .collection('hideouts')
        .doc(hideoutId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final newRound = snapshot.data()!['currentRound'] ?? 1;
        final newEndTimeMillis = snapshot.data()!['roundEndTime'];
        final newEndTime =
            DateTime.fromMillisecondsSinceEpoch(newEndTimeMillis);
        final newPhase =
            _parseGamePhase(snapshot.data()!['currentPhase'] ?? 'playing');

        // Nur aktualisieren, wenn sich etwas geändert hat
        if (newRound != _currentRound ||
            newEndTime != _roundEndTime ||
            newPhase != _currentPhase) {
          _currentRound = newRound;
          _roundEndTime = newEndTime;
          _currentPhase = newPhase;

          _roundController.add(_currentRound);
          _roundEndTimeController.add(_roundEndTime!);
          _phaseController.add(_currentPhase);

          // Timer neu starten
          _cancelRoundTimer();
          final now = DateTime.now();
          if (_roundEndTime!.isAfter(now)) {
            if (_currentPhase == GamePhase.playing) {
              _startRoundTimer(_roundEndTime!.difference(now).inSeconds);
            } else {
              _startVotingTimer(_roundEndTime!.difference(now).inSeconds);
            }
          }
        }
      }
    });
  }

  // Umwandeln des String-Werts in GamePhase Enum
  // Umwandeln des String-Werts in GamePhase Enum
GamePhase _parseGamePhase(String phase) {
  switch (phase) {
    case 'voting':
      return GamePhase.voting;
    case 'finished':
      return GamePhase.finished;
    case 'playing':
    default:
      return GamePhase.playing;
  }
}

  // Eine neue Spielrunde starten
  Future<void> _startNewRound(String hideoutId) async {
    _currentRound = 1;
    _currentPhase = GamePhase.playing;
    _roundEndTime = DateTime.now().add(Duration(seconds: roundDuration));

    // In Firestore speichern
    await _firestore.collection('hideouts').doc(hideoutId).update({
      'currentRound': _currentRound,
      'currentPhase': 'playing',
      'roundEndTime': _roundEndTime!.millisecondsSinceEpoch,
      'votes': {}, // Zurücksetzen der Stimmen
    });

    _roundController.add(_currentRound);
    _phaseController.add(_currentPhase);
    _roundEndTimeController.add(_roundEndTime!);
    _startRoundTimer(roundDuration);
  }

  // Zur Abstimmungsphase wechseln
  Future<void> _startVotingPhase(String hideoutId) async {
    _currentPhase = GamePhase.voting;
    _roundEndTime = DateTime.now().add(Duration(seconds: votingDuration));

    // In Firestore speichern
    await _firestore.collection('hideouts').doc(hideoutId).update({
      'currentPhase': 'voting',
      'roundEndTime': _roundEndTime!.millisecondsSinceEpoch,
      'votes': {}, // Zurücksetzen der Stimmen für neue Abstimmung
    });

    _phaseController.add(_currentPhase);
    _roundEndTimeController.add(_roundEndTime!);
    _startVotingTimer(votingDuration);
  }

  // Zur nächsten Runde wechseln
Future<void> _advanceToNextRound(String hideoutId) async {
  try {
    // Nur Host darf die Abstimmung beenden und Runde wechseln
    if (!_isHost()) {
      print("Nicht-Host versucht, zur nächsten Runde zu wechseln - ignoriert");
      return;
    }
    
    // Abstimmungsergebnis auswerten
    await votingProvider.endVoting(hideoutId, _currentRound);
    
    // Prüfen, ob der Spitzel eliminiert wurde
    final spyEliminated = await votingProvider.wasSpyEliminated();
    
    // Aktuelle Rundennummer aus Firestore lesen, um konsistent zu bleiben
    final hideoutDoc = await _firestore.collection('hideouts').doc(hideoutId).get();
    int currentRound = hideoutDoc.data()?['currentRound'] ?? 1;
    
    // Spiel beenden, wenn Spy eliminiert oder Runde 4 erreicht wurde
    if (spyEliminated || currentRound >= 5) {
      print("Spiel beendet nach Runde $currentRound. Spitzel eliminiert: $spyEliminated");
      await _endGame(hideoutId);
      return;
    }

    // Neue Rundendaten berechnen
    final newRound = currentRound + 1;
    final newPhase = GamePhase.playing;
    final newEndTime = DateTime.now().add(Duration(seconds: roundDuration));

    print("Wechsel zu Runde $newRound (Host: ${communicationProvider.currentPlayer?.name})");

    // Atomares Update in Firestore
    await _firestore.collection('hideouts').doc(hideoutId).update({
      'currentRound': newRound,
      'currentPhase': 'playing',
      'roundEndTime': newEndTime.millisecondsSinceEpoch,
    });

    // Lokale Variablen erst NACH erfolgreicher Firestore-Aktualisierung setzen
    _currentRound = newRound;
    _currentPhase = newPhase;
    _roundEndTime = newEndTime;
    
    // Streams aktualisieren
    _roundController.add(_currentRound);
    _phaseController.add(_currentPhase);
    _roundEndTimeController.add(_roundEndTime!);

    // Benachrichtigung im Chat (nur Host sendet diese)
    await chatProvider.sendSystemMessage("Runde $_currentRound beginnt jetzt!");

    // Timer starten
    _startRoundTimer(roundDuration);
  } catch (e) {
    print("Fehler beim Wechsel zur nächsten Runde: $e");
  }
}

Future<void> _endGame(String hideoutId) async {
  try {
    // GamePhase auf "finished" setzen
    await _firestore.collection('hideouts').doc(hideoutId).update({
      'currentPhase': 'finished',
      'gameEnded': true,
    });
    
    // Spielphase im lokalen Zustand aktualisieren
    _currentPhase = GamePhase.finished;
    
    // Phase-Controller aktualisieren
    _phaseController.add(_currentPhase);

    // Prüfen, ob der Spitzel erfolgreich identifiziert wurde
    final spyEliminated = await votingProvider.wasSpyEliminated();
    final winMessage = spyEliminated 
        ? "🎉 Der Spitzel wurde identifiziert! Die Gruppe hat gewonnen!" 
        : "😈 Der Spitzel konnte nicht rechtzeitig identifiziert werden! Der Spitzel gewinnt!";

    // Systembenachrichtigung senden
    await chatProvider.sendSystemMessage("🎮 Das Spiel ist beendet!\n$winMessage");
    
    print("Spiel-Ende-Phase eingeleitet: Spy wurde ${spyEliminated ? '' : 'nicht '}eliminiert.");
  } catch (e) {
    print("Fehler beim Beenden des Spiels: $e");
  }
}

  // Systemnachricht an den Chat senden
  Future<void> _sendSystemMessage(String hideoutId, String message) async {
    final chatMessage = {
      'username': 'System',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isSystem': true,
    };

    await _firestore
        .collection('lobbies')
        .doc(hideoutId)
        .collection('messages')
        .add(chatMessage);
  }

  // Stimme für einen Spieler abgeben
  Future<void> voteForPlayer(
      String hideoutId, String voterId, String votedFor) async {
    if (_currentPhase != GamePhase.voting) return;

    await _firestore
        .collection('hideouts')
        .doc(hideoutId)
        .update({'votes.$voterId': votedFor});
  }

  // Alle abgegebenen Stimmen abrufen
  Stream<Map<String, dynamic>> getVotesStream(String hideoutId) {
    return _firestore.collection('hideouts').doc(hideoutId).snapshots().map(
        (snapshot) =>
            Map<String, dynamic>.from(snapshot.data()?['votes'] ?? {}));
  }

  // Timer für die Spielphase starten
  void _startRoundTimer(int seconds) {
    _cancelRoundTimer();
    _roundTimer = Timer(Duration(seconds: seconds), () {
      // Diese Logik wird nur beim Host ausgeführt
      if (_isHost()) {
        _startVotingPhase(_getCurrentHideoutId());
      }
    });
  }

  // Timer für die Abstimmungsphase starten
  void _startVotingTimer(int seconds) {
    _cancelRoundTimer();
    _roundTimer = Timer(Duration(seconds: seconds), () {
      // Diese Logik wird nur beim Host ausgeführt
      if (_isHost()) {
        // Erst Abstimmung beenden
        votingProvider
            .endVoting(_getCurrentHideoutId(), _currentRound)
            .then((_) => _advanceToNextRound(_getCurrentHideoutId()));
      }
    });
  }

  // Laufenden Timer abbrechen
  void _cancelRoundTimer() {
    _roundTimer?.cancel();
    _roundTimer = null;
  }

  bool _isHost() {
  // Verwende den lokalen Cache statt eines asynchronen Future-Aufrufs
  final currentPlayer = communicationProvider.currentPlayer;
  final String? hostName = communicationProvider.hostName;
  
  if (currentPlayer != null && hostName != null) {
    return currentPlayer.name == hostName;
  }
  return false;
}

  // Aktuelles Hideout abrufen
  String _getCurrentHideoutId() {
    return chatProvider.getHideout();
  }

  // Aktuelle Rundennummer abrufen
  int getCurrentRound() {
    return _currentRound;
  }

  // Verbleibende Zeit in der aktuellen Phase (in Sekunden)
  int getRemainingTime() {
    if (_roundEndTime == null) return 0;

    final now = DateTime.now();
    if (_roundEndTime!.isAfter(now)) {
      return _roundEndTime!.difference(now).inSeconds;
    }
    return 0;
  }

  // Ressourcen freigeben
  void dispose() {
    _cancelRoundTimer();
    _roundController.close();
    _roundEndTimeController.close();
    _phaseController.close();
  }
}

final roundProvider = RoundProvider();
