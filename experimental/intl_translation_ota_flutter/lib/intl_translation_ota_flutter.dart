library intl_translation_ota_flutter;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:path/path.dart' as p;

export 'package:intl_translation_ota/intl_translation_ota.dart';
export 'src/app_strings.dart';


class AssetFile extends RedableFile {
  final String key;

  @override
  String get name => p.basename(key);
  AssetFile(this.key);

  @override
  Future<Uint8List> readAsBytes() async {
    final data = await rootBundle.load(key);
    final buffer = data.buffer;
    final bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return bytes;
  }

  @override
  Future<String> readAsString() async {
    return await rootBundle.loadString(key);
  }
}
