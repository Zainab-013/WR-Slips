import 'package:flutter/material.dart';
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
  String _slipSearchQuery = '';

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
            _buildSlipsGrid(slips, isDark: isDark),
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
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isPdfType ? AppTheme.primaryBlue : AppTheme.secondaryAmber,
                      width: 6,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isPdfType ? AppTheme.primaryBlue : AppTheme.secondaryAmber).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPdfType ? Icons.picture_as_pdf_rounded : Icons.notes_rounded,
                            color: isPdfType ? AppTheme.primaryBlue : AppTheme.secondaryAmber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
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
                        const SizedBox(width: 8),
                        _buildDownloadButton(doc, isDownloaded, isDownloading, progress),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(DocumentModel doc, bool isDownloaded, bool isDownloading, double progress) {
    if (isDownloading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      );
    }

    if (isDownloaded) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          Icons.offline_pin_rounded,
          color: AppTheme.accentTeal,
          size: 26,
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.download_rounded, color: AppTheme.primaryBlue),
      tooltip: 'Download PDF',
      onPressed: () => _startDownload(doc),
    );
  }

  Widget _buildSlipsGrid(List<DocumentModel> slips, {required bool isDark}) {
    // Filter slips based on search query
    final filteredSlips = slips.where((slip) {
      if (_slipSearchQuery.isEmpty) return true;
      final label = _getSlipLabel(slip.title);
      return label.toLowerCase().contains(_slipSearchQuery.toLowerCase()) || 
             slip.title.toLowerCase().contains(_slipSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Search Bar matching the user's sketch but polished
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search slips...',
              hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
              prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black12),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _slipSearchQuery = val.trim();
              });
            },
          ),
        ),
        Expanded(
          child: filteredSlips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No correction slips found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredSlips.length,
                  itemBuilder: (context, index) {
                    final slip = filteredSlips[index];
                    final label = _getSlipLabel(slip.title);

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                        border: Border.all(
                          color: isDark ? const Color(0xFF475569) : Colors.black87,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SlipViewerScreen(document: slip),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getSlipLabel(String title) {
    final regExp = RegExp(r'No\.\s*(\d+)');
    final match = regExp.firstMatch(title);
    if (match != null) {
      return match.group(1) ?? '';
    }
    if (title.toLowerCase().contains('index')) {
      return 'i';
    }
    return title.split(' ').last;
  }
}
