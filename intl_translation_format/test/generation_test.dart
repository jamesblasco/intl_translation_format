import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:test/test.dart';

void expectTranslatedMessages(
  List<String> files,
  Map<String, Map<String, String>> messagesByLocale,
  String locale,
) async {
  final template = TranslationCatalog('intl', locale: locale);

  final mainMessaages = messagesByLocale[locale].map(
    (name, message) => MapEntry(
        name,
        IcuMainMessage(message)
          ..name = name
          ..id = name),
  );

  template.messages.addAll(mainMessaages);
  template.originalMessage
      .addAll(mainMessaages.map((key, value) => MapEntry(key, [value])));

  for (final messagesForLocale in messagesByLocale.entries) {
    final translatedMessages = messagesForLocale.value.entries.map((e) {
      return BasicTranslatedMessage(e.key, IcuMessage.fromIcu(e.value));
    }).toList();
    template.translatedMessages[messagesForLocale.key] = translatedMessages;
  }
  final messages = template.generateDartMessages();
  for (final file in messages.asMap().entries) {
    if (file.key == messages.length - 1) {
      expect(file.value.contents, mainFileHeader(['en', 'es']));
    } else {
      expect(file.value.contents, files[file.key]);
    }
  }
}

localeFileHeader(String locale) =>
    '// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart\n'
    '// This is a library that provides messages for a $locale locale. All the\n'
    '// messages from the main program should be duplicated here with the same\n'
    '// function name.\n'
    '\n'
    '// Ignore issues from commonly used lints in this file.\n'
    '// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new\n'
    '// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering\n'
    '// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases\n'
    '// ignore_for_file:unused_import, file_names\n'
    '\n'
    'import \'package:intl/intl.dart\';\n'
    'import \'package:intl/message_lookup_by_library.dart\';\n'
    '\n';

String mainFileHeader(List<String> locales) => [
      '// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart\n'
          '// This is a library that looks up messages for specific locales by\n'
          '// delegating to the appropriate library.\n'
          '\n'
          '// Ignore issues from commonly used lints in this file.\n'
          '// ignore_for_file:implementation_imports, file_names, unnecessary_new\n'
          '// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering\n'
          '// ignore_for_file:argument_type_not_assignable, invalid_assignment\n'
          '// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases\n'
          '// ignore_for_file:comment_references\n'
          '\n'
          'import \'dart:async\';\n'
          '\n'
          'import \'package:intl/intl.dart\';\n'
          'import \'package:intl/message_lookup_by_library.dart\';\n'
          'import \'package:intl/src/intl_helpers.dart\';\n'
          '\n',
      for (final locale in locales)
        'import \'intl_messages_$locale.dart\' deferred as messages_$locale;\n',
      '\n'
          'typedef Future<dynamic> LibraryLoader();\n'
          'Map<String, LibraryLoader> _deferredLibraries = {\n',
      for (final locale in locales)
        '  \'$locale\': messages_$locale.loadLibrary,\n',
      '};\n'
          '\n'
          'MessageLookupByLibrary _findExact(String localeName) {\n'
          '  switch (localeName) {\n',
      for (final locale in locales)
        '    case \'$locale\':\n'
            '      return messages_$locale.messages;\n',
      '    default:\n'
          '      return null;\n'
          '  }\n'
          '}\n'
          '\n'
          '/// User programs should call this before using [localeName] for messages.\n'
          'Future<bool> initializeMessages(String localeName) async {\n'
          '  var availableLocale = Intl.verifiedLocale(\n'
          '    localeName,\n'
          '    (locale) => _deferredLibraries[locale] != null,\n'
          '    onFailure: (_) => null);\n'
          '  if (availableLocale == null) {\n'
          '    return new Future.value(false);\n'
          '  }\n'
          '  var lib = _deferredLibraries[availableLocale];\n'
          '  await (lib == null ? new Future.value(false) : lib());\n'
          '  initializeInternalMessageLookup(() => new CompositeMessageLookup());\n'
          '  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);\n'
          '  return new Future.value(true);\n'
          '}\n'
          '\n'
          'bool _messagesExistFor(String locale) {\n'
          '  try {\n'
          '    return _findExact(locale) != null;\n'
          '  } catch (e) {\n'
          '    return false;\n'
          '  }\n'
          '}\n'
          '\n'
          'MessageLookupByLibrary _findGeneratedMessagesFor(String locale) {\n'
          '  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,\n'
          '      onFailure: (_) => null);\n'
          '  if (actualLocale == null) return null;\n'
          '  return _findExact(actualLocale);\n'
          '}\n'
          '',
    ].join();

void main() {
  test('Simple Message', () async {
    final enContent = '${localeFileHeader('en')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'en\';\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "simpleMessage" : MessageLookupByLibrary.simpleMessage("Simple Message")\n'
        '  };\n'
        '}\n'
        '';
    final esContent = '${localeFileHeader('es')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'es\';\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "simpleMessage" : MessageLookupByLibrary.simpleMessage("Mensaje simple")\n'
        '  };\n'
        '}\n'
        '';

    await expectTranslatedMessages([
      enContent,
      esContent,
    ], {
      'en': {'simpleMessage': 'Simple Message'},
      'es': {'simpleMessage': 'Mensaje simple'},
    }, 'en');
  });

  test('Message with variable', () async {
    final enContent = '${localeFileHeader('en')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'en\';\n'
        '\n'
        '  static m0(variable) => "Hello \${variable}";\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "variable" : m0\n'
        '  };\n'
        '}\n'
        '';
    final esContent = '${localeFileHeader('es')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'es\';\n'
        '\n'
        '  static m0(variable) => "Hola \${variable}";\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "variable" : m0\n'
        '  };\n'
        '}\n'
        '';

    await expectTranslatedMessages([
      enContent,
      esContent,
    ], {
      'en': {
        'variable': 'Hello {variable}',
      },
      'es': {
        'variable': 'Hola {variable}',
      },
    }, 'en');
  });

  // There is a global state _methodNameCounter in intl_translation.
  // So when generating the method name it is different if the test
  // is running isolated or part of a group of test with Generation
  // https://github.com/dart-lang/intl_translation/blob/b20a558f049730d38f84bbf2f2084163ecddbcba/lib/generate_localized.dart#L488
  test('Message with plural', () async {
    final enContent = '${localeFileHeader('en')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'en\';\n'
        '\n'
        '  static m1(howMany) => "\${Intl.plural(howMany, zero: \'No items\', one: \'One item\', many: \'A lot of items\', other: \'\${howMany} items\')}";\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "pluralExample" : m1\n'
        '  };\n'
        '}\n'
        '';
    final esContent = '${localeFileHeader('es')}'
        'final messages = new MessageLookup();\n'
        '\n'
        'typedef String MessageIfAbsent(String messageStr, List<dynamic> args);\n'
        '\n'
        'class MessageLookup extends MessageLookupByLibrary {\n'
        '  String get localeName => \'es\';\n'
        '\n'
        '  static m1(howMany) => "\${Intl.plural(howMany, zero: \'Ningún elemento\', one: \'Un elemento\', many: \'Muchos elementos\', other: \'\${howMany} elementos\')}";\n'
        '\n'
        '  final messages = _notInlinedMessages(_notInlinedMessages);\n'
        '  static _notInlinedMessages(_) => <String, Function> {\n'
        '    "pluralExample" : m1\n'
        '  };\n'
        '}\n'
        '';

    await expectTranslatedMessages([
      enContent,
      esContent,
    ], {
      'en': {
        'pluralExample':
            '{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}'
      },
      'es': {
        'pluralExample':
            '{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}'
      },
    }, 'en');
  });
}
