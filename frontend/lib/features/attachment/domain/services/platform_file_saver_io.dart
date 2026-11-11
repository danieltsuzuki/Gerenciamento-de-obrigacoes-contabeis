import 'dart:io';
import 'package:flutter/widgets.dart';
import '../../../../core/network/downloaded_file.dart';

bool get _isTestEnvironment {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
  final binding = WidgetsBinding.instance.runtimeType.toString();
  return binding.contains('Test') || binding.contains('AutomatedTest');
}

Future<String?> saveAndOpenFileOnDevice(DownloadedFile file) async {
  try {
    if (_isTestEnvironment) {
      return 'test_downloads/${file.filename}';
    }

    Directory targetDir;
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final downloads = Directory('$userProfile\\Downloads');
        targetDir = downloads.existsSync() ? downloads : Directory.systemTemp;
      } else {
        targetDir = Directory.systemTemp;
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final downloads = Directory('$home/Downloads');
        targetDir = downloads.existsSync() ? downloads : Directory.systemTemp;
      } else {
        targetDir = Directory.systemTemp;
      }
    }

    final safeFilename = file.filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filePath = '${targetDir.path}${Platform.pathSeparator}$safeFilename';
    final targetFile = File(filePath);
    await targetFile.writeAsBytes(file.bytes, flush: true);

    if (!_isTestEnvironment) {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      }
    }

    return targetFile.path;
  } catch (e) {
    debugPrint('Erro ao salvar/abrir arquivo localmente: $e');
    return null;
  }
}
