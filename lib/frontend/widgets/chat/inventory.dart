import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:flutter/material.dart';
import 'package:escapeberlin/backend/types/player.dart';
import 'package:escapeberlin/globals.dart';

class InventoryWidget extends StatefulWidget {
  final String hideoutId;
  final Role playerRole;
  
  const InventoryWidget({
    Key? key,
    required this.hideoutId,
    required this.playerRole
  }) : super(key: key);

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  List<GameDocument> _documents = [];
  final ExpansionTileController _controller = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }
  
  @override
  void didUpdateWidget(InventoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Wenn sich die Rolle oder die Runde ändert, laden wir die Dokumente neu
    if (oldWidget.playerRole != widget.playerRole) {
      _loadDocuments();
    }
  }

  void _loadDocuments() {
    final currentRound = roundProvider.getCurrentRound();
    final docs = documentProvider.getDocumentsForRoleAndRound(widget.playerRole, currentRound);
    setState(() {
      _documents = docs;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentRound = roundProvider.getCurrentRound();
    final canShare = documentProvider.canShareDocument(currentRound);
    
    return ExpansionTile(
      controller: _controller,
      title: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: foregroundColor,
          ),
          SizedBox(width: 10),
          Text(
            'Inventar',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.8),
            border: Border.all(color: foregroundColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verfügbare Dokumente (Runde $currentRound):',
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              if (_documents.isEmpty)
                Text(
                  'Keine Dokumente für diese Runde verfügbar.',
                  style: TextStyle(
                    color: foregroundColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else if (!canShare)
                Text(
                  'Du hast bereits ein Dokument in dieser Runde geteilt.',
                  style: TextStyle(
                    color: foregroundColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ..._documents.map((doc) => _buildDocumentItem(doc, currentRound)).toList(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDocumentItem(GameDocument document, int currentRound) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.amber[800]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          Divider(height: 8, thickness: 1, color: Colors.amber[300]),
          Text(
            document.content,
            style: TextStyle(fontSize: 13, color: Colors.brown[700]),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.share, size: 16),
                label: Text('Im Chat teilen'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.amber[800],
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: TextStyle(fontSize: 13),
                ),
                onPressed: () async {
                  final success = await documentProvider.shareDocument(
                    document.id,
                    widget.hideoutId,
                    currentRound,
                  );
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dokument wurde im Chat geteilt'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // Schließe das ExpansionTile nach dem erfolgreichen Senden
                    _controller.collapse();
                    setState(() {}); // Widget aktualisieren
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dokument konnte nicht geteilt werden'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}