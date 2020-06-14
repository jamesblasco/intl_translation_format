import 'dart:developer';
import 'dart:typed_data';

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:http/http.dart' as http;



class NetworkFile extends FileProvider {
  final String url;
  final String name;

  NetworkFile(this.url, this.name);

  @override
  Future<Uint8List> readAsBytes() async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      log('Request failed with status: ${response.statusCode}.');
    }

    return null;
  }

  @override
  Future<String> readAsString() async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      log(response.body);
      return response.body;
    } else {
      log('Request failed with status: ${response.statusCode}.');
    }
    return null;
  }

  @override
  Future writeAsBytes(Uint8List bytes) async {}

  @override
  Future writeAsString(String content) async {}
}
