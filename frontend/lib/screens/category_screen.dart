import 'dart:async';
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
  String _slipSearchQuery = '';

  // Remote API State variables
  List<DocumentModel> _apiBooks = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isApiLoading = false;
  bool _isFetchingMore = false;
  String _searchQuery = '';
  Timer? _debounce;
  
  final ScrollController _pdfScrollController = ScrollController();
  final ScrollController _slipsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pdfScrollController.addListener(_onPdfScroll);
    _slipsScrollController.addListener(_onSlipsScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.useRemoteApi) {
        _fetchBooks(reset: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pdfScrollController.dispose();
    _slipsScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onPdfScroll() {
    if (_pdfScrollController.position.pixels >= _pdfScrollController.position.maxScrollExtent - 200) {
      _fetchMoreBooks();
    }
  }

  void _onSlipsScroll() {
    if (_slipsScrollController.position.pixels >= _slipsScrollController.position.maxScrollExtent - 200) {
      _fetchMoreBooks();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
        _fetchBooks(reset: true);
      }
    });
  }

  Future<void> _fetchBooks({bool reset = false}) async {
    if (_isApiLoading) return;
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isApiLoading = true;
      if (reset) {
        _apiBooks = [];
        _currentPage = 1;
      }
    });

    try {
      final result = await appState.fetchRemoteBooksForCategory(
        categoryName: widget.categoryName,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
      );

      final List<dynamic> booksData = result['data'] ?? [];
      final List<DocumentModel> fetchedBooks = booksData
          .map((b) => DocumentModel.fromJson(Map<String, dynamic>.from(b)))
          .toList();

      final meta = result['meta'] ?? {};
      final lastPageVal = meta['last_page'] as int? ?? 1;

      if (mounted) {
        setState(() {
          if (reset) {
            _apiBooks = fetchedBooks;
          } else {
            _apiBooks.addAll(fetchedBooks);
          }
          _lastPage = lastPageVal;
        });
      }
    } catch (e) {
      debugPrint('Error fetching books in screen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isApiLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMoreBooks() async {
    if (_isApiLoading || _isFetchingMore || _currentPage >= _lastPage) return;
    
    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final result = await appState.fetchRemoteBooksForCategory(
        categoryName: widget.categoryName,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
      );

      final List<dynamic> booksData = result['data'] ?? [];
      final List<DocumentModel> fetchedBooks = booksData
          .map((b) => DocumentModel.fromJson(Map<String, dynamic>.from(b)))
          .toList();

      if (mounted) {
        setState(() {
          _apiBooks.addAll(fetchedBooks);
        });
      }
    } catch (e) {
      debugPrint('Error fetching more books: $e');
      _currentPage--; // roll back
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredDocs = appState.getFilteredDocuments(widget.categoryName);
    final displayDocs = appState.useRemoteApi ? _apiBooks : filteredDocs;
    
    // Separate into PDFs and Slips
    final pdfs = displayDocs.where((d) => d.isPdf).toList();
    final slips = displayDocs.where((d) => d.isSlip).toList();

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
    if (_isApiLoading && docs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
      controller: isPdfType ? _pdfScrollController : null,
      padding: const EdgeInsets.all(16),
      itemCount: docs.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == docs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final doc = docs[index];

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
                          child: Text(
                            doc.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
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

  Widget _buildSlipsGrid(List<DocumentModel> slips, {required bool isDark}) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Filter slips locally ONLY in local cache mode. 
    // In API mode, filtering is handled server-side via search query.
    final filteredSlips = appState.useRemoteApi
        ? slips
        : slips.where((slip) {
            if (_slipSearchQuery.isEmpty) return true;
            final label = _getSlipLabel(slip.title);
            return label.toLowerCase().contains(_slipSearchQuery.toLowerCase()) || 
                   slip.title.toLowerCase().contains(_slipSearchQuery.toLowerCase());
          }).toList();

    if (_isApiLoading && filteredSlips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
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
              if (appState.useRemoteApi) {
                _onSearchChanged(val.trim());
              } else {
                setState(() {
                  _slipSearchQuery = val.trim();
                });
              }
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
                  controller: _slipsScrollController,
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
                               color: isDark ? Colors.white : AppTheme.textLightPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_isFetchingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
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
