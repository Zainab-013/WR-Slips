class DocumentModel {
  final String id;
  final String title;
  final String category; // 'GR & SR', 'O.M', 'A.M', 'B.W.M', 'U.S.R'
  final String zone; // e.g., 'Western Railway', 'Central Railway'
  final String? pdfUrl; // Path or URL to the main PDF
  final String? slipUrl; // Path or URL to the correction slip
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.zone,
    this.pdfUrl,
    this.slipUrl,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get isSlip => slipUrl != null && slipUrl!.isNotEmpty;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      zone: json['zone'] as String,
      pdfUrl: json['pdf_url'] as String?,
      slipUrl: json['slip_url'] as String?,
      uploadedBy: json['uploaded_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'zone': zone,
      'pdf_url': pdfUrl,
      'slip_url': slipUrl,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? category,
    String? zone,
    String? pdfUrl,
    String? slipUrl,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      zone: zone ?? this.zone,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      slipUrl: slipUrl ?? this.slipUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
