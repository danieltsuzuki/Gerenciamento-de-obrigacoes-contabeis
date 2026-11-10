class CnpjValidator {
  CnpjValidator._();

  /// Remove caracteres de pontuação e retorna apenas os dígitos.
  static String strip(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'\D'), '');
  }

  /// Formata uma string de 14 dígitos no padrão XX.XXX.XXX/XXXX-XX.
  static String format(String? raw) {
    final digits = strip(raw);
    if (digits.length != 14) return raw ?? '';
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12, 14)}';
  }

  /// Valida se o CNPJ é estruturalmente válido e cumpre os dois dígitos verificadores (RN-001).
  static bool isValid(String? raw) {
    final digits = strip(raw);
    if (digits.length != 14) return false;

    // Rejeita sequências de dígitos repetidos
    if (RegExp(r'^(\d)\1{13}$').hasMatch(digits)) return false;

    // Cálculo do primeiro dígito verificador
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var sum1 = 0;
    for (var i = 0; i < 12; i++) {
      sum1 += int.parse(digits[i]) * weights1[i];
    }
    final remainder1 = sum1 % 11;
    final dv1 = remainder1 < 2 ? 0 : 11 - remainder1;
    if (dv1 != int.parse(digits[12])) return false;

    // Cálculo do segundo dígito verificador
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var sum2 = 0;
    for (var i = 0; i < 13; i++) {
      sum2 += int.parse(digits[i]) * weights2[i];
    }
    final remainder2 = sum2 % 11;
    final dv2 = remainder2 < 2 ? 0 : 11 - remainder2;
    return dv2 == int.parse(digits[13]);
  }

  /// Validador para uso direto em FormField / TextFormField.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O CNPJ é obrigatório.';
    }
    final digits = strip(value);
    if (digits.length != 14) {
      return 'O CNPJ deve conter exatamente 14 dígitos numéricos.';
    }
    if (!isValid(value)) {
      return 'CNPJ inválido (dígitos verificadores incorretos).';
    }
    return null;
  }
}

