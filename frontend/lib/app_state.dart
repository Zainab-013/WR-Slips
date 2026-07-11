import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';
import 'models/document_model.dart';
import 'repositories/auth_repository.dart';
import 'repositories/document_repository.dart';

class AppState with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final DocumentRepository _documentRepository = DocumentRepository();

  UserModel? _currentUser;
  String? _selectedZone;
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;

  bool _isSyncing = false;
  double _syncProgress = 0.0;
  String _syncStatusText = '';

  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;
  String get syncStatusText => _syncStatusText;

  bool _useRemoteApi = false;
  bool get useRemoteApi => _useRemoteApi;

  List<Map<String, dynamic>> _remoteCategories = [];
  List<Map<String, dynamic>> get remoteCategories => _remoteCategories;

  List<Map<String, dynamic>> _remoteZones = [];
  List<Map<String, dynamic>> get remoteZones => _remoteZones;

  List<DocumentModel> _remoteRecentBooks = [];
  List<DocumentModel> get remoteRecentBooks => _remoteRecentBooks;

  List<dynamic> _remoteHomeSections = [];
  List<dynamic> get remoteHomeSections => _remoteHomeSections;

  UserModel? get currentUser => _currentUser;
  String? get selectedZone => _selectedZone;
  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  String _language = 'English';
  String get language => _language;

  AuthRepository get authRepository => _authRepository;
  DocumentRepository get documentRepository => _documentRepository;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<void> setUseRemoteApi(bool value) async {
    _useRemoteApi = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_remote_api', value);
    
    _isLoading = true;
    notifyListeners();
    
    if (_useRemoteApi) {
      await loadRemoteCommonData();
    } else {
      await loadDocuments();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRemoteCommonData() async {
    _remoteCategories = await _documentRepository.getRemoteCategories();
    _remoteZones = await _documentRepository.getRemoteZones();
    
    final homeData = await _documentRepository.getRemoteHomeScreenData();
    final List<dynamic> recent = homeData['recent'] ?? [];
    _remoteRecentBooks = recent.map((item) => DocumentModel.fromJson(Map<String, dynamic>.from(item))).toList();
    _remoteHomeSections = homeData['sections'] ?? [];
    
    notifyListeners();
  }

  int? get selectedRemoteZoneId {
    if (_selectedZone == null) return null;
    try {
      final zoneMap = _remoteZones.firstWhere(
        (z) => z['name'].toString().toLowerCase() == _selectedZone!.toLowerCase(),
      );
      return zoneMap['id'] as int?;
    } catch (_) {
      try {
        final zoneMap = _remoteZones.firstWhere(
          (z) => _selectedZone!.toLowerCase().contains(z['name'].toString().toLowerCase()) ||
                 z['name'].toString().toLowerCase().contains(_selectedZone!.toLowerCase()),
        );
        return zoneMap['id'] as int?;
      } catch (_) {
        return null;
      }
    }
  }

  int? getCategoryIdByName(String categoryName) {
    try {
      final catMap = _remoteCategories.firstWhere(
        (c) => c['name'].toString().toLowerCase() == categoryName.toLowerCase(),
      );
      return catMap['id'] as int?;
    } catch (_) {
      final cleanName = categoryName.replaceAll(' ', '').replaceAll('.', '').toLowerCase();
      try {
        final catMap = _remoteCategories.firstWhere(
          (c) {
            final name = c['name'].toString().toLowerCase();
            final slug = c['slug'].toString().toLowerCase();
            return name.contains(cleanName) || 
                   cleanName.contains(name) ||
                   slug.contains(cleanName) ||
                   cleanName.contains(slug);
          }
        );
        return catMap['id'] as int?;
      } catch (_) {
        return null;
      }
    }
  }

  Future<Map<String, dynamic>> fetchRemoteBooksForCategory({
    required String categoryName,
    String? query,
    int page = 1,
  }) async {
    final catId = getCategoryIdByName(categoryName);
    final zoneId = selectedRemoteZoneId;
    
    return await _documentRepository.getRemoteBooks(
      query: query,
      categoryId: catId,
      zoneId: zoneId,
      page: page,
    );
  }

  // Initialize and check current user session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.init();
    await _documentRepository.init();

    final prefs = await SharedPreferences.getInstance();
    _useRemoteApi = prefs.getBool('use_remote_api') ?? true;

    _currentUser = await _authRepository.getCurrentUser();
    _selectedZone = await _authRepository.getSelectedZone();
    
    if (_useRemoteApi) {
      await loadRemoteCommonData();
    } else {
      if (_currentUser != null) {
        await loadDocuments();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authRepository.login(email, password);
    if (user != null) {
      _currentUser = user;
      _selectedZone = user.zone;
      await loadDocuments();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? zone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        zone: zone,
      );
      if (user != null) {
        _currentUser = user;
        _selectedZone = zone;
        await loadDocuments();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _currentUser = null;
    _selectedZone = null;
    _documents = [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectZone(String zone) async {
    _selectedZone = zone;
    await _authRepository.saveSelectedZone(zone);
    await loadDocuments();
    notifyListeners();
  }

  Future<void> loadDocuments() async {
    if (_selectedZone == null) return;
    _documents = await _documentRepository.getAllDocuments();
    notifyListeners();
  }

  List<DocumentModel> getFilteredDocuments(String category) {
    return _documents.where((d) => 
      d.category == category && 
      d.zone == _selectedZone
    ).toList();
  }

  Future<void> addDocument({
    required String title,
    required String category,
    String? pdfUrl,
    String? slipUrl,
  }) async {
    if (_selectedZone == null || _currentUser == null) return;

    final newDoc = DocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      zone: _selectedZone!,
      pdfUrl: pdfUrl,
      slipUrl: slipUrl,
      uploadedBy: _currentUser!.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _documentRepository.addDocument(newDoc);
    await loadDocuments();
  }

  Future<void> updateDocument({
    required String id,
    required String title,
    required String category,
    String? pdfUrl,
    String? slipUrl,
  }) async {
    final existingIndex = _documents.indexWhere((d) => d.id == id);
    if (existingIndex == -1) return;

    final existingDoc = _documents[existingIndex];
    final updatedDoc = existingDoc.copyWith(
      title: title,
      category: category,
      pdfUrl: pdfUrl,
      slipUrl: slipUrl,
      updatedAt: DateTime.now(),
    );

    await _documentRepository.updateDocument(updatedDoc);
    await loadDocuments();
  }

  Future<void> deleteDocument(String id) async {
    await _documentRepository.deleteDocument(id);
    await loadDocuments();
  }

  // Check if a document file is cached offline in Hive
  bool isDocumentOffline(String id, {bool isSlip = false}) {
    final box = Hive.box<Uint8List>('offline_documents');
    final key = isSlip ? '${id}_slip' : '${id}_pdf';
    return box.containsKey(key);
  }

  // Retrieve cached document bytes from Hive
  Uint8List? getOfflineBytes(String id, {bool isSlip = false}) {
    final box = Hive.box<Uint8List>('offline_documents');
    final key = isSlip ? '${id}_slip' : '${id}_pdf';
    return box.get(key);
  }

  // Clear all cached offline files in Hive
  Future<void> clearOfflineCache() async {
    final box = Hive.box<Uint8List>('offline_documents');
    await box.clear();
    notifyListeners();
  }

  // Main sync operation: downloads and caches all PDF files offline
  Future<void> syncAllDocuments() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncProgress = 0.0;
    _syncStatusText = 'Preparing documents list...';
    notifyListeners();

    try {
      List<DocumentModel> docsToSync = [];

      if (_useRemoteApi) {
        // Fetch latest categories, zones, and home screen layout from API
        await loadRemoteCommonData();

        // Fetch all pages of remote books for the selected zone
        int page = 1;
        bool hasMore = true;
        while (hasMore) {
          _syncStatusText = 'Fetching remote list (Page $page)...';
          notifyListeners();

          final result = await _documentRepository.getRemoteBooks(
            zoneId: selectedRemoteZoneId,
            page: page,
          );
          
          final List<dynamic> booksData = result['data'] ?? [];
          final List<DocumentModel> fetchedBooks = booksData
              .map((b) => DocumentModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();

          if (fetchedBooks.isEmpty) {
            hasMore = false;
          } else {
            docsToSync.addAll(fetchedBooks);
            final meta = result['meta'] ?? {};
            final lastPage = meta['last_page'] as int? ?? 1;
            if (page >= lastPage) {
              hasMore = false;
            } else {
              page++;
            }
          }
        }
      } else {
        // Local mode: load latest documents and use seeded cache
        await loadDocuments();
        docsToSync = List.from(_documents);
      }

      if (docsToSync.isEmpty) {
        _syncStatusText = 'No documents found to sync.';
        _syncProgress = 1.0;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
        return;
      }

      // Calculate total sub-tasks (PDF URL and Slip URL separately, only for API documents starting with http)
      int totalTasks = 0;
      for (final doc in docsToSync) {
        if (doc.isPdf && doc.pdfUrl!.startsWith('http')) totalTasks++;
        if (doc.isSlip && doc.slipUrl!.startsWith('http')) totalTasks++;
      }

      if (totalTasks == 0) {
        _syncStatusText = 'No API files found to download.';
        _syncProgress = 1.0;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
        return;
      }

      final box = Hive.box<Uint8List>('offline_documents');
      int completedTasks = 0;

      for (final doc in docsToSync) {
        // 1. Download PDF book if present and is from API
        if (doc.isPdf && doc.pdfUrl!.startsWith('http')) {
          final String path = doc.pdfUrl!;
          _syncStatusText = 'Syncing PDF: ${doc.title}';
          notifyListeners();

          try {
            Uint8List? bytes = await _documentRepository.downloadFileBytes(path);
            if (bytes != null) {
              await box.put('${doc.id}_pdf', bytes);
            }
          } catch (e) {
            debugPrint('Error syncing PDF for doc ${doc.id}: $e');
          }

          completedTasks++;
          _syncProgress = completedTasks / totalTasks;
          notifyListeners();
        }

        // 2. Download Correction Slip if present and is from API
        if (doc.isSlip && doc.slipUrl!.startsWith('http')) {
          final String path = doc.slipUrl!;
          _syncStatusText = 'Syncing Slip: ${doc.title}';
          notifyListeners();

          try {
            Uint8List? bytes = await _documentRepository.downloadFileBytes(path);
            if (bytes != null) {
              await box.put('${doc.id}_slip', bytes);
            }
          } catch (e) {
            debugPrint('Error syncing Slip for doc ${doc.id}: $e');
          }

          completedTasks++;
          _syncProgress = completedTasks / totalTasks;
          notifyListeners();
        }
      }

      _syncStatusText = 'Sync completed successfully!';
      _syncProgress = 1.0;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _syncStatusText = 'Sync failed: $e';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
