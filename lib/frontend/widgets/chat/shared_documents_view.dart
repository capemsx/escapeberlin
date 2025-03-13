import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class SharedDocumentsView extends StatelessWidget {
  final int currentRound;

  const SharedDocumentsView({
    Key? key,
    required this.currentRound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GameDocument>>(
      stream: documentProvider.streamSharedDocumentsForRound(currentRound),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: foregroundColor),
          );
        }

        final documents = snapshot.data ?? [];
        
        if (documents.isEmpty) {
          return Center(
            child: Text(
              "Keine Dokumente geteilt",
              style: TextStyle(
                color: foregroundColor.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        // Scrollbare Liste für geteilte Dokumente, um Overflow zu verhindern
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(
                "Geteilte Dokumente:",
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return _buildDocumentCard(documents[index], context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentCard(GameDocument document, BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.5),
        border: Border.all(color: foregroundColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 14, color: foregroundColor),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  document.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(height: 8, color: foregroundColor.withOpacity(0.3)),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                document.content,
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Text(
            "Quelle: ${document.roleRequirement}",
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: foregroundColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}