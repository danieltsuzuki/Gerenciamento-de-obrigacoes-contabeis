import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

void main() {
  group('Responsible Models and Entities - SPEC-023', () {
    test('Responsible.fromJson deve desserializar JSON completo com sucesso', () {
      final json = {
        'id': 10,
        'name': 'Carlos Contador',
        'email': 'carlos@contabilidade.com',
        'active': true,
        'createdAt': '2026-02-10T08:00:00.000Z',
        'updatedAt': '2026-02-15T09:30:00.000Z',
      };

      final responsible = Responsible.fromJson(json);

      expect(responsible.id, 10);
      expect(responsible.name, 'Carlos Contador');
      expect(responsible.email, 'carlos@contabilidade.com');
      expect(responsible.active, isTrue);
      expect(responsible.createdAt, isNotNull);
      expect(responsible.updatedAt, isNotNull);
    });

    test('Responsible.fromJson deve tratar valores padrão quando opcionais estiverem ausentes', () {
      final json = {
        'id': 20,
        'name': 'Ana Silva',
        'email': 'ana@contabilidade.com',
      };

      final responsible = Responsible.fromJson(json);

      expect(responsible.id, 20);
      expect(responsible.active, isTrue);
      expect(responsible.createdAt, isNull);
      expect(responsible.updatedAt, isNull);
    });

    test('Responsible.toJson deve serializar dados corretamente', () {
      const responsible = Responsible(
        id: 30,
        name: 'Roberto Fiscal',
        email: 'roberto@contabilidade.com',
        active: false,
      );

      final json = responsible.toJson();

      expect(json['id'], 30);
      expect(json['name'], 'Roberto Fiscal');
      expect(json['email'], 'roberto@contabilidade.com');
      expect(json['active'], isFalse);
    });

    test('CreateResponsibleRequest.toJson deve incluir credenciais e active', () {
      const request = CreateResponsibleRequest(
        name: 'Novo Responsavel',
        email: 'novo@empresa.com',
        password: 'SenhaSegura@2026',
        active: true,
      );

      final json = request.toJson();

      expect(json['name'], 'Novo Responsavel');
      expect(json['email'], 'novo@empresa.com');
      expect(json['password'], 'SenhaSegura@2026');
      expect(json['active'], isTrue);
    });

    test('UpdateResponsibleRequest.toJson deve serializar dados de atualização', () {
      const request = UpdateResponsibleRequest(
        name: 'Responsavel Atualizado',
        email: 'atualizado@empresa.com',
        active: false,
      );

      final json = request.toJson();

      expect(json['name'], 'Responsavel Atualizado');
      expect(json['email'], 'atualizado@empresa.com');
      expect(json['active'], isFalse);
    });
  });
}

