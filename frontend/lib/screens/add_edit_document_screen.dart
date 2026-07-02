import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/document_model.dart';
import '../theme.dart';

class AddEditDocumentScreen extends StatefulWidget {
  final DocumentModel? document;
  final String initialCategory;

  const AddEditDocumentScreen({
    super.key,
    this.document,
    required this.initialCategory,
  });

  @override
  State<AddEditDocumentScreen> createState() => _AddEditDocumentScreenState();
}

class _AddEditDocumentScreenState extends State<AddEditDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String _selectedCategory;
  
  bool _hasPdf = false;
  bool _hasSlip = false;
  String? _pdfPath;
  String? _slipPath;
  bool _isUploadingPdf = false;
  bool _isUploadingSlip = false;

  final List<String> _categories = const [
    'GR & SR',
    'O.M',
    'A.M',
    'B.W.M',
    'U.S.R',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document?.title ?? '');
    _selectedCategory = widget.document?.category ?? widget.initialCategory;
    
    if (widget.document != null) {
      _hasPdf = widget.document!.isPdf;
      _hasSlip = widget.document!.isSlip;
      _pdfPath = widget.document!.pdfUrl;
      _slipPath = widget.document!.slipUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _simulateUpload(bool isPdf) async {
    setState(() {
      if (isPdf) {
        _isUploadingPdf = true;
      } else {
        _isUploadingSlip = true;
      }
    });

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      if (isPdf) {
        _isUploadingPdf = false;
        _hasPdf = true;
        _pdfPath = 'assets/docs/sample.pdf'; // Use local mock PDF
      } else {
        _isUploadingSlip = false;
        _hasSlip = true;
        _slipPath = 'assets/docs/sample.pdf'; // Use local mock PDF
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isPdf ? "PDF Book" : "Correction Slip"} attached successfully!'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_hasPdf && !_hasSlip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach at least a PDF Book or a Correction Slip.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    if (widget.document == null) {
      await appState.addDocument(
        title: _titleController.text,
        category: _selectedCategory,
        pdfUrl: _hasPdf ? _pdfPath : null,
        slipUrl: _hasSlip ? _slipPath : null,
      );
    } else {
      await appState.updateDocument(
        id: widget.document!.id,
        title: _titleController.text,
        category: _selectedCategory,
        pdfUrl: _hasPdf ? _pdfPath : null,
        slipUrl: _hasSlip ? _slipPath : null,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.document == null ? 'Document added!' : 'Document updated!'),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.document != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Document' : 'Add Document'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Document Title',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Attach Files',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // PDF Attach Panel
                  _buildAttachRow(
                    title: 'Attach PDF Book',
                    isAttached: _hasPdf,
                    isUploading: _isUploadingPdf,
                    onAttach: () => _simulateUpload(true),
                    onRemove: () => setState(() {
                      _hasPdf = false;
                      _pdfPath = null;
                    }),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  // Slip Attach Panel
                  _buildAttachRow(
                    title: 'Attach Correction Slip',
                    isAttached: _hasSlip,
                    isUploading: _isUploadingSlip,
                    onAttach: () => _simulateUpload(false),
                    onRemove: () => setState(() {
                      _hasSlip = false;
                      _slipPath = null;
                    }),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _handleSave,
                    child: Text(isEdit ? 'Save Changes' : 'Upload Document'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachRow({
    required String title,
    required bool isAttached,
    required bool isUploading,
    required VoidCallback onAttach,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAttached 
              ? AppTheme.accentTeal.withOpacity(0.5) 
              : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
          width: isAttached ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isAttached)
                  const Text(
                    'sample.pdf attached',
                    style: TextStyle(color: AppTheme.accentTeal, fontSize: 12),
                  )
                else
                  Text(
                    'No document attached',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (isUploading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (isAttached)
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
              onPressed: onRemove,
            )
          else
            TextButton.icon(
              onPressed: onAttach,
              icon: const Icon(Icons.attach_file_rounded, size: 18),
              label: const Text('Attach'),
            )
        ],
      ),
    );
  }
}
