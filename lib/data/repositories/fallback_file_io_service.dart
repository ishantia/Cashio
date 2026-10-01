import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';

import '../../domain/services/file_io_service.dart';

class FallbackFileIoService implements FileIoService {
  @override
  Future<String?> pickFile({required List<String> allowedExtensions}) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'data',
        extensions: allowedExtensions,
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        return file.path;
      }
    } catch (e) {
      // Fallback for missing SAF or headless tests
      final dir = await getApplicationDocumentsDirectory();
      final f = File('${dir.path}/cashio_backup.json');
      if (await f.exists()) return f.path;
    }
    return null;
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
  }) async {
    try {
      final path = await getSaveLocation(suggestedName: fileName);
      if (path != null) {
        final f = XFile.fromData(
          Uint8List.fromList(content.codeUnits),
          name: fileName,
          mimeType: 'application/json',
        );
        await f.saveTo(path.path);
        return path.path;
      }
    } catch (e) {
      // Fallback
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    }
    return null;
  }
}
