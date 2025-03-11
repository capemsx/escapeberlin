import 'dart:async';
import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';

class RoundTimer extends StatefulWidget {
  const RoundTimer({Key? key}) : super(key: key);

  @override
  State<RoundTimer> createState() => _RoundTimerState();
}

class _RoundTimerState extends State<RoundTimer> {
  int _currentRound = 1;
  int _remainingSeconds = 0;
  Timer? _localTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Auf Rundenänderungen hören
    roundProvider.roundStream.listen((round) {
      setState(() {
        _currentRound = round;
      });
    });
    
    // Auf Änderungen der Endzeit hören
    roundProvider.roundEndTimeStream.listen((endTime) {
      _startLocalTimer(endTime);
    });
  }

  void _startLocalTimer(DateTime endTime) {
    // Alte Timer abbrechen
    _localTimer?.cancel();
    
    // Timer-Funktion zum Aktualisieren der verbleibenden Zeit
    void updateRemainingTime() {
      final now = DateTime.now();
      if (endTime.isAfter(now)) {
        setState(() {
          _remainingSeconds = endTime.difference(now).inSeconds;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
        });
        _localTimer?.cancel();
      }
    }
    
    // Initial setzen
    updateRemainingTime();
    
    // Timer für die Aktualisierung einrichten (jede Sekunde)
    _localTimer = Timer.periodic(Duration(seconds: 1), (_) {
      updateRemainingTime();
    });
  }
  
  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    // Bestimme die Farbe basierend auf der verbleibenden Zeit
    Color timerColor;
    if (_remainingSeconds > 30) {
      timerColor = Colors.green;
    } else if (_remainingSeconds > 10) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        border: Border.all(color: foregroundColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Runde $_currentRound',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.timer,
            color: timerColor,
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
