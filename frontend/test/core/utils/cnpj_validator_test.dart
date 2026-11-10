import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/utils/cnpj_validator.dart';

void main() {
  group('CnpjValidator', () {
    test('deve validar CNPJ válido formatado e não formatado', () {
      expect(CnpjValidator.isValid('33.000.167/0001-01'), isTrue);
      expect(CnpjValidator.isValid('33000167000101'), isTrue);
      expect(CnpjValidator.validate('33.000.167/0001-01'), isNull);
    });

    test('deve rejeitar CNPJ com dígitos repetidos', () {
      expect(CnpjValidator.isValid('00.000.000/0000-00'), isFalse);
      expect(CnpjValidator.isValid('11111111111111'), isFalse);
      expect(CnpjValidator.validate('00000000000000'), isNotNull);
    });

    test('deve rejeitar CNPJ com dígitos verificadores incorretos', () {
      expect(CnpjValidator.isValid('33.000.167/0001-99'), isFalse);
      expect(CnpjValidator.validate('33.000.167/0001-99'), contains('inválido'));
    });

    test('deve rejeitar CNPJ nulo, vazio ou com tamanho incorreto', () {
      expect(CnpjValidator.validate(null), contains('obrigatório'));
      expect(CnpjValidator.validate('   '), contains('obrigatório'));
      expect(CnpjValidator.validate('123'), contains('14 dígitos'));
    });

    test('deve formatar CNPJ corretamente', () {
      expect(CnpjValidator.format('33000167000101'), '33.000.167/0001-01');
    });
  });
}

