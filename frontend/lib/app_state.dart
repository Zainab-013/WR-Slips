import 'package:flutter/material.dart';
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

  // Initialize and check current user session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.init();
    await _documentRepository.init();

    _currentUser = await _authRepository.getCurrentUser();
    _selectedZone = await _authRepository.getSelectedZone();
    
    if (_currentUser != null) {
      await loadDocuments();
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
}
