import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_status_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';

void main() {
  group('Obligation Models and Entities - SPEC-023', () {
    test('ObligationStatus deve mapear códigos, labels e transições permitidas (RN-008)', () {
      expect(ObligationStatus.fromCode('PENDING'), ObligationStatus.pending);
      expect(ObligationStatus.fromCode('IN_PROGRESS'), ObligationStatus.inProgress);
      expect(ObligationStatus.fromCode('COMPLETED'), ObligationStatus.completed);
      expect(ObligationStatus.fromCode('OUTRO_VALOR'), ObligationStatus.pending);

      expect(ObligationStatus.pending.label, 'Pendente');
      expect(ObligationStatus.inProgress.label, 'Em Andamento');
      expect(ObligationStatus.completed.label, 'Concluída');

      // Transições válidas
      expect(ObligationStatus.pending.canTransitionTo(ObligationStatus.inProgress), isTrue);
      expect(ObligationStatus.inProgress.canTransitionTo(ObligationStatus.completed), isTrue);

      // Transições inválidas
      expect(ObligationStatus.pending.canTransitionTo(ObligationStatus.completed), isFalse);
      expect(ObligationStatus.inProgress.canTransitionTo(ObligationStatus.pending), isFalse);
      expect(ObligationStatus.completed.canTransitionTo(ObligationStatus.inProgress), isFalse);
      expect(ObligationStatus.completed.canTransitionTo(ObligationStatus.pending), isFalse);
    });

    test('ObligationParticipantSummary.fromJson deve extrair id e nome de diferentes formatos', () {
      final summaryFromLegalName = ObligationParticipantSummary.fromJson({
        'id': 1,
        'legalName': 'Empresa Exemplo SA',
      });
      expect(summaryFromLegalName.id, 1);
      expect(summaryFromLegalName.name, 'Empresa Exemplo SA');

      final summaryFromName = ObligationParticipantSummary.fromJson({
        'id': 2,
        'name': 'João da Silva',
      });
      expect(summaryFromName.id, 2);
      expect(summaryFromName.name, 'João da Silva');
    });

    test('Obligation.fromJson deve desserializar objeto completo', () {
      final json = {
        'id': 100,
        'title': 'DIRF Anual 2026',
        'description': 'Declaração do Imposto de Renda Retido na Fonte',
        'status': 'IN_PROGRESS',
        'dueDate': '2026-02-28',
        'completedAt': null,
        'createdAt': '2026-01-10T10:00:00.000Z',
        'updatedAt': '2026-01-15T12:00:00.000Z',
        'company': {'id': 5, 'name': 'Empresa XYZ'},
        'responsible': {'id': 8, 'name': 'Mariana Souza'},
        'attachmentCount': 3,
      };

      final obligation = Obligation.fromJson(json);

      expect(obligation.id, 100);
      expect(obligation.title, 'DIRF Anual 2026');
      expect(obligation.description, 'Declaração do Imposto de Renda Retido na Fonte');
      expect(obligation.status, ObligationStatus.inProgress);
      expect(obligation.dueDate.year, 2026);
      expect(obligation.company.id, 5);
      expect(obligation.responsible.id, 8);
      expect(obligation.attachmentCount, 3);
    });

    test('Obligation.copyWith deve atualizar propriedades selecionadas preservando as demais', () {
      final original = Obligation(
        id: 200,
        title: 'DAS Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos'),
        attachmentCount: 0,
      );

      final updated = original.copyWith(
        status: ObligationStatus.inProgress,
        attachmentCount: 2,
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.status, ObligationStatus.inProgress);
      expect(updated.attachmentCount, 2);
      expect(updated.company.id, original.company.id);
    });

    test('Obligation.isOverdue deve calcular status de atraso com precisão', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final futureDate = DateTime.now().add(const Duration(days: 2));

      final overdueObligation = Obligation(
        id: 301,
        title: 'Obrigação Atrasada',
        status: ObligationStatus.pending,
        dueDate: pastDate,
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Responsável'),
      );
      expect(overdueObligation.isOverdue, isTrue);

      final onTimeObligation = Obligation(
        id: 302,
        title: 'Obrigação no Prazo',
        status: ObligationStatus.pending,
        dueDate: futureDate,
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Responsável'),
      );
      expect(onTimeObligation.isOverdue, isFalse);

      final completedPastDueObligation = Obligation(
        id: 303,
        title: 'Obrigação Concluída',
        status: ObligationStatus.completed,
        dueDate: pastDate,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Responsável'),
      );
      expect(completedPastDueObligation.isOverdue, isFalse);
    });

    test('Requests de Obrigação devem serializar payloads JSON esperados pela API', () {
      const createReq = CreateObligationRequest(
        companyId: 10,
        responsibleId: 20,
        title: 'Nova Guia FGTS',
        description: 'Guia mensal',
        dueDate: '2026-11-20',
      );
      final createJson = createReq.toJson();
      expect(createJson['companyId'], 10);
      expect(createJson['responsibleId'], 20);
      expect(createJson['title'], 'Nova Guia FGTS');
      expect(createJson['description'], 'Guia mensal');
      expect(createJson['dueDate'], '2026-11-20');

      const updateReq = UpdateObligationRequest(
        companyId: 11,
        responsibleId: 21,
        title: 'Guia Atualizada',
        dueDate: '2026-11-25',
        status: ObligationStatus.inProgress,
      );
      final updateJson = updateReq.toJson();
      expect(updateJson['companyId'], 11);
      expect(updateJson['status'], 'IN_PROGRESS');

      const statusReq = UpdateObligationStatusRequest(ObligationStatus.completed);
      final statusJson = statusReq.toJson();
      expect(statusJson['status'], 'COMPLETED');
    });
  });
}

