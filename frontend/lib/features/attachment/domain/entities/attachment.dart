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
      id: json['id'] as int,
      obligationId: json['obligationId'] as int,
      name: json['name'] as String,
      contentType: json['contentType'] as String? ?? 'application/octet-stream',
      size: json['size'] as int? ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
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

