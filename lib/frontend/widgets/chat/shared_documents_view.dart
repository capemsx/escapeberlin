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
        // Ladeindikator nur anzeigen, wenn keine Daten vorhanden sind
        // und die Verbindung noch aufgebaut wird
        if (snapshot.connectionState == ConnectionState.waiting && 
            !snapshot.hasData) {
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
                  return _buildDocumentCard(documents[index], context, documents, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentCard(GameDocument document, BuildContext context, List<GameDocument> allDocuments, int currentIndex) {
    return InkWell(
      onTap: () {
        _showDocumentDialog(context, document, allDocuments, currentIndex);
      },
      child: Container(
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
            Divider(height: 4, color: foregroundColor.withOpacity(0.3)),
            Expanded(
              child: Text(
                document.content,
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.8),
                  fontSize: 11,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "Quelle: ${document.sharedBy}",
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: foregroundColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, GameDocument document, List<GameDocument> allDocuments, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(
        documents: allDocuments,
        initialIndex: initialIndex,
      ),
    );
  }
}

class DocumentViewerDialog extends StatefulWidget {
  final List<GameDocument> documents;
  final int initialIndex;

  const DocumentViewerDialog({
    Key? key,
    required this.documents,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _DocumentViewerDialogState createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: foregroundColor, width: 1),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titel und Navigation
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: foregroundColor),
                  onPressed: _currentIndex > 0 
                      ? () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } 
                      : null,
                ),
                Expanded(
                  child: Text(
                    "Dokument ${_currentIndex + 1} von ${widget.documents.length}",
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: foregroundColor),
                  onPressed: _currentIndex < widget.documents.length - 1 
                      ? () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } 
                      : null,
                ),
              ],
            ),
            Divider(color: foregroundColor.withOpacity(0.5)),
            // Dokumente als PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.documents.length,
                itemBuilder: (context, index) {
                  final document = widget.documents[index];
                  return _buildFullDocumentView(document);
                },
              ),
            ),
            // Schließen-Button
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

  Widget _buildFullDocumentView(GameDocument document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dokumenttitel
        Text(
          document.title,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        // Quelle
        Text(
          "Quelle: ${document.sharedBy}",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: foregroundColor.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 12),
        Divider(color: foregroundColor.withOpacity(0.3)),
        // Vollständiger Inhalt mit Scrollmöglichkeit
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                document.content,
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}