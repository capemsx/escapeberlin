import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';

class RoundNotification extends StatelessWidget {
  final int roundNumber;
  
  const RoundNotification({
    Key? key,
    required this.roundNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: foregroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update,
            color: foregroundColor,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            'Runde $roundNumber beginnt',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
