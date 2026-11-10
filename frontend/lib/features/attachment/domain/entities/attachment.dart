class Attachment {
  final int id;
  final int obligationId;
  final String name;
  final String contentType;
  final int size;
  final DateTime uploadedAt;

  const Attachment({
    required this.id,
    required this.obligationId,
    required this.name,
    required this.contentType,
    required this.size,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: (json['id'] as num).toInt(),
      obligationId: (json['obligationId'] as num).toInt(),
      name: json['name'] as String,
      contentType: json['contentType'] as String? ?? 'application/octet-stream',
      size: (json['size'] as num?)?.toInt() ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'obligationId': obligationId,
        'name': name,
        'contentType': contentType,
        'size': size,
        'uploadedAt': uploadedAt.toIso8601String(),
      };
}

