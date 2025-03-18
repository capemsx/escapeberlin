import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class InventoryDialog extends StatefulWidget {
  final String hideoutId;
  final Role playerRole;
  
  const InventoryDialog({
    Key? key, 
    required this.hideoutId,
    required this.playerRole,
  }) : super(key: key);

  @override
  State<InventoryDialog> createState() => _InventoryDialogState();
}

class _InventoryDialogState extends State<InventoryDialog> {
  List<GameDocument> _documents = [];
  
  @override
  void initState() {
    super.initState();
    _loadDocuments();
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
                Icon(Icons.inventory_2, color: foregroundColor),
                SizedBox(width: 10),
                Text(
                  'Inventar (Runde $currentRound)',
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Divider(color: foregroundColor.withOpacity(0.5)),
            if (_documents.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Keine Dokumente für diese Runde verfügbar.',
                  style: TextStyle(
                    color: foregroundColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else if (!canShare)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Du hast bereits ein Dokument in dieser Runde geteilt.',
                  style: TextStyle(
                    color: foregroundColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _documents.map((doc) => _buildDocumentItem(doc, currentRound, context)).toList(),
                ),
              ),
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
  
  Widget _buildDocumentItem(GameDocument document, int currentRound, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: foregroundColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dokument-Quelle im Header anzeigen
          /*
          Row(
            children: [
              Icon(Icons.source_outlined, size: 16, color: foregroundColor),
              SizedBox(width: 4),
              Text(
                "Quelle: ${document.roleRequirement}",
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: foregroundColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          */
          // Dokumenttitel
          Text(
            document.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
          Divider(height: 8, thickness: 1, color: foregroundColor.withOpacity(0.5)),
          
          // Dokumentinhalt
          Text(
            document.content,
            style: TextStyle(fontSize: 13, color: foregroundColor.withOpacity(0.9)),
          ),
          SizedBox(height: 8),
          
          // Teilen-Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.share, size: 16),
                label: Text('Im Chat teilen'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: backgroundColor,
                  backgroundColor: foregroundColor,
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
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Dialog schließen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dokument wurde im Chat geteilt'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dokument konnte nicht geteilt werden'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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
