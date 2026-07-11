import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/document_model.dart';
import '../app_state.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _incrementViewsIfNeeded();
      
      final appState = Provider.of<AppState>(context, listen: false);
      final offlineBytes = appState.getOfflineBytes(widget.document.id, isSlip: false);
      final String rawPath = widget.document.pdfUrl ?? '';
      final String pdfPath = rawPath.isNotEmpty
          ? rawPath
          : (!appState.useRemoteApi ? 'assets/docs/sample.pdf' : '');
      
      if (pdfPath.isEmpty && offlineBytes == null) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _incrementViewsIfNeeded() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.useRemoteApi && widget.document.slug != null) {
      await appState.documentRepository.getRemoteBookDetail(widget.document.slug!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final offlineBytes = appState.getOfflineBytes(widget.document.id, isSlip: false);

    // Fallback path is allowed only in local cache mode (when useRemoteApi is false)
    final String rawPath = widget.document.pdfUrl ?? '';
    final String pdfPath = rawPath.isNotEmpty
        ? rawPath
        : (!appState.useRemoteApi ? 'assets/docs/sample.pdf' : '');

    final isAsset = !pdfPath.startsWith('http');
    final isPathEmpty = pdfPath.isEmpty;

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
          isPathEmpty && offlineBytes == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'This rules manual is not available on the server.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : offlineBytes != null
                  ? SfPdfViewer.memory(
                      offlineBytes,
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
                            content: Text('Failed to load cached PDF: ${details.error}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                    )
                  : isAsset
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
          if (_isLoading && !isPathEmpty)
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
