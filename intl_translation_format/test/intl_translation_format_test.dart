import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test.dart';

import 'package:test/test.dart';

dynamic expectExtractedMessages(
    String fileContent, Map<String, String> messages) async {
  final file = MockFile(StringFileData(fileContent, 'main.dart'));
  final template = TranslationTemplate('intl');
  await template.addTemplateMessages([file]);
  final result = template.messages.map(
    (key, value) => MapEntry(key, messageToIcuString(value)),
  );

  expect(result, messages);
}

void main() {
  test('Extract Simple Message', () async {
    final fileContent = '''
    final String simpleMessage = Intl.message('Simple Message', name: 'simpleMessage');
    ''';
    await expectExtractedMessages(fileContent, {
      'simpleMessage': 'Simple Message',
    });
  });
 test('Extract Simple Message', () async {
    final fileContent = '''
class Test {
   static final String simpleMessage = Intl.message('Simple Message', name: 'simpleMessage');
}
    ''';
    await expectExtractedMessages(fileContent, {
      'simpleMessage': 'Simple Message',
    });
  });

  test('Extract Simple Message - 2', () async {
    final fileContent = '''
    final String simpleMessage = Intl.message('Simple Message');
    ''';
    await expectExtractedMessages(fileContent, {
      'simpleMessage': 'Simple Message',
    });
  });

  test('Extract Message with Variable', () async {
    final fileContent = '''
    String variable(int variable) =>
    Intl.message('Hello \$variable', name: 'variable', args: [variable]);
    ''';
    await expectExtractedMessages(fileContent, {
      'variable': 'Hello {variable}',
    });
  });

  test('Extract Plural Message', () async {
    final fileContent = '''
    String pluralExample(int howMany) => Intl.plural(howMany,
    zero: 'No items',
    one: 'One item',
    many: 'A lot of items',
    other: '\$howMany items',
    name: 'pluralExample',
    args: [howMany]);
    ''';

    // Todo: intl_translation should implement toString in Plurals and Genders
    await expectExtractedMessages(fileContent, {
      'pluralExample':
          '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}'
    });
  });

  test('Extract Embeded Plural Message', () async {
    final fileContent = '''
    String embedded(int howMany) => Intl.message(
      'Embedded Plural: \${Intl.plural(
      howMany,
      zero: 'No items',
      one: 'One item',
      many: 'A lot of items',
      other: '\$howMany items',
    )}',
      args: [howMany],
      name: 'embedded',
    );
    ''';
    await expectExtractedMessages(fileContent, {
      'embedded':
          'Embedded Plural: {howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}'
    });
  });
  test('Extract Embeded Plural Message', () async {
    final fileContent = '''
   embeddedPlural2(n) => Intl.message(
    "\${Intl.plural(n, zero: 'none', one: 'one', other: 'some')} plus text.",
    name: 'embeddedPlural2', desc: 'An embedded plural', args: [n]);
    ''';
    await expectExtractedMessages(fileContent, {
      'embeddedPlural2': '{n,plural, =0{none}=1{one}other{some}} plus text.',
    });
  });

  
   test('Extract Embeded Plural Message', () async {
    final fileContent = '''
   embeddedPlural2(n) => Intl.message(
    "\${Intl.plural(n, zero: 'none', one: 'one', other: 'some')} plus text.",
    name: 'embeddedPlural2', desc: 'An embedded plural', args: [n]);
    ''';
    await expectExtractedMessages(fileContent, {
      'embeddedPlural2': '{n,plural, =0{none}=1{one}other{some}} plus text.',
    });
  });

}

