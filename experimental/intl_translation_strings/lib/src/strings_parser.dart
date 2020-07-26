import 'package:petitparser/petitparser.dart';
class SimpleStringsParser {
  Parser<String> get _doubleQuotes => char('"');
  Parser<String> get _safeDoubleQuotes => string('\\"');
  Parser<String> get _equal => string('=');
  Parser<String> get _semicolon => string(';');

  Parser get _string =>
      (_safeDoubleQuotes | _doubleQuotes.neg()).star().flatten();

  Parser get _stringWithDoubleQuotes =>
      (_doubleQuotes & _string.optional() & _doubleQuotes)
          .map((value) => value[1]);

  Parser<MapEntry<String, String>> _mapEntry() {
    final parser = _stringWithDoubleQuotes &
        _equal.trim() &
        _stringWithDoubleQuotes &
        _semicolon.trim();

    return parser.map((value) => MapEntry(value[0], value[2]));
  }

  Parser<Map<String, String>> get _map {
    final parser = _mapEntry().star().trim();
    return parser.map((value) {
      final entries = List<MapEntry<String, String>>.from(value);
      return Map.fromEntries(entries);
    });
  }

  Parser get _object => _map.optional().trim();

  Parser<Map<String, String>> get parser => _object;

  Map<String, String> parse(String content) {
    return parser.parse(content).value;
  }
}
