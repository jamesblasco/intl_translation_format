import 'dart:typed_data';

import 'package:intl_translation_format/intl_translation_format.dart';

class MockFile extends ReadableFile {
  final FileData data;
  MockFile(this.data);

  @override
  String get name => data.name;

  @override
  Future<Uint8List> readAsBytes() async {
    return (data as BinaryFileData).bytes;
  }

  @override
  Future<String> readAsString() async {
    return (data as StringFileData).contents;
  }
}
