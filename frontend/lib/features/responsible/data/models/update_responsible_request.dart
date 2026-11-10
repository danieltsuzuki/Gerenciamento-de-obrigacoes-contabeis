class UpdateResponsibleRequest {
  final String name;
  final String email;
  final bool active;

  const UpdateResponsibleRequest({
    required this.name,
    required this.email,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'active': active,
      };
}

