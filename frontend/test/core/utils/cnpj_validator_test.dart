import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/utils/cnpj_validator.dart';

void main() {
  group('CnpjValidator', () {
    test('deve validar CNPJ válido formatado e não formatado (numérico e alfanumérico)', () {
      expect(CnpjValidator.isValid('33.000.167/0001-01'), isTrue);
      expect(CnpjValidator.isValid('33000167000101'), isTrue);
      expect(CnpjValidator.validate('33.000.167/0001-01'), isNull);

      // CNPJ Alfanumérico da Receita Federal (SPEC-041)
      expect(CnpjValidator.isValid('12ABC34501DE35'), isTrue);
      expect(CnpjValidator.isValid('12.ABC.345/01DE-35'), isTrue);
      expect(CnpjValidator.validate('12.ABC.345/01DE-35'), isNull);

      expect(CnpjValidator.isValid('AB.123.456/0001-10'), isTrue);
      expect(CnpjValidator.validate('AB.123.456/0001-10'), isNull);
    });

    test('deve rejeitar CNPJ com caracteres repetidos', () {
      expect(CnpjValidator.isValid('00.000.000/0000-00'), isFalse);
      expect(CnpjValidator.isValid('11111111111111'), isFalse);
      expect(CnpjValidator.isValid('AAAAAAAAAAAAAA'), isFalse);
      expect(CnpjValidator.validate('00000000000000'), isNotNull);
    });

    test('deve rejeitar CNPJ com dígitos verificadores incorretos', () {
      expect(CnpjValidator.isValid('33.000.167/0001-99'), isFalse);
      expect(CnpjValidator.validate('33.000.167/0001-99'), contains('inválido'));

      expect(CnpjValidator.isValid('12.ABC.345/01DE-99'), isFalse);
      expect(CnpjValidator.validate('12.ABC.345/01DE-99'), contains('inválido'));
    });

    test('deve rejeitar CNPJ nulo, vazio ou com tamanho incorreto', () {
      expect(CnpjValidator.validate(null), contains('obrigatório'));
      expect(CnpjValidator.validate('   '), contains('obrigatório'));
      expect(CnpjValidator.validate('123'), contains('14'));
    });

    test('deve formatar CNPJ corretamente', () {
      expect(CnpjValidator.format('33000167000101'), '33.000.167/0001-01');
      expect(CnpjValidator.format('12ABC34501DE35'), '12.ABC.345/01DE-35');
    });
  });
}
