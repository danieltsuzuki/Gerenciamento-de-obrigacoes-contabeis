class Responsible {
  final int id;
  final String name;
  final String email;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Responsible({
    required this.id,
    required this.name,
    required this.email,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Responsible.fromJson(Map<String, dynamic> json) {
    return Responsible(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
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
      'name': name,
      'email': email,
      'active': active,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
