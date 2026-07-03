import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class DocumentRepository {
  static const String _docsDbKey = 'documents_database_v3';

  // Seed documents
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_docsDbKey)) {
      final defaultDocs = <DocumentModel>[];

      // Define zones to seed
      final zones = ['Western Railway', 'Central Railway', 'Northern Railway', 'Southern Railway'];

      for (final zone in zones) {
        // Seed GR & SR Main PDF Book
        defaultDocs.add(
          DocumentModel(
            id: 'doc_1_${zone.replaceAll(' ', '_')}',
            title: 'General Rules & Subsidiary Rules (GR&SR) 2020 Edition ($zone)',
            category: 'GR & SR',
            zone: zone,
            pdfUrl: 'assets/docs/sample.pdf',
            slipUrl: null,
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 300)),
            updatedAt: DateTime.now().subtract(const Duration(days: 300)),
          ),
        );

        // Correction Slip Index (represented by 'i')
        defaultDocs.add(
          DocumentModel(
            id: 'slip_index_${zone.replaceAll(' ', '_')}',
            title: 'Correction Slip Index to GR&SR ($zone)',
            category: 'GR & SR',
            zone: zone,
            pdfUrl: null,
            slipUrl: 'assets/docs/sample.pdf',
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 200)),
            updatedAt: DateTime.now().subtract(const Duration(days: 200)),
          ),
        );

        // For WR, seed full set of 31 slips. For other zones, seed 5 slips.
        final slipCount = (zone == 'Western Railway') ? 31 : 5;
        for (int i = 1; i <= slipCount; i++) {
          defaultDocs.add(
            DocumentModel(
              id: 'slip_${i}_${zone.replaceAll(' ', '_')}',
              title: 'Correction Slip No. $i to GR&SR ($zone)',
              category: 'GR & SR',
              zone: zone,
              pdfUrl: null,
              slipUrl: 'assets/docs/sample.pdf',
              uploadedBy: 'Railway Admin',
              createdAt: DateTime.now().subtract(Duration(days: 100 - i)),
              updatedAt: DateTime.now().subtract(Duration(days: 100 - i)),
            ),
          );
        }

        // Add O.M (Operating Manual)
        defaultDocs.add(
          DocumentModel(
            id: 'doc_3_${zone.replaceAll(' ', '_')}',
            title: 'Operating Manual (OM) Chapter 1-5 ($zone)',
            category: 'O.M',
            zone: zone,
            pdfUrl: 'assets/docs/sample.pdf',
            slipUrl: null,
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 180)),
            updatedAt: DateTime.now().subtract(const Duration(days: 180)),
          ),
        );

        // Add dummy slip for O.M
        defaultDocs.add(
          DocumentModel(
            id: 'doc_4_${zone.replaceAll(' ', '_')}',
            title: 'Correction Slip for Operating Manual Chapter 3 ($zone)',
            category: 'O.M',
            zone: zone,
            pdfUrl: null,
            slipUrl: 'assets/docs/sample.pdf',
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        );

        // Add A.M (Accident Manual)
        defaultDocs.add(
          DocumentModel(
            id: 'doc_5_${zone.replaceAll(' ', '_')}',
            title: 'Accident Manual 2022 ($zone)',
            category: 'A.M',
            zone: zone,
            pdfUrl: 'assets/docs/sample.pdf',
            slipUrl: null,
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 250)),
            updatedAt: DateTime.now().subtract(const Duration(days: 250)),
          ),
        );

        // Add B.W.M (Block Working Manual)
        defaultDocs.add(
          DocumentModel(
            id: 'doc_7_${zone.replaceAll(' ', '_')}',
            title: 'Block Working Manual ($zone)',
            category: 'B.W.M',
            zone: zone,
            pdfUrl: 'assets/docs/sample.pdf',
            slipUrl: null,
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 400)),
            updatedAt: DateTime.now().subtract(const Duration(days: 400)),
          ),
        );

        // Add U.S.R (Unified Standard Schedule of Rates)
        defaultDocs.add(
          DocumentModel(
            id: 'doc_8_${zone.replaceAll(' ', '_')}',
            title: 'Unified Standard Schedule of Rates ($zone)',
            category: 'U.S.R',
            zone: zone,
            pdfUrl: 'assets/docs/sample.pdf',
            slipUrl: null,
            uploadedBy: 'Railway Admin',
            createdAt: DateTime.now().subtract(const Duration(days: 50)),
            updatedAt: DateTime.now().subtract(const Duration(days: 50)),
          ),
        );
      }

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
