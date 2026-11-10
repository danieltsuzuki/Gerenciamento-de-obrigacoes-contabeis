import 'package:flutter/material.dart';

import 'platform_file_picker_stub.dart'
    if (dart.library.io) 'platform_file_picker_io.dart'
    if (dart.library.html) 'platform_file_picker_web.dart' as platform_picker;

String detectMimeType(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.xml')) return 'application/xml';
  if (lower.endsWith('.xlsx')) {
    return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  }
  if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
  if (lower.endsWith('.csv') || lower.endsWith('.txt')) return 'text/plain';
  if (lower.endsWith('.zip')) return 'application/zip';
  return 'application/octet-stream';
}

class SelectedFile {
  final String filename;
  final List<int> bytes;
  final int size;
  final String? mimeType;

  const SelectedFile({
    required this.filename,
    required this.bytes,
    required this.size,
    this.mimeType,
  });
}

abstract class FilePickerService {
  Future<SelectedFile?> pickFile({
    BuildContext? context,
    List<String>? allowedExtensions,
  });
}

class DefaultFilePickerService implements FilePickerService {
  final Future<SelectedFile?> Function()? customPicker;

  const DefaultFilePickerService({this.customPicker});

  @override
  Future<SelectedFile?> pickFile({
    BuildContext? context,
    List<String>? allowedExtensions,
  }) async {
    if (customPicker != null) {
      return customPicker!();
    }
    return platform_picker.pickFileFromDevice();
  }
}
