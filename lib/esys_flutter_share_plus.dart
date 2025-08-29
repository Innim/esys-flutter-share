import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Share {
  static const MethodChannel _channel = const MethodChannel(
      'channel:github.com/orgs/esysberlin/esys-flutter-share');

  static const _tempShareDirectoryName = 'org_innim_esys_flutter_share_tmp';

  static Future<void>? _initialise;

  /// Initializes the Share plugin.
  ///
  /// This method should be called at app startup or before starting to work with sharing.
  /// It performs cleanup of temporary files that may have been left from previous
  /// sharing sessions, especially if the app was closed or crashed before the share
  /// window was properly closed.
  ///
  /// It's recommended to call this method in your app's initialization code
  /// (e.g., in main() or in the initState of your main widget) to ensure
  /// a clean state before any sharing operations.
  static Future<void> init() async {
    await (_initialise ??= _init());
  }

  /// Sends a text to other apps.
  static void text(String title, String text, String mimeType) {
    Map argsMap = <String, String>{
      'title': title,
      'text': text,
      'mimeType': mimeType
    };
    _channel.invokeMethod('text', argsMap);
  }

  /// Sends a file to other apps.
  ///
  /// **Note:** It's recommended to use [fileFromStorage] for better performance
  /// and to avoid potential memory issues. Use this method only for small files.
  @Deprecated(
      'Use fileFromStorage instead. For small files, you can use fileFromMemory(), which is not recommended for large files due to memory constraints.')
  static Future<void> file(
    String title,
    String name,
    List<int> bytes,
    String mimeType, {
    String text = '',
  }) async {
    await fileFromMemory(title, name, bytes, mimeType, text: text);
  }

  /// Sends multiple files to other apps.
  ///
  /// **Note:** It's recommended to use [filesFromStorage] for better performance
  /// and to avoid potential memory issues. Use this method only for small files.
  @Deprecated(
      'Use filesFromStorage instead. For small files, you can use filesFromMemory(), which is not recommended for large files due to memory constraints.')
  static Future<void> files(
    String title,
    Map<String, List<int>> files,
    Set<String> mimeTypes, {
    String text = '',
  }) async {
    await filesFromMemory(title, files, mimeTypes, text: text);
  }

  /// Sends a file to other apps from memory.
  ///
  /// **Warning:** Use this method only for small files. For large files, use [fileFromStorage]
  /// to avoid potential out of memory errors.
  static Future<void> fileFromMemory(
    String title,
    String name,
    List<int> bytes,
    String mimeType, {
    String text = '',
  }) async {
    await init();

    final tempDir = await _getDirectoryForShareFile();
    final file = await File('${tempDir.path}/$name').create();
    await file.writeAsBytes(bytes);

    Map<String, String> argsMap = {
      'title': title,
      'mimeType': mimeType,
      'text': text,
      'filePath': file.path,
    };

    _channel.invokeMethod('file', argsMap).whenComplete(() {
      file.delete();
    });
  }

  /// Sends multiple files to other apps from memory.
  ///
  /// **Warning:** Use this method only for small files. For large files, use [filesFromStorage]
  /// to avoid potential out of memory errors.
  /// The optional `mimeTypes` parameter can be used to specify MIME types for
  /// the provided files.
  /// Android supports all natively available MIME types (wildcards like image/*
  /// are also supported) and it's considered best practice to avoid mixing
  /// unrelated file types (eg. image/jpg & application/pdf). If MIME types are
  /// mixed the plugin attempts to find the lowest common denominator. Even
  /// if MIME types are supplied the receiving app decides if those are used
  /// or handled.
  /// On iOS image/jpg, image/jpeg and image/png are handled as images, while
  /// every other MIME type is considered a normal file.
  static Future<void> filesFromMemory(
    String title,
    Map<String, List<int>> files,
    Set<String> mimeTypes, {
    String text = '',
  }) async {
    await init();

    final tempDir = await _getDirectoryForShareFile();

    final filePaths = <String>[];
    final tempFilesList = <File>[];

    for (var entry in files.entries) {
      final file = await File('${tempDir.path}/${entry.key}').create();
      await file.writeAsBytes(entry.value);
      filePaths.add(file.path);
      tempFilesList.add(file);
    }
    Map<String, dynamic> argsMap = {
      'title': title,
      'mimeTypes': mimeTypes.toList(),
      'text': text,
      'filePaths': filePaths,
    };
    _channel.invokeMethod('files', argsMap).whenComplete(() {
      for (final file in tempFilesList) {
        file.delete();
      }
    });
  }

  /// Sends a file to other apps using a file path.
  ///
  /// This method is recommended for sharing files to avoid memory issues.
  static Future<void> fileFromStorage(
    String title,
    String name,
    String filePath,
    String mimeType, {
    String text = '',
  }) async {
    await init();
    final tempShareDir = await _getDirectoryForShareFile();
    final sourceFile = File(filePath);
    final destFile = await File('${tempShareDir.path}/$name').create();

    await sourceFile.copy(destFile.path);

    Map<String, String> argsMap = {
      'title': title,
      'mimeType': mimeType,
      'text': text,
      'filePath': destFile.path
    };

    _channel.invokeMethod('file', argsMap).whenComplete(() {
      destFile.delete();
    });
  }

  /// Sends multiple files to other apps using file paths.
  ///
  /// This method is recommended for sharing files to avoid memory issues.
  /// The optional `mimeTypes` parameter can be used to specify MIME types for
  /// the provided files.
  /// Android supports all natively available MIME types (wildcards like image/*
  /// are also supported) and it's considered best practice to avoid mixing
  /// unrelated file types (eg. image/jpg & application/pdf). If MIME types are
  /// mixed the plugin attempts to find the lowest common denominator. Even
  /// if MIME types are supplied the receiving app decides if those are used
  /// or handled.
  /// On iOS image/jpg, image/jpeg and image/png are handled as images, while
  /// every other MIME type is considered a normal file.
  static Future<void> filesFromStorage(
    String title,
    Map<String, String> files,
    Set<String> mimeTypes, {
    String text = '',
  }) async {
    await init();
    final tempShareDir = await _getDirectoryForShareFile();
    final tempFilesList = <File>[];
    final filePaths = <String>[];

    for (var entry in files.entries) {
      final sourceFile = File(entry.value);
      final destFile = await File('${tempShareDir.path}/${entry.key}').create();
      tempFilesList.add(destFile);
      filePaths.add(destFile.path);
      await sourceFile.copy(destFile.path);
    }

    Map<String, dynamic> argsMap = {
      'title': title,
      'mimeTypes': mimeTypes.toList(),
      'text': text,
      'filePaths': filePaths
    };

    _channel.invokeMethod('files', argsMap).whenComplete(() {
      for (final file in tempFilesList) {
        file.delete();
      }
    });
    ;
  }

  static Future<void> _init() async {
    _clearTempShareDirectory();
  }

  static Future<Directory> _getDirectoryForShareFile() async {
    final tempShareDir = await _getBaseTempShareDirectory();
    final dirForFile = Directory('${tempShareDir.path}/${_getRandomString()}');
    await dirForFile.create(recursive: true);
    return dirForFile;
  }

  static Future<Directory> _getBaseTempShareDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final tempShareDir = Directory('${tempDir.path}/$_tempShareDirectoryName');
    return tempShareDir;
  }

  static String _getRandomString() {
    final random = Random();
    return random.nextInt(100000).toString();
  }

  static Future<void> _clearTempShareDirectory() async {
    final tempShareDir = await _getBaseTempShareDirectory();
    if (await tempShareDir.exists()) {
      tempShareDir.delete(recursive: true);
    }
  }
}
