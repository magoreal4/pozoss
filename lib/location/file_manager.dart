import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<void> writeFile(String log) async {
    final file = await _getTempFile();
    await file.writeAsString(log, mode: FileMode.append);
  }

  static Future<String> readFile() async {
    final file = await _getTempFile();
    return file.readAsString();
  }

  static Future<File> _getTempFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/pos.json');
    if (!await file.exists()) {
      await file.writeAsString('');
    }
    return file;
  }

  static Future<void> clearFile() async {
    final file = await _getTempFile();
    await file.writeAsString('');
  }
}
