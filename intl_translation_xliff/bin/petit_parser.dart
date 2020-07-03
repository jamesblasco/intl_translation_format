library extract_to_xliff;

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';
import 'package:intl_translation/src/intl_message.dart';

// Only valid for this use case


class SimpleStringsParser {
  Parser<String> get _doubleQuotes => char('"');
  Parser<String> get _safeDoubleQuotes => string('\\"');
  Parser<String> get _colon => string('=');
  Parser<String> get _comma => string(';');

  Parser get _string =>
      (_safeDoubleQuotes | _doubleQuotes.neg()).star().flatten();

  Parser get _stringWithDoubleQuotes =>
      (_doubleQuotes & _string.optional() & _doubleQuotes)
          .map((value) => value[1]);

  Parser<MapEntry<String, String>> _mapEntry() {
    final parser = _stringWithDoubleQuotes &
        _colon.trim() &
        _stringWithDoubleQuotes &
        _comma.trim();

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

  Parser<Map<String, T>> _object<T>(Parser<T> value) =>
      (_openCurly.trim() & _map(value).optional() & _closeCurly.trim())
          .map((value) => value[1]);

  Parser<Map<String, Map<String, String>>> get parser =>
      _object(_object(_stringWithDoubleQuotes));

  Map<String, Map<String, String>> parse(String content) {
    return parser.parse(content).value;
  }
}

void main(List<String> args) {
  final parser = SimpleStringsParser();
  final id1 = parser.parser.parse('''
   "a" = "b";
   "c" = "b";
  ''');
  if (id1.isFailure) {
    print(id1.message);
  } else {
    print(id1.value);
  }
}

/* 
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
 */ /* 
void main(List<String> args) {
  final document = XmlDocument.parse(contentToParse);

  final textual = document.descendants
      .whereType<XmlElement>()
      .where((node) => node.name.local == 'unit')
      .map((node) {
        final id = node.getAttribute('id');

        final segment = node.getElement('segment');
        var message = segment?.getElement('target')?.innerText;
        message ??= segment?.getElement('source')?.innerText;

        if (message == null) return null;

        return BasicTranslatedMessage(id, Message.from(message, null));
      })
      .where((element) => element != null)
      .join('\n');
  print(textual);
}

const contentToParse = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="text" name="text">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>text</source>
      </segment>
    </unit>
    <unit id="textWithMetadata" name="textWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>textWithMetadata</source>
      </segment>
    </unit>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
  </file>
</xliff>
''';
 */
