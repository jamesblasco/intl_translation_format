import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test_utils.dart';
import 'package:test/test.dart';

main() {
  group('Format to Arb  -', () {
    test('Simple message', () {
      final messsage = () {
        final MainMessage message = MainMessage();
        message
          ..name = 'message1'
          ..arguments = []
          ..addPieces([LiteralString('This is a message', message)]);
        return message;
      }();
      expectContentForMessages(
        '{\n'
        '  "@@locale": "en",\n'
        '  "message1": "This is a message",\n'
        '  "@message1": {\n'
        '    "type": "text",\n'
        '    "placeholders": {},\n'
        '    "source_text": "This is a message"\n'
        '  }\n'
        '}',
        ArbFormat(),
        messages: {
          'message1': messsage,
        },
      );
    });

    test('Extract simple message with parameter', () {
      final messsage = () {
        final MainMessage message = MainMessage();
        message
          ..name = 'message2'
          ..arguments = ['x']
          ..description = 'Description2'
          ..examples = {
            'x': 3,
          }
          ..addPieces([
            LiteralString('Another message with parameter ', message),
            VariableSubstitution.named('x', message)
          ]);
        return message;
      }();
      expectContentForMessages(
        '{\n'
        '  "@@locale": "en",\n'
        '  "message2": "Another message with parameter {x}",\n'
        '  "@message2": {\n'
        '    "description": "Description2",\n'
        '    "type": "text",\n'
        '    "placeholders": {\n'
        '      "x": {\n'
        '        "example": 3\n'
        '      }\n'
        '    },\n'
        '    "source_text": "Another message with parameter {x}"\n'
        '  }\n'
        '}',
        ArbFormat(),
        messages: {
          'message2': messsage,
        },
      );
    });

    test('Message with wierd characters and no name', () {
      final messsage = () {
        final MainMessage message = MainMessage();
        message
          ..name = "'<>{}= +-_\$()&^%\$#@!~`'"
          ..arguments = []
          ..description = 'interesting characters'
          ..addPieces([
            LiteralString('<>{}= +-_\$()&^%\$#@!~`', message),
          ]);
        return message;
      }();
      expectContentForMessages(
        '{\n'
        '  "@@locale": "en",\n'
        '  "\'<>{}= +-_\$()&^%\$#@!~`\'": "<>{}= +-_\$()&^%\$#@!~`",\n'
        '  "@\'<>{}= +-_\$()&^%\$#@!~`\'": {\n'
        '    "description": "interesting characters",\n'
        '    "type": "text",\n'
        '    "placeholders": {},\n'
        '    "source_text": "<>{}= +-_\$()&^%\$#@!~`"\n'
        '  }\n'
        '}',
        ArbFormat(),
        messages: {
          'message2': messsage,
        },
      );
    });

    test('Message with outer plural', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String outerPlural(n) => Intl.plural(n,
        zero: 'none',
        one: 'one',
        other: 'some',
        name: 'outerPlural',
        desc: 'A plural with no enclosing message',
        args: [n]);
    ''', 'example.dart');

      final message = messages['outerPlural'];
      expect(message.name, 'outerPlural');
      expect(message.arguments, ['n']);

      expect(messageToIcuString(message),
          '{n,plural, =0{none}=1{one}other{some}}');
    });

    test('Message with outer gender', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String outerGender(g) => Intl.gender(g,
      male: 'm',
      female: 'f',
      other: 'o',
      name: 'outerGender',
      desc: 'A gender with no enclosing message',
      args: [g]);
    ''', 'example.dart');

      final message = messages['outerGender'];
      expect(message.name, 'outerGender');
      expect(message.arguments, ['g']);

      expect(
          messageToIcuString(message), '{g,select, female{f}male{m}other{o}}');
    });

    test('Gender message without name or args', () {
      // A standalone gender message where we don't provide name or args. This should
      // be rejected by validation code.
      final extraction = MessageExtraction();
      extraction.parseContent('''
    String invalidOuterGender(g) => Intl.gender(
      g,
      other: 'o',
      desc: "Invalid outer gender",
    );
    ''', 'example.dart');

      expect(extraction.warnings, [
        '''
Skipping invalid Intl.message invocation
    <Intl.gender(g, other: 'o', desc: "Invalid outer gender")>
    reason: The 'args' argument for Intl.message must be specified for messages with parameters. Consider using rewrite_intl_messages.dart
    from example.dart    line: 1, column: 37'''
      ]);
    });

    test('Gender message without name or args', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(r'''
    String outerSelect(currency, amount) => Intl.select(
          currency,
          {
            "CDN": "$amount Canadian dollars",
            "other": "$amount some currency or other."
          },
          name: "outerSelect",
          desc: "Select",
          args: [currency, amount],
        );
    ''', 'example.dart');

      final message = messages['outerSelect'];
      expect(message.name, 'outerSelect');
      expect(message.arguments, ['currency', 'amount']);
      expect(messageToIcuString(message),
          '{currency,select, CDN{{amount} Canadian dollars}other{{amount} some currency or other.}}');
    });

    test('Invalid select message', () {
      final extraction = MessageExtraction();
      extraction.parseContent('''
    String failedSelect(currency) => Intl.select(
      currency,
      {"this.should.fail": "not valid", "other": "doesn't matter"},
      name: "failedSelect",
      args: [currency],
      desc: "Invalid select",
    );
    ''', 'example.dart');
      expect(extraction.warnings.first, '''
Error IntlMessageExtractionException: Invalid select keyword: 'this.should.fail', must match '[a-zA-Z][a-zA-Z0-9_-]*'
Processing <Intl.select(currency, {"this.should.fail" : "not valid", "other" : "doesn't matter"}, name: "failedSelect", args: [currency], desc: "Invalid select")>    from example.dart    line: 1, column: 38''');
    });

    // There is an error with nested select and plurals in intl_translation
    // and this test fails.
    /* test('Nested select and plural message without interpolation', () {
      // A trivial nested plural/gender where both are done directly rather than
      // in interpolations.
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(r'''
    String nestedOuter(number, gen) => Intl.plural(number,
        other: Intl.gender(gen, male: "$number male", other: "$number other"),
        name: 'nestedOuter',
        args: [number, gen],
        desc: "Gender inside plural");
    ''', 'example.dart');

      final message = messages['nestedOuter'];
      expect(message.name, 'nestedOuter');
      expect(message.arguments, ['number', 'gen']);
      //print(icuMessageToString(message));
      expect(messageToIcuString(message),
          '{number,plural, other{{gen, select .....}}}');
    }); */

    test('Messages with same content and differentName', () {
      // A trivial nested plural/gender where both are done directly rather than
      // in interpolations.
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
   String sameContentsDifferentName() => Intl.message(
      "Hello World",
      name: "sameContentsDifferentName",
      desc: "One of two messages with the same contents, but different names",
    );

String differentNameSameContents() => Intl.message("Hello World",
    name: "differentNameSameContents",
    desc: "One of two messages with the same contents, but different names");

    ''', 'example.dart');

      final message = messages['sameContentsDifferentName'];
      expect(message.name, 'sameContentsDifferentName');
      expect(messageToIcuString(message), 'Hello World');

      final message2 = messages['differentNameSameContents'];
      expect(message2.name, 'differentNameSameContents');
      expect(messageToIcuString(message2), 'Hello World');
    });

    test('Messages with same content, different name and meaning', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String rentToBePaid() => Intl.message("rent",
    name: "rentToBePaid",
    meaning: 'Money for rent',
    desc: "Money to be paid for rent");

String rentAsVerb() => Intl.message("rent",
    name: "rentAsVerb",
    meaning: 'rent as a verb',
    desc: "The action of renting, as in rent a car");
''', 'example.dart');

      final message = messages['rentToBePaid'];
      expect(message.name, 'rentToBePaid');
      expect(message.meaning, 'Money for rent');
      expect(messageToIcuString(message), 'rent');

      final message2 = messages['rentAsVerb'];
      expect(message2.name, 'rentAsVerb');
      expect(message2.meaning, 'rent as a verb');
      expect(messageToIcuString(message2), 'rent');
    });

    test('Messages with literal dollar', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(r'''
String literalDollar() => Intl.message(
      "Five cents is US\$0.05",
      name: "literalDollar",
      desc: "Literal dollar sign with valid number",
    );
''', 'example.dart');

      final message = messages['literalDollar'];
      expect(message.name, 'literalDollar');
      expect(messageToIcuString(message), 'Five cents is US\$0.05');
    });

    test('Messages should extract', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String extractable() => Intl.message(
      'This message should be extractable',
      name: "extractable",
      skip: false,
      desc: "Not skipped message",
    );
''', 'example.dart');

      final message = messages['extractable'];
      expect(message.name, 'extractable');
      expect(messageToIcuString(message), 'This message should be extractable');
    });

    test('Skip Messages', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String skipMessage() => Intl.message(
      'This message should skip extraction',
      skip: true,
      desc: "Skipped message",
    );
''', 'example.dart');
      expect(messages.length, 0);
    });

    test('Skip Plural Messages', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String skipPlural(n) => Intl.plural(n,
    zero: 'Extraction skipped plural none',
    one: 'Extraction skipped plural one',
    other: 'Extraction skipped plural some',
    name: 'skipPlural',
    desc: 'A skipped plural',
    args: [n],
    skip: true);    
''', 'example.dart');
      expect(messages.length, 0);
    });

    test('Skip Gender Messages', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String skipGender(g) => Intl.gender(g,
    male: 'Extraction skipped gender m',
    female: 'Extraction skipped gender f',
    other: 'Extraction skipped gender o',
    name: 'skipGender',
    desc: 'A skipped gender',
    args: [g],
    skip: true);   
''', 'example.dart');
      expect(messages.length, 0);
    });

    test('Skip Select Messages', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
String skipSelect(name) => Intl.select(
    name,
    {
      "Bob": "Extraction skipped select specified Bob!",
      "other": "Extraction skipped select other \$name"
    },
    name: "skipSelect",
    desc: "Skipped select",
    args: [name],
    skip: true);    
''', 'example.dart');
      expect(messages.length, 0);
    });
  });

  group('findMessages denied usages', () {
    test('fails with message on non-literal examples Map', () {
      final extraction = MessageExtraction();
      extraction.parseContent('''
final variable = 'foo';

String message(String string) =>
    Intl.select(string, {'foo': 'foo', 'bar': 'bar'},
        name: 'message', args: [string], examples: {'string': variable});
      ''', 'test.dart');

      expect(extraction.warnings,
          anyElement(contains('Examples must be a const Map literal.')));
    });

    test('fails with message on prefixed expression in interpolation', () {
      final extraction = MessageExtraction();
      extraction.parseContent(
        'String message(object) => Intl.message("\${object.property}", args: [object], name: "message");',
        '',
      );
      expect(
          extraction.warnings,
          anyElement(
              contains('Only simple identifiers and Intl.plural/gender/select '
                  'expressions are allowed in message interpolation '
                  'expressions')));
    });

    test('fails on call with name referencing variable name inside a function',
        () {
      final extraction = MessageExtraction();
      extraction.parseContent('''
      class MessageTest {
        String functionName() {
          final String variableName = Intl.message('message string',
            name: 'variableName' );
        }
      }''', 'main.dart');

      expect(
          extraction.warnings,
          anyElement(contains('The \'name\' argument for Intl.message '
              'must match either the name of the containing function '
              'or <ClassName>_<methodName>')));
    });

    test('fails on referencing a name from listed fields declaration', () {
      final extraction = MessageExtraction();
      extraction.parseContent('''
      class MessageTest {
        String first, second = Intl.message('message string',
            name: 'first' );
      }''', 'main.dart');

      expect(
          extraction.warnings,
          anyElement(contains('The \'name\' argument for Intl.message '
              'must match either the name of the containing function '
              'or <ClassName>_<methodName>')));
    });
  });

  group('findMessages accepted usages', () {
    test('succeeds on Intl call from class getter', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        String get messageName => Intl.message("message string",
          name: 'messageName', desc: 'abc');
      }''', 'main.dart');

      expect(messages.values.map((m) => m.name),
          anyElement(contains('messageName')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on Intl call in top variable declaration', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(
          'List<String> list = [Intl.message("message string", '
              'name: "list", desc: "in list")];',
          'main.dart');

      expect(messages.values.map((m) => m.name), anyElement(contains('list')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on Intl call in member variable declaration', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        final String messageName = Intl.message("message string",
          name: 'MessageTest_messageName', desc: 'test');
      }''', 'main.dart');

      expect(messages.values.map((m) => m.name),
          anyElement(contains('MessageTest_messageName')));
      expect(extraction.warnings, isEmpty);
    });

    // Note: this type of usage is not recommended.
    test('succeeds on Intl call inside a function as variable declaration', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        String functionName() {
          final String variableName = Intl.message('message string',
            name: 'functionName', desc: 'test' );
        }
      }''', 'main.dart');

      expect(messages.values.map((m) => m.name),
          anyElement(contains('functionName')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on list field declaration', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        String first, second = Intl.message('message string', desc: 'test');
      }''', 'main.dart');

      expect(messages.values.map((m) => m.name),
          anyElement(contains('message string')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on prefixed Intl call', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        static final String prefixedMessage =
            prefix.Intl.message('message', desc: 'xyz');
      }
      ''', 'main.dart');

      expect(
          messages.values.map((m) => m.name), anyElement(contains('message')));
      expect(extraction.warnings, isEmpty);
    });
  });
}
