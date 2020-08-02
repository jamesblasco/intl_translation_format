import 'dart:math';

import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:test/test.dart';

main() {
  group('Extraction -', () {
    test('Extract simple message', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String message1() => Intl.message(
      'This is a message',
      name: 'message1',
      desc: 'foo',
    );
    ''', 'example.dart');
      expect(messages['message1'].name, 'message1');
      expect(messages['message1'].description, 'foo');
    });

    test('Extract message with adjacent string literals', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String message1() => Intl.message(
      'This is a message',
      name: 'mes' 'sage1',
      desc: 'Descr' 'iption',
    );
    ''', 'example.dart');
      expect(messages['message1'].name, 'message1');
      expect(messages['message1'].description, 'Description');
    });

    test('Extract simple message with parameter', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String message2(x) => Intl.message(
      'Another message with parameter \$x',
      name: 'message2',
      desc: 'Description2',
      args: [x],
      examples: const {'x': 3},
    );
    ''', 'example.dart');
      expect(messages['message2'].name, 'message2');
      expect(messages['message2'].description, 'Description2');
      expect(messages['message2'].arguments.first, 'x');
      expect(messages['message2'].examples['x'], 3);
    });

    // A string with multiple adjacent strings concatenated together, verify
    // that the parser handles this properly.
    test('Extract multiline message', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String multiLine() => Intl.message(
      "This "
      "string "
      "extends "
      "across "
      "multiple "
      "lines.",
      desc: "multi-line",
    );
    ''', 'example.dart');
      final message = messages['This string extends across multiple lines.'];
      expect(message.name, 'This string extends across multiple lines.');
      expect(message.description, 'multi-line');
      expect(message.messagePieces.map((e) => (e as LiteralString).string),
          ['This ', 'string ', 'extends ', 'across ', 'multiple ', 'lines.']);
    });

    test('Extract message with wierd characters and no name', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(r'''
    String get interestingCharactersNoName => Intl.message(
      "'<>{}= +-_\$()&^%\$#@!~`'",
      desc: "interesting characters",
    );
    ''', 'example.dart');
      final name = r"'<>{}= +-_$()&^%$#@!~`'";
      final message = messages[name];
      expect(message.name, name);
      expect(icuMessageToString(message), name);
    });

    test('Extract message with type variables ', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String types(int a, String b, List c) => Intl.message(
      "\$a, \$b, \$c",
      name: 'types',
      args: [a, b, c],
      desc: 'types',
    );
    ''', 'example.dart');
      final message = messages['types'];
      expect(message.name, 'types');
      expect(message.description, 'types');
      expect(icuMessageToString(message), '{a}, {b}, {c}');
      expect(message.arguments, ['a', 'b', 'c']);
    });

    test('Extract message always translated to fr', () {
      // This string will be printed with a French locale, so it will always show
      // up in the French version, regardless of the current locale.

      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String alwaysTranslated() => Intl.message(
      "This string is always translated",
      locale: 'fr',
      name: 'alwaysTranslated',
      desc: 'always translated',
    );
    ''', 'example.dart');
      final message = messages['alwaysTranslated'];
      expect(message.name, 'alwaysTranslated');
      expect(message.description, 'always translated');
      expect(message.locale, 'fr');
      expect(icuMessageToString(message), 'This string is always translated');
    });

    test('Extract message that contains interpolation with curly braces', () {
      // Test interpolation with curly braces around the expression, but it must
      // still be just a variable reference.
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String trickyInterpolation(s) => Intl.message(
      "Interpolation is tricky when it ends a sentence like \${s}.",
      name: 'trickyInterpolation',
      args: [s],
      desc: 'interpolation',
    );
    ''', 'example.dart');
      final message = messages['trickyInterpolation'];
      expect(message.name, 'trickyInterpolation');
      expect(message.description, 'interpolation');
      expect(message.arguments, ['s']);
      expect(icuMessageToString(message),
          'Interpolation is tricky when it ends a sentence like {s}.');
    });

    test('Message with leading quotes', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent(r'''
    String get leadingQuotes => Intl.message(
      "\"So-called\"",
      desc: "so-called",
    );
    ''', 'example.dart');
      final message = messages['"So-called"'];
      expect(message.name, '"So-called"');
      expect(message.description, 'so-called');
      expect(icuMessageToString(message), '"So-called"');
    });

    test('Message with characters not in the basic multilingual plane', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String originalNotInBMP() => Intl.message(
      "Ancient Greek hangman characters: 𐅆𐅇.",
      desc: "non-BMP",
    );
    ''', 'example.dart');
      final message = messages['Ancient Greek hangman characters: 𐅆𐅇.'];
      expect(message.name, 'Ancient Greek hangman characters: 𐅆𐅇.');
      expect(message.description, 'non-BMP');
      expect(icuMessageToString(message),
          'Ancient Greek hangman characters: 𐅆𐅇.');
    });

    test('Message with interpolation out of scope - ignored', () {
      // This is invalid and should be recognized as such, because the message has
      // to be a literal. Otherwise, interpolations would be outside of the function
      // scope.
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    final someString = "No, it has to be a literal string";
    String noVariables() => Intl.message(someString,
      name: "noVariables", desc: "Invalid. Not a literal");
    ''', 'example.dart');

      expect(messages.length, 0);
      expect(extraction.warnings.first, '''
Skipping invalid Intl.message invocation
    <Intl.message(someString, name: "noVariables", desc: "Invalid. Not a literal")>
    reason: Intl.message messages must be string literals
    from example.dart    line: 2, column: 29''');
    });

    test('Message with escapable charactesr', () {
      // This is unremarkable in English, but the translated versions will contain
      // characters that ought to be escaped during code generation.

      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String escapable() => Intl.message(
      "Escapable characters here: ",
      name: "escapable",
      desc: "Escapable characters",
    );
    ''', 'example.dart');

      final message = messages['escapable'];
      expect(message.name, 'escapable');
      expect(icuMessageToString(message), 'Escapable characters here: ');
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

      expect(icuMessageToString(message),
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
          icuMessageToString(message), '{g,select, female{f}male{m}other{o}}');
    });

    test('Message with plural that fails parsing', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
    String pluralThatFailsParsing(noOfThings) => Intl.plural(
      noOfThings,
      one: "1 thing:",
      other: "\$noOfThings things:",
      name: "pluralThatFailsParsing",
      args: [noOfThings],
      desc: "How many things are there?",
    );
    ''', 'example.dart');

      final message = messages['pluralThatFailsParsing'];
      expect(message.name, 'pluralThatFailsParsing');
      expect(message.arguments, ['noOfThings']);
      expect(icuMessageToString(message),
          '{noOfThings,plural, =1{1 thing:}other{{noOfThings} things:}}');
      throw 'Shouldnt this fail?';
    });

    test('Gender message without name or args', () {
      // A standalone gender message where we don't provide name or args. This should
      // be rejected by validation code.
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
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
      expect(icuMessageToString(message),
          '{currency,select, CDN{{amount} Canadian dollars}other{{amount} some currency or other.}}');
    });

    test('Invalid select message', () {
      final extraction = MessageExtraction();
      final messages = extraction.parseContent('''
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

    test('Nested select and plural message without interpolation', () {
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
      expect(icuMessageToString(message),
          '{number,plural, other{{gen, select .....}}}');
    });

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
      expect(icuMessageToString(message), 'Hello World');

      final message2 = messages['differentNameSameContents'];
      expect(message2.name, 'differentNameSameContents');
      expect(icuMessageToString(message2), 'Hello World');
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
      expect(icuMessageToString(message), 'rent');

      final message2 = messages['rentAsVerb'];
      expect(message2.name, 'rentAsVerb');
      expect(message2.meaning, 'rent as a verb');
      expect(icuMessageToString(message2), 'rent');
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
      expect(icuMessageToString(message), 'Five cents is US\$0.05');
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
      expect(icuMessageToString(message), 'This message should be extractable');
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
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent('''
final variable = 'foo';

String message(String string) =>
    Intl.select(string, {'foo': 'foo', 'bar': 'bar'},
        name: 'message', args: [string], examples: {'string': variable});
      ''', 'test.dart');

      expect(extraction.warnings,
          anyElement(contains('Examples must be a const Map literal.')));
    });

    test('fails with message on prefixed expression in interpolation', () {
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent(
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
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent('''
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
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent('''
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
      final extraction = new MessageExtraction();
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
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent(
          'List<String> list = [Intl.message("message string", '
              'name: "list", desc: "in list")];',
          'main.dart');

      expect(messages.values.map((m) => m.name), anyElement(contains('list')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on Intl call in member variable declaration', () {
      final extraction = new MessageExtraction();
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
      final extraction = new MessageExtraction();
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
      final extraction = new MessageExtraction();
      final messages = extraction.parseContent('''
      class MessageTest {
        String first, second = Intl.message('message string', desc: 'test');
      }''', 'main.dart');

      expect(messages.values.map((m) => m.name),
          anyElement(contains('message string')));
      expect(extraction.warnings, isEmpty);
    });

    test('succeeds on prefixed Intl call', () {
      final extraction = new MessageExtraction();
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
