import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/features/attachment/data/datasources/attachment_remote_datasource.dart';
import 'package:player_contabilidade_front/features/attachment/data/repositories/attachment_repository_impl.dart';

void main() {
  group('Attachment Integration Layer', () {
    test('uploadAttachment deve enviar multipart e retornar Attachment model', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/obligations/10/attachments');

        return http.Response(
          jsonEncode({
            'id': 50,
            'obligationId': 10,
            'name': 'recibo_darf.pdf',
            'contentType': 'application/pdf',
            'size': 2048,
            'uploadedAt': '2026-11-10T14:30:00',
          }),
          201,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AttachmentRemoteDataSourceImpl(apiClient);
      final repository = AttachmentRepositoryImpl(dataSource);

      final attachment = await repository.uploadAttachment(
        obligationId: 10,
        filename: 'recibo_darf.pdf',
        bytes: utf8.encode('PDF mock content'),
        contentType: 'application/pdf',
      );

      expect(attachment.id, 50);
      expect(attachment.name, 'recibo_darf.pdf');
      expect(attachment.obligationId, 10);
      expect(attachment.size, 2048);
    });

    test('getAttachments deve listar anexos da obrigação', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/obligations/10/attachments');

        return http.Response(
          jsonEncode([
            {
              'id': 50,
              'obligationId': 10,
              'name': 'recibo_darf.pdf',
              'contentType': 'application/pdf',
              'size': 2048,
              'uploadedAt': '2026-11-10T14:30:00',
            },
            {
              'id': 51,
              'obligationId': 10,
              'name': 'declaracao.xml',
              'contentType': 'application/xml',
              'size': 1024,
              'uploadedAt': '2026-11-10T14:35:00',
            }
          ]),
          200,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AttachmentRemoteDataSourceImpl(apiClient);
      final repository = AttachmentRepositoryImpl(dataSource);

      final attachments = await repository.getAttachments(10);

      expect(attachments.length, 2);
      expect(attachments[0].name, 'recibo_darf.pdf');
      expect(attachments[1].name, 'declaracao.xml');
    });

    test('downloadAttachment deve retornar bytes e filename sanitizado', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/attachments/50/download');

        return http.Response.bytes(
          Uint8List.fromList([10, 20, 30, 40]),
          200,
          headers: {
            'content-type': 'application/pdf',
            'content-disposition': 'attachment; filename="recibo_darf.pdf"',
          },
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AttachmentRemoteDataSourceImpl(apiClient);
      final repository = AttachmentRepositoryImpl(dataSource);

      final file = await repository.downloadAttachment(50);

      expect(file.filename, 'recibo_darf.pdf');
      expect(file.bytes.length, 4);
      expect(file.contentType, 'application/pdf');
    });

    test('download de anexo inexistente deve lançar 404 NOT_FOUND', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'NOT_FOUND',
            'message': 'Anexo não encontrado',
            'details': [],
          }),
          404,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AttachmentRemoteDataSourceImpl(apiClient);

      expect(
        () => dataSource.downloadAttachment(999),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isNotFound, 'isNotFound', isTrue)
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });
}

