class CnpjValidator {
  CnpjValidator._();

  /// Remove caracteres de pontuação e formatação, retornando caracteres alfanuméricos em maiúsculas (SPEC-041).
  static String strip(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '').toUpperCase();
  }

  /// Formata uma string de 14 caracteres alfanuméricos no padrão XX.XXX.XXX/XXXX-XX.
  static String format(String? raw) {
    final digits = strip(raw);
    if (digits.length != 14) return raw ?? '';
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12, 14)}';
  }

  /// Valida se o CNPJ é estruturalmente válido e cumpre os dois dígitos verificadores (RN-001 & SPEC-041).
  /// Suporta tanto o padrão numérico tradicional de 14 dígitos quanto o novo formato alfanumérico da Receita Federal.
  static bool isValid(String? raw) {
    final digits = strip(raw);
    if (digits.length != 14) return false;

    // As primeiras 12 posições são alfanuméricas (0-9, A-Z) e as 2 últimas são os DVs numéricos (0-9)
    if (!RegExp(r'^[0-9A-Z]{12}[0-9]{2}$').hasMatch(digits)) {
      return false;
    }

    // Rejeita sequências de caracteres idênticos repetidos
    if (RegExp(r'^(.)\1{13}$').hasMatch(digits)) return false;

    // Cálculo do primeiro dígito verificador
    // Regra RFB: char - 48 (onde '0'..='9' -> 0..9 e 'A'..='Z' -> 17..42)
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var sum1 = 0;
    for (var i = 0; i < 12; i++) {
      final val = digits.codeUnitAt(i) - 48;
      sum1 += val * weights1[i];
    }
    final remainder1 = sum1 % 11;
    final dv1 = remainder1 < 2 ? 0 : 11 - remainder1;
    if (dv1 != (digits.codeUnitAt(12) - 48)) return false;

    // Cálculo do segundo dígito verificador
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var sum2 = 0;
    for (var i = 0; i < 13; i++) {
      final val = digits.codeUnitAt(i) - 48;
      sum2 += val * weights2[i];
    }
    final remainder2 = sum2 % 11;
    final dv2 = remainder2 < 2 ? 0 : 11 - remainder2;
    return dv2 == (digits.codeUnitAt(13) - 48);
  }

  /// Validador para uso direto em FormField / TextFormField.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O CNPJ é obrigatório.';
    }
    final stripped = strip(value);
    if (stripped.length != 14) {
      return 'O CNPJ deve conter exatamente 14 caracteres.';
    }
    if (!isValid(value)) {
      return 'CNPJ inválido (dígitos verificadores incorretos).';
    }
    return null;
  }
}
