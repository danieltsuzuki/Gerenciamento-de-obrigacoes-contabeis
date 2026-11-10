class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final bool active;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'active': active,
      };
}

