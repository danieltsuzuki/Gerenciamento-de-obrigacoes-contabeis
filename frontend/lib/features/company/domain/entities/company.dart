class Company {
  final int id;
  final String legalName;
  final String? tradeName;
  final String cnpj;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Company({
    required this.id,
    required this.legalName,
    this.tradeName,
    required this.cnpj,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      legalName: json['legalName'] as String,
      tradeName: json['tradeName'] as String?,
      cnpj: json['cnpj'] as String,
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legalName': legalName,
      if (tradeName != null) 'tradeName': tradeName,
      'cnpj': cnpj,
      'active': active,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get displayName => (tradeName != null && tradeName!.isNotEmpty)
      ? tradeName!
      : legalName;
}
