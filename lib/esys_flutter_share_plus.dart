import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Share {
  static const MethodChannel _channel = const MethodChannel(
      'channel:github.com/orgs/esysberlin/esys-flutter-share');

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
    Map<String, String> argsMap = {
      'title': title,
      'name': name,
      'mimeType': mimeType,
      'text': text
    };

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$name').create();
    await file.writeAsBytes(bytes);

    _channel.invokeMethod('file', argsMap);
  }

  /// Sends multiple files to other apps from memory.
  ///
  /// **Warning:** Use this method only for small files. For large files, use [filesFromStorage]
  /// to avoid potential out of memory errors.
  static Future<void> filesFromMemory(
    String title,
    Map<String, List<int>> files,
    Set<String> mimeTypes, {
    String text = '',
  }) async {
    Map<String, dynamic> argsMap = {
      'title': title,
      'names': files.keys.toList(),
      'mimeTypes': mimeTypes.toList(),
      'text': text
    };

    final tempDir = await getTemporaryDirectory();

    for (var entry in files.entries) {
      final file = await File('${tempDir.path}/${entry.key}').create();
      await file.writeAsBytes(entry.value);
    }

    _channel.invokeMethod('files', argsMap);
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
    Map<String, String> argsMap = {
      'title': title,
      'name': name,
      'mimeType': mimeType,
      'text': text
    };

    final tempDir = await getTemporaryDirectory();
    final sourceFile = File(filePath);
    final destFile = await File('${tempDir.path}/$name').create();

    await sourceFile.copy(destFile.path);

    _channel.invokeMethod('file', argsMap);
  }

  /// Sends multiple files to other apps using file paths.
  ///
  /// This method is recommended for sharing files to avoid memory issues.
  static Future<void> filesFromStorage(
    String title,
    Map<String, String> files,
    Set<String> mimeTypes, {
    String text = '',
  }) async {
    Map<String, dynamic> argsMap = {
      'title': title,
      'names': files.keys.toList(),
      'mimeTypes': mimeTypes.toList(),
      'text': text
    };

    final tempDir = await getTemporaryDirectory();

    for (var entry in files.entries) {
      final sourceFile = File(entry.value);
      final destFile = await File('${tempDir.path}/${entry.key}').create();
      await sourceFile.copy(destFile.path);
    }

    _channel.invokeMethod('files', argsMap);
  }
}
