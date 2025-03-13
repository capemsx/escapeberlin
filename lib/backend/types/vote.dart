
class Vote {
  final String voterId;  // ID des abstimmenden Spielers
  final String voterName;  // Name des abstimmenden Spielers
  final String targetId;  // ID des Spielers, für den gestimmt wird
  final String targetName;  // Name des Spielers, für den gestimmt wird
  final DateTime timestamp;  // Zeitpunkt der Stimmabgabe
  final int round;  // Spielrunde, in der die Abstimmung stattfindet

  Vote({
    required this.voterId,
    required this.voterName,
    required this.targetId,
    required this.targetName,
    required this.timestamp,
    required this.round,
  });

  Map<String, dynamic> toMap() {
    return {
      'voterId': voterId,
      'voterName': voterName,
      'targetId': targetId,
      'targetName': targetName,
      'timestamp': timestamp.toIso8601String(),
      'round': round,
    };
  }

  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      voterId: map['voterId'] ?? '',
      voterName: map['voterName'] ?? '',
      targetId: map['targetId'] ?? '',
      targetName: map['targetName'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      round: map['round'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Vote(von: $voterName, für: $targetName, runde: $round)';
  }
}

class VoteResult {
  final String targetName;
  final int voteCount;
  final List<String> voterNames; // Namen der abstimmenden Spieler
  final bool isEliminated;

  VoteResult({
    required this.targetName,
    required this.voteCount,
    this.voterNames = const [],
    this.isEliminated = false,
  });
  
  @override
  String toString() {
    return 'VoteResult($targetName: $voteCount Stimmen, Eliminated: $isEliminated)';
  }
}

class EliminationRecord {
  final String playerName;
  final int round;
  final int voteCount;
  final DateTime timestamp;
  final List<String> voters;

  EliminationRecord({
    required this.playerName,
    required this.round,
    required this.voteCount,
    required this.timestamp,
    this.voters = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'round': round,
      'voteCount': voteCount,
      'timestamp': timestamp.toIso8601String(),
      'voters': voters,
    };
  }

  factory EliminationRecord.fromMap(Map<String, dynamic> map) {
    return EliminationRecord(
      playerName: map['playerName'] ?? '',
      round: map['round'] ?? 0,
      voteCount: map['voteCount'] ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      voters: map['voters'] != null
          ? List<String>.from(map['voters'])
          : [],
    );
  }
}
