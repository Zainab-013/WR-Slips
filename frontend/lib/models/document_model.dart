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

  // New API fields
  final String? slug;
  final String? description;
  final int? year;
  final int? pages;
  final List<String> tags;
  final int? views;
  final String? viewsShort;
  final int? downloads;
  final int? fileSize;
  final String? fileSizeHuman;
  final String? coverUrl;
  final String? downloadUrl;
  final String? webUrl;
  final String? addedHuman;

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
    this.slug,
    this.description,
    this.year,
    this.pages,
    this.tags = const [],
    this.views,
    this.viewsShort,
    this.downloads,
    this.fileSize,
    this.fileSizeHuman,
    this.coverUrl,
    this.downloadUrl,
    this.webUrl,
    this.addedHuman,
  });

  bool get isPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get isSlip => slipUrl != null && slipUrl!.isNotEmpty;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    // Handle category name parsing (can be String or Map)
    String catVal = '';
    if (json['category'] is Map) {
      catVal = (json['category'] as Map)['name']?.toString() ?? '';
    } else if (json['category'] is String) {
      catVal = json['category'] as String;
    }

    // Handle zone name parsing (can be String or Map)
    String zoneVal = '';
    if (json['zone'] is Map) {
      zoneVal = (json['zone'] as Map)['name']?.toString() ?? '';
    } else if (json['zone'] is String) {
      zoneVal = json['zone'] as String;
    }

    // Parse id safely (could be int from API or String from local)
    final idVal = json['id']?.toString() ?? '';

    // Handle pdf_url / file_url mapping
    final String? pdfUrlVal = json['file_url'] as String? ?? json['pdf_url'] as String?;
    
    // In API, if the category or title indicates a slip, we can map file_url to slipUrl or pdfUrl.
    String? slipUrlVal = json['slip_url'] as String?;
    if (slipUrlVal == null && pdfUrlVal != null) {
      final String lowerTitle = (json['title'] as String? ?? '').toLowerCase();
      final String lowerCat = catVal.toLowerCase();
      if (lowerTitle.contains('slip') || lowerCat.contains('slip')) {
        slipUrlVal = pdfUrlVal;
      }
    }

    return DocumentModel(
      id: idVal,
      title: json['title'] as String? ?? '',
      category: catVal,
      zone: zoneVal,
      pdfUrl: pdfUrlVal,
      slipUrl: slipUrlVal,
      uploadedBy: json['uploaded_by'] as String? ?? 'System',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now() 
          : DateTime.now(),
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      year: json['year'] as int?,
      pages: json['pages'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : const [],
      views: json['views'] as int?,
      viewsShort: json['views_short'] as String?,
      downloads: json['downloads'] as int?,
      fileSize: json['file_size'] as int?,
      fileSizeHuman: json['file_size_human'] as String?,
      coverUrl: json['cover_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      webUrl: json['web_url'] as String?,
      addedHuman: json['added_human'] as String?,
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
      'slug': slug,
      'description': description,
      'year': year,
      'pages': pages,
      'tags': tags,
      'views': views,
      'views_short': viewsShort,
      'downloads': downloads,
      'file_size': fileSize,
      'file_size_human': fileSizeHuman,
      'cover_url': coverUrl,
      'download_url': downloadUrl,
      'web_url': webUrl,
      'added_human': addedHuman,
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
    String? slug,
    String? description,
    int? year,
    int? pages,
    List<String>? tags,
    int? views,
    String? viewsShort,
    int? downloads,
    int? fileSize,
    String? fileSizeHuman,
    String? coverUrl,
    String? downloadUrl,
    String? webUrl,
    String? addedHuman,
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
      slug: slug ?? this.slug,
      description: description ?? this.description,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      viewsShort: viewsShort ?? this.viewsShort,
      downloads: downloads ?? this.downloads,
      fileSize: fileSize ?? this.fileSize,
      fileSizeHuman: fileSizeHuman ?? this.fileSizeHuman,
      coverUrl: coverUrl ?? this.coverUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      webUrl: webUrl ?? this.webUrl,
      addedHuman: addedHuman ?? this.addedHuman,
    );
  }
}
