import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// File abstraction that can be read and written
///
/// A FileProvider instance is an object that holds a [name] on which operations can
/// be performed.
///
/// See related [LocalFile], [MockFile]
abstract class FileProvider with ReadableFile, WritableFile {
  @override
  String get name;

  FileProvider();
}

/// File abstraction that can be read
abstract class ReadableFile {
  String get name;

  Future<String> readAsString();
  Future<Uint8List> readAsBytes();

  Future<T> readDataOfExactType<T extends FileData>() async {
    final type = FileData.dataTypeForDataOfExactType<T>();
    return await read(type) as T;
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

/// File abstraction that can be written
abstract class WritableFile {
  Future writeAsString(String content);

  Future writeAsBytes(Uint8List bytes);

  Future write(FileData data) async {
    if (data?.type == FileDataType.text) {
      return await writeAsString(data._contents);
    } else if (data?.type == FileDataType.binary) {
      return await writeAsBytes(data._bytes);
    }
    throw UnimplementedError(
        'Write not supported for file type ${data?.type}.');
  }
}

enum FileDataType { text, binary }

/// File data that can be stored in text or binary
/// See related [StringFileData], [BinaryFileData]
class FileData {
  final String name;
  String get extension => p.extension(name);
  String get nameWithoutExtension => p.basenameWithoutExtension(name);

  final Uint8List _bytes;
  final String _contents;

  final Encoding encoding;

  static FileDataType dataTypeForDataOfExactType<T extends FileData>() => {
        StringFileData: FileDataType.text,
        BinaryFileData: FileDataType.binary,
      }[T];

  final FileDataType type;

  FileData._(
    String content,
    this.name, {
    this.encoding = utf8,
  })  : _bytes = null,
        _contents = content,
        type = FileDataType.text;

  FileData._binary(
    Uint8List bytes,
    this.name, {
    this.encoding = utf8,
  })  : _bytes = bytes,
        _contents = null,
        type = FileDataType.binary;
}

/// File data that is stored as text
class StringFileData extends FileData {
  String get contents => _contents;
  final Encoding encoding;

  static final FileDataType dataType = FileDataType.text;
  final FileDataType type = FileDataType.text;

  StringFileData(
    String contents,
    String basename, {
    this.encoding = utf8,
  }) : super._(contents, basename, encoding: encoding);
}

/// File data that is stored as bytes
class BinaryFileData extends FileData {
  Uint8List get bytes => _bytes;

  final Encoding encoding;

  static final FileDataType dataType = FileDataType.binary;
  final FileDataType data = FileDataType.binary;

  BinaryFileData(
    Uint8List bytes,
    String basename, {
    this.encoding = utf8,
  }) : super._binary(bytes, basename, encoding: encoding);
}
