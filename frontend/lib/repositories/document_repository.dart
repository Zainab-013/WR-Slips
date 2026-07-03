import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class DocumentRepository {
  static const String _docsDbKey = 'documents_database_v2';

  // Seed documents
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_docsDbKey)) {
      final defaultDocs = [
        // GR & SR Main PDF Book
        DocumentModel(
          id: 'doc_1',
          title: 'General Rules & Subsidiary Rules (GR&SR) 2020 Edition',
          category: 'GR & SR',
          zone: 'Western Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 300)),
          updatedAt: DateTime.now().subtract(const Duration(days: 300)),
        ),
        // Correction Slip Index (represented by 'i')
        DocumentModel(
          id: 'slip_index',
          title: 'Correction Slip Index to GR&SR',
          category: 'GR & SR',
          zone: 'Western Railway',
          pdfUrl: null,
          slipUrl: 'assets/docs/sample.pdf',
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now().subtract(const Duration(days: 200)),
        ),
      ];

      // Dynamically generate correction slips 1 to 31 for GR & SR
      for (int i = 1; i <= 31; i++) {
        defaultDocs.add(
          DocumentModel(
            id: 'slip_$i',
            title: 'Correction Slip No. $i to GR&SR',
            category: 'GR & SR',
            zone: 'Western Railway',
            pdfUrl: null,
            slipUrl: 'assets/docs/sample.pdf',
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(Duration(days: 100 - i)),
            updatedAt: DateTime.now().subtract(Duration(days: 100 - i)),
          ),
        );
      }

      // Add O.M
      defaultDocs.addAll([
        DocumentModel(
          id: 'doc_3',
          title: 'Operating Manual (OM) Chapter 1-5',
          category: 'O.M',
          zone: 'Western Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          updatedAt: DateTime.now().subtract(const Duration(days: 180)),
        ),
        DocumentModel(
          id: 'doc_4',
          title: 'Correction Slip for Operating Manual Chapter 3',
          category: 'O.M',
          zone: 'Western Railway',
          pdfUrl: null,
          slipUrl: 'assets/docs/sample.pdf',
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        // A.M
        DocumentModel(
          id: 'doc_5',
          title: 'Accident Manual 2022',
          category: 'A.M',
          zone: 'Western Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 250)),
          updatedAt: DateTime.now().subtract(const Duration(days: 250)),
        ),
        DocumentModel(
          id: 'doc_6',
          title: 'Accident Manual Appendices',
          category: 'A.M',
          zone: 'Central Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
          updatedAt: DateTime.now().subtract(const Duration(days: 120)),
        ),
        // B.W.M
        DocumentModel(
          id: 'doc_7',
          title: 'Block Working Manual (BWM)',
          category: 'B.W.M',
          zone: 'Western Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 400)),
          updatedAt: DateTime.now().subtract(const Duration(days: 400)),
        ),
        // U.S.R
        DocumentModel(
          id: 'doc_8',
          title: 'Unified Standard Schedule of Rates (USSR)',
          category: 'U.S.R',
          zone: 'Western Railway',
          pdfUrl: 'assets/docs/sample.pdf',
          slipUrl: null,
          uploadedBy: 'Railway Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 50)),
          updatedAt: DateTime.now().subtract(const Duration(days: 50)),
        ),
      ]);

      final docsJson = defaultDocs.map((d) => d.toJson()).toList();
      await prefs.setString(_docsDbKey, jsonEncode(docsJson));
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
}
