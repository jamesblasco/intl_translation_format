library intl_translation_json;

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_json/src/json_format.dart';
import 'package:intl_translation_json/src/multi_json_format.dart';

export 'package:intl_translation_json/src/json_format.dart';

final jsonFormats = <String, TranslationFormatBuilder>{
  JsonFormat.key: () => JsonFormat(),
  MultiJsonFormat.key: () => MultiJsonFormat(),
};

Map<Set<String>, T> foldMap<T>(Map<String, Object> map) {
  final newMap = <Set<String>, T>{};

  void iterateEntries(Map<String, Object> map, {Set<String> keys}) {
    map.forEach((key, value) {
      final newKey = Set<String>.from(keys ?? {})..add(key);
      if (value is Map<String, Object>) {
        iterateEntries(value, keys: newKey);
      } else if (key is String && value is T) {
        newMap[newKey] = value;
      } else if (key is! String) {
        throw BadFormatException(
            '$key is not a String. foldMap requires all map keys to be a String');
      } else {
        throw BadFormatException(
            'Invalid item with key $key. $value is not a subtype of type $T');
      }
    });
  }

  iterateEntries(map);
  return newMap;
}
