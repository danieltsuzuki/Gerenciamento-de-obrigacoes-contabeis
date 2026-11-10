import '../../../../core/network/api_client.dart';
import '../../../../core/network/downloaded_file.dart';
import '../../domain/entities/attachment.dart';

abstract class AttachmentRemoteDataSource {
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  });

  Future<List<Attachment>> getAttachments(int obligationId);

  Future<DownloadedFile> downloadAttachment(int attachmentId);
}

class AttachmentRemoteDataSourceImpl implements AttachmentRemoteDataSource {
  final ApiClient _apiClient;

  AttachmentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  }) async {
    final response = await _apiClient.multipartRequest(
      '/api/obligations/$obligationId/attachments',
      fieldName: 'file',
      filename: filename,
      bytes: bytes,
      contentType: contentType,
    );
    return Attachment.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<Attachment>> getAttachments(int obligationId) async {
    final response = await _apiClient.get(
      '/api/obligations/$obligationId/attachments',
    );

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(Attachment.fromJson)
          .toList();
    }
    return [];
  }

  @override
  Future<DownloadedFile> downloadAttachment(int attachmentId) {
    return _apiClient.download('/api/attachments/$attachmentId/download');
  }
}

