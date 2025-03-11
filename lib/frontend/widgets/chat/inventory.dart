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
    required this.playerRole,
  }) : super(key: key);

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  
  @override
  void initState() {
    super.initState();
    documentProvider.initializeDocuments();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentRound = roundProvider.getCurrentRound();
    final documents = documentProvider.getDocumentsForRole(widget.playerRole);
    final canShare = documentProvider.canShareDocument(currentRound);
    
    return ExpansionTile(
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
                'Verfügbare Dokumente:',
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              if (canShare)
                ...documents.map((doc) => _buildDocumentItem(doc, currentRound))
              else
                Text(
                  'Du hast bereits ein Dokument in dieser Runde geteilt.',
                  style: TextStyle(
                    color: foregroundColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDocumentItem(String documentId, int currentRound) {
    return ListTile(
      title: Text(
        documentId,
        style: TextStyle(color: foregroundColor),
      ),
      trailing: IconButton(
        icon: Icon(Icons.share, color: foregroundColor),
        onPressed: () async {
          // Dokument teilen
          final success = await documentProvider.shareDocument(
            documentId,
            widget.hideoutId,
            currentRound,
          );
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dokument wurde im Chat geteilt'),
                backgroundColor: foregroundColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dokument konnte nicht geteilt werden'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          
          // Widget aktualisieren
          setState(() {});
        },
      ),
    );
  }
}