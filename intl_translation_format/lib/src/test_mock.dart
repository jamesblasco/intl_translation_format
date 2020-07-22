

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:petitparser/petitparser.dart';
import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation/src/intl_message.dart';


MainMessage simpleMessage(String key, String text, {String description}) {
  final mainMessage = MainMessage();
  mainMessage.id = key;
  mainMessage.name = key;
  mainMessage.arguments = [];
  mainMessage.description = description;
  final message = LiteralString(text, mainMessage);
  mainMessage.addPieces([message]);
  return mainMessage;
}

MainMessage simpleMessageWithVariable(
  String key,
  String text,
  String variableName, {
  String description,
}) {
  final mainMessage = MainMessage();
  mainMessage.id = key;
  mainMessage.name = key;
  mainMessage.arguments = [variableName];
  mainMessage.description = description;
  final message = messageParser.parse(text).value as Message;

  message.parent = mainMessage;
  mainMessage.addPieces([message]);
  return mainMessage;
}

MainMessage pluralMessage(String key, String text, String argument,
    {String description}) {
  final mainMessage = MainMessage()
    ..id = key
    ..name = key
    ..arguments = []
    ..description = description;
  mainMessage.arguments = [argument];
  final message = messageParser.parse(text).value as Message;
  message.parent = mainMessage;
  mainMessage.addPieces([message]);
  return mainMessage;
}

class MockTemplate extends TranslationTemplate {
  MockTemplate(
    String projectName,
    this.messages, {
    String locale = 'en',
  }) : super(
          projectName,
          locale: locale,
        );
  @override
  final Map<String, MainMessage> messages;
}

Parser get messageParser {
  final IcuParser parser = IcuParser();

  return (parser.pluralOrGenderOrSelect | parser.simpleText | parser.empty)
      .map((chunk) => Message.from(chunk, null));
}
