import 'dart:convert';
import 'dart:typed_data';
export 'local/local_file.dart';
import 'package:path/path.dart' as p;

abstract class FileReference {
  String get name;

  const FileReference();
  Future writeAsString(String content);
  Future<String> readAsString();

  Future writeAsBytes(Uint8List bytes);
  Future<Uint8List> readAsBytes();

  Future write(FileData data) async {
    if (data?.type == FileDataType.text) {
      return await writeAsString(data._content);
    } else if (data?.type == FileDataType.binary) {
      return await writeAsBytes(data._bytes);
    }
    throw UnimplementedError(
        'Write not supported for file type ${data?.type}.');
  }

  Future<FileData> readDataOfExactType<T extends FileData>() async {
    final type = FileData.dataTypeForDataOfExactType<T>();
    if (type == FileDataType.text) {
      final content = await readAsString();
      return StringFileData(content, name);
    } else if (type == FileDataType.binary) {
      final bytes = await readAsBytes();
      return BinaryFileData(bytes, name);
    }
    throw UnimplementedError('Read not supported for file type $type.');
  }

  Future<FileData> read(FileDataType type) async {
    if (type == FileDataType.text) {
      final content = await readAsString();
      return StringFileData(content, name);
    } else if (type == FileDataType.binary) {
      final bytes = await readAsBytes();
      return BinaryFileData(bytes, name);
    }
    throw UnimplementedError('Read not supported for file type $type.');
  }
}

enum FileDataType { text, binary }

class FileData {
  final String name;
  String get extension => p.extension(name);
  String get nameWithoutExtension => p.basenameWithoutExtension(name);

  final Uint8List _bytes;
  Uint8List get bytes => _bytes;

  final String _content;
  String get contents => _content;
  final Encoding encoding;

  static FileDataType dataTypeForDataOfExactType<T extends FileData>() => {
        StringFileData: FileDataType.text,
        BinaryFileData: FileDataType.binary,
      }[T];

  FileDataType type;

  FileData._(
    String content,
    this.name, {
    this.encoding = utf8,
  })  : _bytes = null,
        _content = content;

  FileData._binary(
    Uint8List bytes,
    this.name, {
    this.encoding = utf8,
  })  : _bytes = bytes,
        _content = null;
}

class StringFileData extends FileData {
  final String content;
  final Encoding encoding;

  static final FileDataType dataType = FileDataType.text;
  final FileDataType type = FileDataType.text;

  StringFileData(
    this.content,
    String basename, {
    this.encoding = utf8,
  }) : super._(content, basename, encoding: encoding);
}

class BinaryFileData extends FileData {
  final Uint8List bytes;

  final Encoding encoding;

  static final FileDataType dataType = FileDataType.binary;
  final FileDataType data = FileDataType.binary;

  BinaryFileData(
    this.bytes,
    String basename, {
    this.encoding = utf8,
  }) : super._binary(bytes, basename, encoding: encoding);
}
