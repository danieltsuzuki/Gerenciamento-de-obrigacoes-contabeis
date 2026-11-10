// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'file_picker_service.dart';

Future<SelectedFile?> pickFileFromDevice() async {
  final completer = Completer<SelectedFile?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(
            SelectedFile(
              filename: file.name,
              bytes: result,
              size: file.size,
              mimeType: file.type.isNotEmpty ? file.type : detectMimeType(file.name),
            ),
          );
        } else if (result is List<int>) {
          completer.complete(
            SelectedFile(
              filename: file.name,
              bytes: result,
              size: file.size,
              mimeType: file.type.isNotEmpty ? file.type : detectMimeType(file.name),
            ),
          );
        } else {
          completer.complete(null);
        }
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
