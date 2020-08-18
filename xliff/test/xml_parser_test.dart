import 'package:intl_translation_xliff/src/parser/xml_parser.dart';
import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

void main() {
  group('Xml Parser', () {
    test('Unhandled element', () {
      final log = MockXmlParser().parse(
        '<?xml version="1.0 encoding="UTF-8""?><xliff></xliff>',
      );
      final expected = [
        'Unhandled element <xliff>',
      ];
      expect(log, expected);
    });

    test('Basic element', () {
      final log = MockXmlParser().parse(
          '<?xml version="1.0 encoding="UTF-8""?><basic></basic>',
          handlers: {
            'basic': () => BasicElement(),
          });
      final expected = [
        'Start Event <basic>',
        'End Event </basic>',
      ];
      expect(log, expected);
    });

    test('Element with required attribute - exception', () {
      expect(
        () => MockXmlParser().parse(
          '''
        <?xml version="1.0 encoding="UTF-8""?>
        <required-attribute>
        </required-attribute>
    ''',
          handlers: {
            'required-attribute': () => RequiredAttributeElement(),
          },
        ),
        throwsA(
          predicate((e) =>
              e is XmlParserException &&
              e.title == '\'att\' attribute is required for <required-attribute>'),
        ),
      );
    });

    test('Element with required attribute - success', () {
      final log = MockXmlParser().parse(
        '''
     <?xml version="1.0 encoding="UTF-8""?>
    <required-attribute att="example">
    </required-attribute>
    ''',
        handlers: {
          'required-attribute': () => RequiredAttributeElement(),
        },
      );
    
      final expected = [
        'Start Event <required-attribute>',
        'Attributes for <required-attribute>: {att: example}',
        'End Event </required-attribute>',
      ];
      expect(log, expected);
    });

    test('Ignored attributes waring', () {
      final log = MockXmlParser().parse('''
     <?xml version="1.0 encoding="UTF-8""?>
    <basic att="example">
    </basic>
    ''', handlers: {
        'basic': () => BasicElement(),
      }, key: 'test');
      final expected = [
        'Start Event <basic>',
        'Extra arguments att in <basic> will not be parsed',
        'End Event </basic>',
      ];
      expect(log, expected);
    });

    test('Element with optional attributes', () {
      final log = MockXmlParser().parse('''
     <?xml version="1.0 encoding="UTF-8""?>
    <optional att="example">
    </optional>
    ''', handlers: {
        'optional': () => OptionalAttributeElement(),
      }, key: 'test');
      final expected = [
        'Start Event <optional>',
        'Attributes for <optional>: {att: example}',
        'End Event </optional>',
      ];
      expect(log, expected);
    });

    test('One time Element - success', () {
      final log = MockXmlParser().parse('''
         <?xml version="1.0 encoding="UTF-8""?>
        <one-time></one-time>
        ''', handlers: {
        'one-time': () => OneTimeElement(),
      });
      final expected = [
        'Start Event <one-time>',
        'End Event </one-time>',
      ];
      expect(log, expected);
    });

    test('One time Element - exception', () {
      expect(
        () => MockXmlParser().parse(
          '''
         <?xml version="1.0 encoding="UTF-8""?>
          <one-time></one-time>
          <one-time></one-time>
        ''',
          handlers: {
            'one-time': () => OneTimeElement(),
          },
        ),
        throwsA(
          predicate((e) =>
              e is XmlParserException &&
              e.title == 'Multiple <one-time> elements are not allowed'),
        ),
      );
    });

    test('Multiple times Element - once', () {
      final log = MockXmlParser().parse('''
         <?xml version="1.0 encoding="UTF-8""?>
       <multiple-times></multiple-times>
        ''', handlers: {
        'multiple-times': () => MultipleTimesElement(),
      });
      final expected = [
        'Start Event <multiple-times>',
        'End Event </multiple-times>',
      ];
      expect(log, expected);
    });

    test('Multiple times Element - multiple', () {
      final log = MockXmlParser().parse('''
         <?xml version="1.0 encoding="UTF-8""?>
       <multiple-times></multiple-times>
       <multiple-times></multiple-times>
       <multiple-times></multiple-times>
        ''', handlers: {
        'multiple-times': () => MultipleTimesElement(),
      });
      final expected = [
        'Start Event <multiple-times>',
        'End Event </multiple-times>',
        'Start Event <multiple-times>',
        'End Event </multiple-times>',
        'Start Event <multiple-times>',
        'End Event </multiple-times>',
      ];
      expect(log, expected);
    });
  });
}

class MockXmlParser {
  final bool displayWarnings;

  MockXmlParser({
    this.displayWarnings = false,
  });

  List<String> parse(String str,
      {Map<String, ElementBuilder<String>> handlers = const {}, String key}) {
    return MockXmlParserState(parseEvents(str), key, displayWarnings, handlers)
        .parse();
  }
}

class MockXmlParserState extends XmlParserState<List<String>> {
  MockXmlParserState(Iterable<XmlEvent> events, String debugKey,
      bool displayWarnings, this.elementHandlers)
      : super(events, debugKey, displayWarnings: displayWarnings);

  @override
  Map<String, ElementBuilder<String>> elementHandlers;

  @override
  List<String> value = [];

  @override
  void warn(Object content) {
    value.add('$content');
    super.warn(content);
  }
}

abstract class MockElement extends Element<MockXmlParserState> {}

class BasicElement extends MockElement {
  @override
  String get key => 'basic';
}

class RequiredAttributeElement extends MockElement {
  @override
  String get key => 'required-attribute';

  @override
  Set<String> get requiredAttributes => {'att'};

  @override
  void onStart() {
    state.value.add('Attributes for <$key>: ${attributes}');
    super.onStart();
  }
}

class OptionalAttributeElement extends MockElement {
  @override
  String get key => 'optional';

  @override
  Set<String> get optionalAttributes => {'att'};

  @override
  void onStart() {
    state.value.add('Attributes for <$key>: ${attributes}');
    super.onStart();
  }
}

class OneTimeElement extends MockElement {
  @override
  String get key => 'one-time';

  @override
  bool get allowsMultiple => false;
}

class MultipleTimesElement extends MockElement {
  @override
  String get key => 'mulitple-times';

  @override
  bool get allowsMultiple => true;
}
