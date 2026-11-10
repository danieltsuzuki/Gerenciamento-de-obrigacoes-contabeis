import 'dart:typed_data';

class DownloadedFile {
  final String filename;
  final Uint8List bytes;
  final String contentType;

  const DownloadedFile({
    required this.filename,
    required this.bytes,
    required this.contentType,
  });

  static String extractFilenameFromHeader(
    String? contentDisposition, {
    String fallback = 'download.bin',
  }) {
    if (contentDisposition == null || contentDisposition.isEmpty) {
      return fallback;
    }

    final filenameMatch = RegExp(
      r'filename="?([^";\n]+)"?',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    if (filenameMatch != null && filenameMatch.group(1) != null) {
      return filenameMatch.group(1)!.trim();
    }

    return fallback;
  }
}
