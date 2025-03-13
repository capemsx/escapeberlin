import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class PlayerListDialog extends StatelessWidget {
  final List<String> players;
  final String currentUsername;
  final String? selectedRecipient;
  final Function(String?) onSelectRecipient;

  const PlayerListDialog({
    Key? key,
    required this.players,
    required this.currentUsername,
    required this.selectedRecipient,
    required this.onSelectRecipient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.people, color: foregroundColor),
                SizedBox(width: 10),
                Text(
                  'Spielerliste',
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Divider(color: foregroundColor.withOpacity(0.5)),
            Text(
              selectedRecipient != null
                  ? 'Aktuelle Flüsternachricht an: $selectedRecipient'
                  : 'Wähle einen Spieler für Flüsternachrichten',
              style: TextStyle(
                color: selectedRecipient != null ? Colors.purple : foregroundColor.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
            ...players.map((player) => _buildPlayerItem(player, context)).toList(),
            if (selectedRecipient != null) ...[
              SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(Icons.cancel, size: 16),
                label: Text('Flüstern abbrechen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                ),
                onPressed: () {
                  onSelectRecipient(null);
                  Navigator.of(context).pop();
                },
              ),
            ],
            SizedBox(height: 10),
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

  Widget _buildPlayerItem(String player, BuildContext context) {
    final bool isCurrentUser = player == currentUsername;
    final bool isSelected = player == selectedRecipient;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        isCurrentUser ? Icons.person_pin : Icons.person_outline,
        color: isSelected ? Colors.purple : foregroundColor,
      ),
      title: Text(
        player,
        style: TextStyle(
          color: isCurrentUser ? foregroundColor.withOpacity(0.7) : foregroundColor,
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isCurrentUser
          ? Text(
              '(Du)',
              style: TextStyle(
                color: foregroundColor.withOpacity(0.5),
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            )
          : Icon(
              isSelected ? Icons.mark_chat_read : Icons.mark_chat_unread_outlined,
              color: isSelected ? Colors.purple : foregroundColor.withOpacity(0.5),
              size: 18,
            ),
      enabled: !isCurrentUser,
      selected: isSelected,
      onTap: isCurrentUser
          ? null
          : () {
              onSelectRecipient(isSelected ? null : player);
              Navigator.of(context).pop();
            },
    );
  }
}
