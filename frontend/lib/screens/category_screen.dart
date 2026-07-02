import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/document_model.dart';
import '../theme.dart';
import 'pdf_viewer_screen.dart';
import 'slip_viewer_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, double> _downloadProgress = {}; // tracks progress per doc id
  final Set<String> _downloadedDocs = {}; // tracks completed downloads

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startDownload(DocumentModel doc) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _downloadProgress[doc.id] = 0.0;
    });

    await appState.documentRepository.simulateDownload(doc, (progress) {
      if (mounted) {
        setState(() {
          _downloadProgress[doc.id] = progress;
        });
      }
    });

    if (mounted) {
      setState(() {
        _downloadProgress.remove(doc.id);
        _downloadedDocs.add(doc.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${doc.title} downloaded successfully!'),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredDocs = appState.getFilteredDocuments(widget.categoryName);
    
    // Separate into PDFs and Slips
    final pdfs = filteredDocs.where((d) => d.isPdf).toList();
    final slips = filteredDocs.where((d) => d.isSlip).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondaryAmber,
          labelColor: isDark ? Colors.white : AppTheme.textLightPrimary,
          tabs: const [
            Tab(icon: Icon(Icons.picture_as_pdf_rounded), text: 'PDF Books'),
            Tab(icon: Icon(Icons.notes_rounded), text: 'Correction Slips'),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDocList(pdfs, isPdfType: true, isDark: isDark),
            _buildDocList(slips, isPdfType: false, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDocList(List<DocumentModel> docs, {required bool isPdfType, required bool isDark}) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPdfType ? Icons.menu_book_rounded : Icons.info_outline_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No items available in this category.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isDownloading = _downloadProgress.containsKey(doc.id);
        final isDownloaded = _downloadedDocs.contains(doc.id);
        final progress = _downloadProgress[doc.id] ?? 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isPdfType ? AppTheme.primaryBlue : AppTheme.secondaryAmber).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPdfType ? Icons.picture_as_pdf_rounded : Icons.notes_rounded,
                          color: isPdfType ? AppTheme.primaryBlue : AppTheme.secondaryAmber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded on ${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year} by ${doc.uploadedBy}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isDownloading) ...[
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Download button
                        OutlinedButton.icon(
                          onPressed: isDownloaded ? null : () => _startDownload(doc),
                          icon: Icon(
                            isDownloaded ? Icons.offline_pin_rounded : Icons.download_rounded,
                            size: 18,
                            color: isDownloaded ? AppTheme.accentTeal : null,
                          ),
                          label: Text(
                            isDownloaded ? 'Downloaded' : 'Download',
                            style: TextStyle(
                              color: isDownloaded ? AppTheme.accentTeal : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Read button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isPdfType) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(document: doc),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SlipViewerScreen(document: doc),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.chrome_reader_mode_rounded, size: 18),
                          label: const Text('Read'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
