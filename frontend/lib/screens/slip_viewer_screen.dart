import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/document_model.dart';
import '../theme.dart';
import '../app_state.dart';

class SlipViewerScreen extends StatefulWidget {
  final DocumentModel document;

  const SlipViewerScreen({
    super.key,
    required this.document,
  });

  @override
  State<SlipViewerScreen> createState() => _SlipViewerScreenState();
}

class _SlipViewerScreenState extends State<SlipViewerScreen> {
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
      final offlineBytes = appState.getOfflineBytes(widget.document.id, isSlip: true);
      final String rawPath = widget.document.slipUrl ?? '';
      final String slipPath = rawPath.isNotEmpty
          ? rawPath
          : (!appState.useRemoteApi ? 'assets/docs/sample.pdf' : '');

      if (slipPath.isEmpty && offlineBytes == null) {
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
    final offlineBytes = appState.getOfflineBytes(widget.document.id, isSlip: true);

    // Fallback path is allowed only in local cache mode (when useRemoteApi is false)
    final String rawPath = widget.document.slipUrl ?? '';
    final String slipPath = rawPath.isNotEmpty
        ? rawPath
        : (!appState.useRemoteApi ? 'assets/docs/sample.pdf' : '');

    final isAsset = !slipPath.startsWith('http');
    final isPathEmpty = slipPath.isEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Correction Slip Viewer'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [AppTheme.bgDark, const Color(0xFF1E293B)] 
                : [Colors.white, const Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Slip Summary Banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: AppTheme.secondaryAmber.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.secondaryAmber, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.secondaryAmber, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.document.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${widget.document.category} | Zone: ${widget.document.zone}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // PDF Viewer Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                    ),
                  ),
                  child: Stack(
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
                                      'This correction slip is not available on the server.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                )
                              : isAsset
                                  ? SfPdfViewer.asset(
                                      slipPath,
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
                                    )
                                  : SfPdfViewer.network(
                                      slipPath,
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
                                    ),
                      if (_isLoading && !isPathEmpty)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
            // Page controller
            if (_pageCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Slip Page $_currentPage of $_pageCount',
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
              ),
          ],
        ),
      ),
    );
  }
}
