import 'dart:io';
import 'package:flutter/foundation.dart';
import 'file_picker_service.dart';

Future<SelectedFile?> pickFileFromDevice() async {
  if (Platform.isWindows) {
    try {
      const script = r'''
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = "Selecionar Arquivo para Anexo"
$dialog.Filter = "Todos os Arquivos (*.*)|*.*|Documentos PDF (*.pdf)|*.pdf|Imagens (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg|XML (*.xml)|*.xml|Planilhas (*.xlsx;*.xls)|*.xlsx;*.xls"
$res = $dialog.ShowDialog()
if ($res -eq [System.Windows.Forms.DialogResult]::OK) {
  [Console]::WriteLine($dialog.FileName)
}
''';
      final result = await Process.run('powershell', ['-Sta', '-NoProfile', '-Command', script]);
      final selectedPath = result.stdout.toString().trim();
      if (selectedPath.isNotEmpty) {
        final file = File(selectedPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final filename = selectedPath.split(RegExp(r'[\\/]')).last;
          final mimeType = detectMimeType(filename);
          return SelectedFile(
            filename: filename,
            bytes: bytes,
            size: bytes.length,
            mimeType: mimeType,
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir seletor nativo do Windows: $e');
    }
  }
  return null;
}

