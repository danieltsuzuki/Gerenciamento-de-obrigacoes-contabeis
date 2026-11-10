class CreateCompanyRequest {
  final String legalName;
  final String? tradeName;
  final String cnpj;
  final bool active;

  const CreateCompanyRequest({
    required this.legalName,
    this.tradeName,
    required this.cnpj,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'legalName': legalName,
        if (tradeName != null) 'tradeName': tradeName,
        'cnpj': cnpj,
        'active': active,
      };
}

