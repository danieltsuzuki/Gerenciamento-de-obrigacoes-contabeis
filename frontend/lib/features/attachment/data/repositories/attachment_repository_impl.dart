import '../../../../core/network/downloaded_file.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../datasources/attachment_remote_datasource.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentRemoteDataSource _remoteDataSource;

  AttachmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  }) {
    return _remoteDataSource.uploadAttachment(
      obligationId: obligationId,
      filename: filename,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<List<Attachment>> getAttachments(int obligationId) {
    return _remoteDataSource.getAttachments(obligationId);
  }

  @override
  Future<DownloadedFile> downloadAttachment(int attachmentId) {
    return _remoteDataSource.downloadAttachment(attachmentId);
  }
}

