
import 'package:petitparser/petitparser.dart';



class SimpleJsonParser {
  Parser<String> get _openCurly => char('{');
  Parser<String> get _closeCurly => char('}');
  Parser<String> get _doubleQuotes => char('"');
  Parser<String> get _safeDoubleQuotes => string('\\"');
  Parser<String> get _colon => string(':');
  Parser<String> get _comma => string(',');

  Parser get _string =>
      (_safeDoubleQuotes | _doubleQuotes.neg()).star().flatten();

  Parser get _stringWithDoubleQuotes =>
      (_doubleQuotes & _string.optional() & _doubleQuotes)
          .map((value) => value[1]);

  Parser<MapEntry<String, String>> _mapEntry({bool isLast = false}) {
    final comma = isLast ? _comma.optional() : _comma;
    final parser = _stringWithDoubleQuotes &
        _colon.trim() &
        _stringWithDoubleQuotes &
        comma.trim();
    return parser.map((value) => MapEntry(value[0], value[2]));
  }

  Parser<Map<String, String>> get _map {
    final parser =
        _mapEntry().star().trim() & _mapEntry(isLast: true).optional().trim();
    return parser.map((value) {
      final list = [...value[0], value[1]].where((element) => element != null);
      final entries = List<MapEntry<String, String>>.from(list);
      return Map.fromEntries(entries);
    });
  }

  Parser get _object =>
      _openCurly.trim() & _map.optional() & _closeCurly.trim();

  Parser<Map<String, String>> get parser => _object.map((value) => value[1]);

  Map<String, String> parse(String content) {
    return parser.parse(content).value;
  }
}
