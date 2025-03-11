import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';
import 'package:escapeberlin/backend/providers/documentprovider.dart';
import 'package:escapeberlin/backend/types/document.dart';

class SharedDocumentsView extends StatefulWidget {
  final int currentRound;
  
  const SharedDocumentsView({
    Key? key, 
    required this.currentRound,
  }) : super(key: key);

  @override
  State<SharedDocumentsView> createState() => _SharedDocumentsViewState();
}

class _SharedDocumentsViewState extends State<SharedDocumentsView> {
  // Set zur Speicherung der geöffneten Dokument-IDs
  final Set<String> _expandedDocumentIds = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GameDocument>>(
      // Hier verbinden wir uns mit dem Firestore-Stream für geteilte Dokumente
      stream: documentProvider.streamSharedDocumentsForRound(widget.currentRound),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: foregroundColor));
        }
        
        final sharedDocuments = snapshot.data ?? [];
        
        if (sharedDocuments.isEmpty) {
          return Center(
            child: Text(
              'In dieser Runde wurden noch keine Dokumente geteilt.',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 14,
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: foregroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                'Geteilte Dokumente (Runde ${widget.currentRound})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: backgroundColor,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.8),
                  border: Border.all(color: foregroundColor),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  itemCount: sharedDocuments.length,
                  itemBuilder: (context, index) {
                    final document = sharedDocuments[index];
                    return DocumentCard(
                      document: document,
                      isExpanded: _expandedDocumentIds.contains(document.id),
                      onExpansionChanged: (isExpanded) {
                        setState(() {
                          if (isExpanded) {
                            _expandedDocumentIds.add(document.id);
                          } else {
                            _expandedDocumentIds.remove(document.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DocumentCard extends StatelessWidget {
  final GameDocument document;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;
  
  const DocumentCard({
    Key? key, 
    required this.document,
    required this.isExpanded,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: backgroundColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: foregroundColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              Icons.description_outlined, 
              size: 16, 
              color: foregroundColor,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                document.title,
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Tippen zum Lesen',
          style: TextStyle(
            fontSize: 12,
            color: foregroundColor.withOpacity(0.7),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: foregroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                document.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: foregroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}