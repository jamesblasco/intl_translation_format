library extract_to_xliff;

import 'package:petitparser/petitparser.dart';

// Only valid for this use case

class MultipleLanguageJsonParser {
  Parser<String> get _openCurly => char('{');
  Parser<String> get _closeCurly => char('}');
  Parser<String> get _doubleQuotes => char('"');
  Parser<String> get _safeDoubleQuotes => string('\\"');
  Parser<String> get _colon => string(':');
  Parser<String> get _comma => string(',');

  Parser get _string =>
      (_safeDoubleQuotes | _doubleQuotes.neg()).star().flatten();

  Parser<String> get _stringWithDoubleQuotes =>
      (_doubleQuotes & _string.optional() & _doubleQuotes)
          .map((value) => value[1]);

  Parser<MapEntry<String, T>> _mapEntry<T>(Parser<T> value,
      {bool isLast = false}) {
    final comma = isLast ? _comma.optional() : _comma;
    final parser =
        _stringWithDoubleQuotes & _colon.trim() & value & comma.trim();
    return parser.map((value) => MapEntry(value[0], value[2]));
  }

  Parser<Map<String, T>> _map<T>(Parser<T> value) {
    final parser = _mapEntry(value).star().trim() &
        _mapEntry(value, isLast: true).optional().trim();
    return parser.map((value) {
      final list = [...value[0], value[1]].where((element) => element != null);
      print(list);
      final entries = List<MapEntry<String, T>>.from(list);
      return Map.fromEntries(entries);
    });
  }

  Parser<Map<String,T>> _object<T>(Parser<T> value) =>
      (_openCurly.trim() & _map(value).optional() & _closeCurly.trim())
          .map((value) => value[1]);

  Parser<Map<String, Map<String, String>>> get parser =>
      _object(_object(_stringWithDoubleQuotes));

  Map<String, Map<String, String>> parse(String content) {
    return parser.parse(content).value;
  }
}

void main(List<String> args) {
  final parser = MultipleLanguageJsonParser();
  final id1 = parser.parser.parse('''
   { 
    "a": { 
    "a":"a",
    "b":"a",
   },
    "b": { 
    "a":"a",
    "b":"a",
   },
   }
  ''');
  if (id1.isFailure) {
    print(id1.message);
  } else {
    print(id1.value);
  }
}
