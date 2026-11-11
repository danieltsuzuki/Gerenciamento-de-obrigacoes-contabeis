import '../../../../core/network/downloaded_file.dart';
import 'platform_file_saver_stub.dart'
    if (dart.library.io) 'platform_file_saver_io.dart'
    if (dart.library.html) 'platform_file_saver_web.dart' as platform_saver;

abstract class FileSaverService {
  Future<String?> saveAndOpenFile(DownloadedFile file);
}

class DefaultFileSaverService implements FileSaverService {
  final Future<String?> Function(DownloadedFile file)? customSaver;

  const DefaultFileSaverService({this.customSaver});

  @override
  Future<String?> saveAndOpenFile(DownloadedFile file) async {
    if (customSaver != null) {
      return customSaver!(file);
    }
    return platform_saver.saveAndOpenFileOnDevice(file);
  }
}

