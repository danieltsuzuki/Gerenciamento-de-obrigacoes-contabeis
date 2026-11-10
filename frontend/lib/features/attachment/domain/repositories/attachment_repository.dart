import '../../../../core/network/downloaded_file.dart';
import '../entities/attachment.dart';

abstract class AttachmentRepository {
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  });

  Future<List<Attachment>> getAttachments(int obligationId);

  Future<DownloadedFile> downloadAttachment(int attachmentId);
}

