import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation_status_history.dart';

void main() {
  group('ObligationStatusHistory Model - SPEC-035', () {
    test('deve desserializar JSON de criação (fromStatus nulo)', () {
      final json = {
        'id': 1,
        'obligationId': 10,
        'fromStatus': null,
        'toStatus': 'PENDING',
        'changedBy': {
          'id': 2,
          'name': 'Carlos Contador',
          'email': 'carlos@empresa.com',
        },
        'changedAt': '2026-11-10T10:00:00',
      };

      final history = ObligationStatusHistory.fromJson(json);

      expect(history.id, 1);
      expect(history.obligationId, 10);
      expect(history.fromStatus, isNull);
      expect(history.toStatus, ObligationStatus.pending);
      expect(history.changedBy, isNotNull);
      expect(history.changedBy!.id, 2);
      expect(history.changedBy!.name, 'Carlos Contador');
      expect(history.changedBy!.email, 'carlos@empresa.com');
      expect(history.changedAt, DateTime.parse('2026-11-10T10:00:00'));
    });

    test('deve desserializar JSON com transição de status e changedBy nulo', () {
      final json = {
        'id': 2,
        'obligationId': 10,
        'fromStatus': 'PENDING',
        'toStatus': 'IN_PROGRESS',
        'changedBy': null,
        'changedAt': '2026-11-10T14:30:00',
      };

      final history = ObligationStatusHistory.fromJson(json);

      expect(history.id, 2);
      expect(history.obligationId, 10);
      expect(history.fromStatus, ObligationStatus.pending);
      expect(history.toStatus, ObligationStatus.inProgress);
      expect(history.changedBy, isNull);
      expect(history.changedAt, DateTime.parse('2026-11-10T14:30:00'));
    });
  });
}

