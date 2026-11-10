import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    test('deve criar a partir do payload padronizado da API', () {
      final json = {
        'code': 'VALIDATION_ERROR',
        'message': 'Dados da requisição inválidos',
        'details': ['cnpj: CNPJ inválido', 'legalName: Razão social obrigatória'],
        'timestamp': '2026-11-09T10:00:00',
      };

      final exception = ApiException.fromResponse(400, json);

      expect(exception.statusCode, 400);
      expect(exception.code, 'VALIDATION_ERROR');
      expect(exception.message, 'Dados da requisição inválidos');
      expect(exception.details.length, 2);
      expect(exception.isValidationError, isTrue);
      expect(exception.isUnauthorized, isFalse);
    });

    test('deve tratar resposta sem corpo de erro', () {
      final exception = ApiException.fromResponse(500, null);

      expect(exception.statusCode, 500);
      expect(exception.code, 'HTTP_500');
      expect(exception.isServerError, isTrue);
    });

    test('deve identificar códigos de erro comuns', () {
      expect(
        const ApiException(statusCode: 401, code: 'UNAUTHORIZED', message: '').isUnauthorized,
        isTrue,
      );
      expect(
        const ApiException(statusCode: 404, code: 'NOT_FOUND', message: '').isNotFound,
        isTrue,
      );
      expect(
        const ApiException(statusCode: 409, code: 'DUPLICATE_CNPJ', message: '').isConflict,
        isTrue,
      );
      expect(
        const ApiException(statusCode: 422, code: 'INVALID_STATUS_TRANSITION', message: '').isBusinessRuleViolation,
        isTrue,
      );
    });

    test('deve tratar falha de conexão de rede', () {
      final exception = ApiException.networkError('SocketException: Connection refused');

      expect(exception.statusCode, 0);
      expect(exception.code, 'NETWORK_ERROR');
      expect(exception.details, contains('SocketException: Connection refused'));
    });
  });
}
