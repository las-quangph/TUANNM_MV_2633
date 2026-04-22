import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AvatarStorage {
  static Future<String> persistAvatar(String sourcePath) async {
    final sourceFile = File(sourcePath);
    final appDirectory = await getApplicationDocumentsDirectory();
    final avatarDirectory = Directory('${appDirectory.path}/profile');
    if (!await avatarDirectory.exists()) {
      await avatarDirectory.create(recursive: true);
    }

    final extension = _extensionOf(sourcePath);
    final targetFile = File(
      '${avatarDirectory.path}/avatar$extension',
    );

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final savedFile = await sourceFile.copy(targetFile.path);
    return savedFile.path;
  }

  static String _extensionOf(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex);
  }
}
