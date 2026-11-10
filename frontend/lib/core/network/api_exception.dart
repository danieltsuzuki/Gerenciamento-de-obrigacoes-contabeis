class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final List<String> details;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
  });

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic>? body) {
    if (body == null) {
      return ApiException(
        statusCode: statusCode,
        code: 'HTTP_$statusCode',
        message: 'Ocorreu um erro inesperado na comunicação com o servidor.',
      );
    }

    final code = body['code'] as String? ?? 'HTTP_$statusCode';
    final message = body['message'] as String? ?? 'Erro na requisição.';
    final rawDetails = body['details'];
    final details = rawDetails is List
        ? rawDetails.map((e) => e.toString()).toList()
        : <String>[];

    return ApiException(
      statusCode: statusCode,
      code: code,
      message: message,
      details: details,
    );
  }

  factory ApiException.networkError(dynamic error) {
    return ApiException(
      statusCode: 0,
      code: 'NETWORK_ERROR',
      message: 'Não foi possível conectar ao servidor. Verifique sua conexão.',
      details: [error.toString()],
    );
  }

  bool get isValidationError => statusCode == 400 || code == 'VALIDATION_ERROR';
  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED' || code == 'BAD_CREDENTIALS';
  bool get isNotFound => statusCode == 404 || code == 'NOT_FOUND';
  bool get isConflict => statusCode == 409;
  bool get isBusinessRuleViolation => statusCode == 422;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'ApiException($statusCode, code: $code, message: $message, details: $details)';
}
