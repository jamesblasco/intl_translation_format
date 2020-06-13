import 'dart:typed_data';

import '../file_reference.dart';

class LocalFile extends FileReference {
  final String path;

  LocalFile(this.path) {
    throw UnimplementedError(
        'LocalFile is not available in your current platform.');
  }

  @override
  String get name => throw UnimplementedError();

  @override
  Future<Uint8List> readAsBytes() async {
    throw UnimplementedError(
        'LocalFile is not available in your current platform.');
  }

  @override
  Future<String> readAsString() async {
    throw UnimplementedError(
        'LocalFile is not available in your current platform.');
  }

  @override
  Future writeAsBytes(Uint8List bytes) async {
    throw UnimplementedError(
        'LocalFile is not available in your current platform.');
  }

  @override
  Future writeAsString(String contents) async {
    throw UnimplementedError(
        'LocalFile is not available in your current platform.');
  }
}
