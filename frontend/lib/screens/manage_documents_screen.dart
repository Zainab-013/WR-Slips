import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/document_model.dart';
import '../theme.dart';
import 'add_edit_document_screen.dart';

class ManageDocumentsScreen extends StatelessWidget {
  final String categoryName;

  const ManageDocumentsScreen({
    super.key,
    required this.categoryName,
  });

  void _confirmDelete(BuildContext context, AppState appState, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await appState.deleteDocument(doc.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document deleted successfully!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final documents = appState.getFilteredDocuments(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage $categoryName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditDocumentScreen(
                    initialCategory: categoryName,
                  ),
                ),
              );
            },
          ),
        ],
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Zone context: ${appState.selectedZone}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                  ),
                ),
              ),
              Expanded(
                child: documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No documents uploaded for this section yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditDocumentScreen(
                                      initialCategory: categoryName,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add First Document'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: (doc.isPdf ? AppTheme.primaryBlue : AppTheme.secondaryAmber).withOpacity(0.1),
                                  child: Icon(
                                    doc.isPdf ? Icons.picture_as_pdf_rounded : Icons.notes_rounded,
                                    color: doc.isPdf ? AppTheme.primaryBlue : AppTheme.secondaryAmber,
                                  ),
                                ),
                                title: Text(
                                  doc.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Types: ${doc.isPdf ? "PDF Book" : ""}${doc.isPdf && doc.isSlip ? " & " : ""}${doc.isSlip ? "Correction Slip" : ""}'),
                                    Text('Last updated: ${doc.updatedAt.day}/${doc.updatedAt.month}/${doc.updatedAt.year}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AddEditDocumentScreen(
                                              document: doc,
                                              initialCategory: categoryName,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () => _confirmDelete(context, appState, doc),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
