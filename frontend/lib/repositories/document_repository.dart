import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/document_model.dart';

class DocumentRepository {
  static const String _docsDbKey = 'documents_database_api_only';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://study.mycbt.in/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Fetch all zones from remote API
  Future<List<Map<String, dynamic>>> getRemoteZones() async {
    try {
      final response = await _dio.get('/zones');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote zones: $e');
    }
    return [];
  }

  // Fetch all categories from remote API
  Future<List<Map<String, dynamic>>> getRemoteCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching remote categories: $e');
    }
    return [];
  }

  // Fetch remote home screen data
  Future<Map<String, dynamic>> getRemoteHomeScreenData() async {
    try {
      final response = await _dio.get('/home');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching remote home data: $e');
    }
    return {'recent': [], 'sections': []};
  }

  // Fetch books paginated
  Future<Map<String, dynamic>> getRemoteBooks({
    String? query,
    int? categoryId,
    int? zoneId,
    int page = 1,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
      };
      if (query != null && query.isNotEmpty) {
        queryParameters['q'] = query;
      }
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      if (zoneId != null) {
        queryParameters['zone_id'] = zoneId;
      }

      final response = await _dio.get('/books', queryParameters: queryParameters);
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching remote books: $e');
    }
    return {'data': [], 'meta': {'current_page': 1, 'last_page': 1}};
  }

  // Live autocomplete / search as you type
  Future<List<DocumentModel>> searchRemoteBooks(String query, {int limit = 15}) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get('/books/search', queryParameters: {
        'q': query,
        'limit': limit,
      });
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('Error searching remote books: $e');
    }
    return [];
  }

  // View book details & increment counter
  Future<DocumentModel?> getRemoteBookDetail(String slug) async {
    try {
      final response = await _dio.get('/books/$slug');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return DocumentModel.fromJson(Map<String, dynamic>.from(response.data['data']));
      }
    } catch (e) {
      debugPrint('Error fetching remote book details for $slug: $e');
    }
    return null;
  }

  // Seed documents (disabled - only API documents are used)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_docsDbKey)) {
      final defaultDocs = <DocumentModel>[];
      final docsJson = defaultDocs.map((d) => d.toJson()).toList();
      await prefs.setString(_docsDbKey, jsonEncode(docsJson));
    }
  }
  }

  Future<List<DocumentModel>> getAllDocuments() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final docsStr = prefs.getString(_docsDbKey);
    if (docsStr == null) return [];
    final List<dynamic> decoded = jsonDecode(docsStr);
    return decoded.map((item) => DocumentModel.fromJson(item)).toList();
  }

  Future<List<DocumentModel>> getDocumentsByCategoryAndZone(String category, String zone) async {
    final docs = await getAllDocuments();
    return docs.where((d) => d.category == category && d.zone == zone).toList();
  }

  Future<void> addDocument(DocumentModel doc) async {
    final docs = await getAllDocuments();
    docs.add(doc);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsDbKey, jsonEncode(docs.map((d) => d.toJson()).toList()));
  }

  Future<void> updateDocument(DocumentModel updatedDoc) async {
    final docs = await getAllDocuments();
    final index = docs.indexWhere((d) => d.id == updatedDoc.id);
    if (index != -1) {
      docs[index] = updatedDoc;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_docsDbKey, jsonEncode(docs.map((d) => d.toJson()).toList()));
    }
  }

  Future<void> deleteDocument(String id) async {
    final docs = await getAllDocuments();
    docs.removeWhere((d) => d.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsDbKey, jsonEncode(docs.map((d) => d.toJson()).toList()));
  }

  // Simulate download delay
  Future<bool> simulateDownload(DocumentModel doc, Function(double progress) onProgress) async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(i * 0.1);
    }
    return true;
  }

  // Download file as Uint8List bytes from network
  Future<Uint8List?> downloadFileBytes(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
      debugPrint('Error downloading file bytes from $url: $e');
    }
    return null;
  }
}
