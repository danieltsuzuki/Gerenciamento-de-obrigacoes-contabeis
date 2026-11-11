import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';

void main() {
  group('Company Models and Entities - SPEC-023', () {
    test('Company.fromJson deve desserializar JSON completo com sucesso', () {
      final json = {
        'id': 1,
        'legalName': 'Alpha Tecnologia Ltda',
        'tradeName': 'Alpha Tech',
        'cnpj': '11.222.333/0001-81',
        'active': true,
        'createdAt': '2026-01-15T10:00:00.000Z',
        'updatedAt': '2026-01-20T15:30:00.000Z',
      };

      final company = Company.fromJson(json);

      expect(company.id, 1);
      expect(company.legalName, 'Alpha Tecnologia Ltda');
      expect(company.tradeName, 'Alpha Tech');
      expect(company.cnpj, '11.222.333/0001-81');
      expect(company.active, isTrue);
      expect(company.createdAt, isNotNull);
      expect(company.updatedAt, isNotNull);
      expect(company.displayName, 'Alpha Tech');
    });

    test('Company.fromJson deve tratar campos opcionais nulos e defaults', () {
      final json = {
        'id': 2,
        'legalName': 'Beta Servicos SA',
        'cnpj': '22.333.444/0001-92',
      };

      final company = Company.fromJson(json);

      expect(company.id, 2);
      expect(company.legalName, 'Beta Servicos SA');
      expect(company.tradeName, isNull);
      expect(company.active, isTrue);
      expect(company.createdAt, isNull);
      expect(company.updatedAt, isNull);
      expect(company.displayName, 'Beta Servicos SA');
    });

    test('Company.displayName deve usar legalName se tradeName for vazio', () {
      const company = Company(
        id: 3,
        legalName: 'Gama Comercio Ltda',
        tradeName: '',
        cnpj: '33.444.555/0001-03',
        active: false,
      );

      expect(company.displayName, 'Gama Comercio Ltda');
    });

    test('Company.toJson deve gerar mapa serializável com campos preenchidos', () {
      final company = Company(
        id: 4,
        legalName: 'Delta Transportes',
        tradeName: 'Delta Log',
        cnpj: '44.555.666/0001-14',
        active: true,
        createdAt: DateTime(2026, 2, 1, 12, 0),
      );

      final json = company.toJson();

      expect(json['id'], 4);
      expect(json['legalName'], 'Delta Transportes');
      expect(json['tradeName'], 'Delta Log');
      expect(json['cnpj'], '44.555.666/0001-14');
      expect(json['active'], isTrue);
      expect(json['createdAt'], isNotNull);
      expect(json.containsKey('updatedAt'), isFalse);
    });

    test('CreateCompanyRequest.toJson deve serializar corretamente', () {
      const request = CreateCompanyRequest(
        legalName: 'Nova Empresa Ltda',
        tradeName: 'Nova',
        cnpj: '12345678000195',
        active: true,
      );

      final json = request.toJson();

      expect(json['legalName'], 'Nova Empresa Ltda');
      expect(json['tradeName'], 'Nova');
      expect(json['cnpj'], '12345678000195');
      expect(json['active'], isTrue);
    });

    test('UpdateCompanyRequest.toJson deve serializar campos para atualização', () {
      const request = UpdateCompanyRequest(
        legalName: 'Empresa Atualizada Ltda',
        tradeName: 'Atualizada',
        cnpj: '98765432000187',
        active: false,
      );

      final json = request.toJson();

      expect(json['legalName'], 'Empresa Atualizada Ltda');
      expect(json['tradeName'], 'Atualizada');
      expect(json['cnpj'], '98765432000187');
      expect(json['active'], isFalse);
    });
  });
}

