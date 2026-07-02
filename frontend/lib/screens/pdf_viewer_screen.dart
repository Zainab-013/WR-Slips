import 'package:flutter/material';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/document_model.dart';
import '../theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final DocumentModel document;

  const PdfViewerScreen({
    super.key,
    required this.document,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  int _pageCount = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback path in case pdfUrl is null or empty
    final String pdfPath = (widget.document.pdfUrl != null && widget.document.pdfUrl!.isNotEmpty) 
        ? widget.document.pdfUrl! 
        : 'assets/docs/sample.pdf';

    final isAsset = !pdfPath.startsWith('http');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            onPressed: () {
              _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            onPressed: () {
              _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isAsset
              ? SfPdfViewer.asset(
                  pdfPath,
                  controller: _pdfViewerController,
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    setState(() {
                      _isLoading = false;
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (PdfPageChangedDetails details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load PDF: ${details.error}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                )
              : SfPdfViewer.network(
                  pdfPath,
                  controller: _pdfViewerController,
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    setState(() {
                      _isLoading = false;
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (PdfPageChangedDetails details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load network PDF: ${details.error}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: _pageCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $_currentPage of $_pageCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _currentPage > 1
                            ? () => _pdfViewerController.previousPage()
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _currentPage < _pageCount
                            ? () => _pdfViewerController.nextPage()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
