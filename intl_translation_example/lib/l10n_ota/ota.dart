import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl_translation_json/intl_translation_json.dart';

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:path/path.dart' as path;
import 'package:intl_translation_ota/intl_translation_ota.dart';
import 'dart:convert';

Future loadNewTranslations() async {
  final file1 = await AssetTranslationFile.loadTranslationFile(
      'assets/arb/intl_messages_en.json');
  final file2 = await AssetTranslationFile.loadTranslationFile(
      'assets/arb/intl_messages_fr.json');
  TranslationCatalog catalog = TranslationCatalog();
  catalog.defaultLocal = 'en';
  catalog =
      catalog.addTranslationsFromFiles([file1, file2], format: JsonFormat());

  TranslationLoader(catalog).initializeMessages('fr');
}

Future loadNetworkTranslations() async {
  final file2 = await NetworkTranslationFile.loadTranslationFromUrl(
    'https://firebasestorage.googleapis.com/v0/b/jaimeblascoandres.appspot.com/o/gsoc%2Fintl_messages_fr.json?alt=media&token=6debf01c-1049-4959-a3e3-c9bd4acd8a8f',
    'intl_messages_fr',
  );
  print(file2.content);
  TranslationCatalog catalog = TranslationCatalog();

  catalog.defaultLocal = 'en';
  catalog = catalog.addTranslationsFromFiles([file2], format: JsonFormat());

  TranslationLoader(catalog).initializeMessages('fr');
}

class NetworkTranslationFile extends TranslationFile {
  static Future<TranslationFile> loadTranslationFromUrl(
    String _url,
    String name, {
    FileType type = FileType.text,
  }) async {
    final url = Uri.parse(_url);
    var httpClient = new HttpClient();
    final request = await httpClient.getUrl(url);

    final response = await request.close();

    final data = await response.transform(utf8.decoder).toList();

    var content = data.join('');

    httpClient.close();

    httpClient.close();

    final fileExtension = 'json';
    return TranslationFile(
        name: name, fileExtension: fileExtension, content: content);
    /* if (type == FileType.text) {
      
    
    } else {
      final data = await rootBundle.load(key);
      final buffer = data.buffer;
      final bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      return TranslationFile.binary(
        name: name,
        fileExtension: fileExtension,
        bytes: bytes,
      ); */
    // }
  }
}

class AssetTranslationFile extends TranslationFile {
  static Future<TranslationFile> loadTranslationFile(
    String key, {
    FileType type = FileType.text,
  }) async {
    final name = path.basenameWithoutExtension(key);
    final fileExtension = path.extension(key).replaceAll('.', '');
    if (type == FileType.text) {
      final content = await rootBundle.loadString(key);
      return TranslationFile(
          name: name, fileExtension: fileExtension, content: content);
    } else {
      final data = await rootBundle.load(key);
      final buffer = data.buffer;
      final bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      return TranslationFile.binary(
        name: name,
        fileExtension: fileExtension,
        bytes: bytes,
      );
    }
  }
}
