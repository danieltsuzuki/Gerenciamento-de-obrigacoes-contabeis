// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../../../../core/network/downloaded_file.dart';

Future<String?> saveAndOpenFileOnDevice(DownloadedFile file) async {
  try {
    final blob = html.Blob([file.bytes], file.contentType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', file.filename);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return file.filename;
  } catch (e) {
    return null;
  }
}
