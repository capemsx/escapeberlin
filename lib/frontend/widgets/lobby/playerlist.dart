import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class PlayerList extends StatelessWidget {
  final List<String> players;
  
  const PlayerList({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spieler im Versteck:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...players.map((player) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: foregroundColor),
                const SizedBox(width: 8),
                Text(player),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}