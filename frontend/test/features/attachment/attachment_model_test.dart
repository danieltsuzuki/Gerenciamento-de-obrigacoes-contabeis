import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/attachment/domain/entities/attachment.dart';

void main() {
  group('Attachment Models and Entities - SPEC-023', () {
    test('Attachment.fromJson e toJson devem serializar e desserializar metadados corretamente', () {
      final json = {
        'id': 55,
        'obligationId': 12,
        'name': 'comprovante_darf.pdf',
        'contentType': 'application/pdf',
        'size': 1048576, // 1 MB
        'uploadedAt': '2026-11-01T14:20:00.000Z',
      };

      final attachment = Attachment.fromJson(json);

      expect(attachment.id, 55);
      expect(attachment.obligationId, 12);
      expect(attachment.name, 'comprovante_darf.pdf');
      expect(attachment.contentType, 'application/pdf');
      expect(attachment.size, 1048576);
      expect(attachment.uploadedAt.year, 2026);

      final outputJson = attachment.toJson();
      expect(outputJson['id'], 55);
      expect(outputJson['obligationId'], 12);
      expect(outputJson['name'], 'comprovante_darf.pdf');
      expect(outputJson['contentType'], 'application/pdf');
      expect(outputJson['size'], 1048576);
    });

    test('Attachment.formattedSize deve formatar bytes em unidades legíveis (B, KB, MB)', () {
      final small = Attachment(
        id: 1,
        obligationId: 1,
        name: 'tiny.txt',
        contentType: 'text/plain',
        size: 512,
        uploadedAt: DateTime(2026, 1, 1),
      );
      expect(small.formattedSize, '512 B');

      final medium = Attachment(
        id: 2,
        obligationId: 1,
        name: 'document.pdf',
        contentType: 'application/pdf',
        size: 1024 * 250, // 250 KB
        uploadedAt: DateTime(2026, 1, 1),
      );
      expect(medium.formattedSize, '250.0 KB');

      final large = Attachment(
        id: 3,
        obligationId: 1,
        name: 'large_backup.zip',
        contentType: 'application/zip',
        size: (1024 * 1024 * 3.5).round(), // 3.5 MB
        uploadedAt: DateTime(2026, 1, 1),
      );
      expect(large.formattedSize, '3.5 MB');
    });
  });
}

