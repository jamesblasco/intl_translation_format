import 'dart:io';
import 'dart:typed_data';

import 'file_provider.dart';
import 'package:path/path.dart' as p;

///  A reference to a file on the file system.
class LocalFile extends FileProvider {
  final String path;

  LocalFile(this.path);

  @override
  String get name => p.basename(path);

  @override
  Future<Uint8List> readAsBytes() => File(path).readAsBytes();

  @override
  Future<String> readAsString() => File(path).readAsString();

  @override
  Future writeAsBytes(Uint8List bytes) => File(path).writeAsBytes(bytes);

  @override
  Future writeAsString(String contents) => File(path).writeAsString(contents);
}
