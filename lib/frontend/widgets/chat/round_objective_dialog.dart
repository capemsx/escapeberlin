import 'package:escapeberlin/backend/types/roundobjective.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class RoundObjectiveDialog extends StatelessWidget {
  final int currentRound;
  final RoundObjective? objective;
  final int remainingSeconds;

  const RoundObjectiveDialog({
    Key? key,
    required this.currentRound,
    required this.objective,
    required this.remainingSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Timer-Farbe basierend auf verbleibender Zeit
    Color timerColor = remainingSeconds > 30 
      ? Colors.green 
      : (remainingSeconds > 10 ? Colors.orange : Colors.red);
    
    // Formatierte Zeit
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: backgroundColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: foregroundColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Runde $currentRound",
                    style: TextStyle(
                      color: backgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                // Timer anzeigen
                Row(
                  children: [
                    Icon(Icons.timer, color: timerColor, size: 18),
                    SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            if (objective != null) ...[
              Text(
                objective!.title,
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                objective!.description,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              Text(
                "Kein Ziel für diese Runde definiert",
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Schließen', 
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
