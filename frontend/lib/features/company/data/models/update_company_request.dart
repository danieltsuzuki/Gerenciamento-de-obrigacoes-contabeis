class UpdateCompanyRequest {
  final String legalName;
  final String? tradeName;
  final String cnpj;
  final bool active;

  const UpdateCompanyRequest({
    required this.legalName,
    this.tradeName,
    required this.cnpj,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
        'legalName': legalName,
        if (tradeName != null) 'tradeName': tradeName,
        'cnpj': cnpj,
        'active': active,
      };
}

