import 'dart:io';
import 'dart:typed_data';

import '../file_provider.dart';
import 'package:path/path.dart' as p;

class LocalFile extends FileProvider {
  final String path;

  LocalFile(this.path);

  @override
  String get name => p.basename(path);

  @override
  Future<Uint8List> readAsBytes() async => File(path).readAsBytesSync();

  @override
  Future<String> readAsString() async => File(path).readAsStringSync();

  @override
  Future writeAsBytes(Uint8List bytes) async =>
      File(path).writeAsBytesSync(bytes);

  @override
  Future writeAsString(String contents) async =>
      File(path).writeAsString(contents);
}