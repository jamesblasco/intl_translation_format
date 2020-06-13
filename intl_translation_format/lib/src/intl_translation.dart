
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'models/translation_format.dart';

Map<String, List<MainMessage>> originalMessage = {};


/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class BasicTranslatedMessage extends TranslatedMessage {
  BasicTranslatedMessage(String name, translated) : super(name, translated);

  List<MainMessage> get originalMessages => (super.originalMessages == null)
      ? _findOriginals()
      : super.originalMessages;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  List<MainMessage> _findOriginals() => originalMessages = originalMessage[id];
}



class IntlTranslation {
  @deprecated
  static String extractMessages(
      {TranslationFormat format,
      String locale,
      List<String> dartFiles,
      MessageExtraction messageExtraction}) {
    throw 'Deprecated ';
  }

  @deprecated
  static Map<String, String> generateTranslations(
      {TranslationFormat format,
      String locale,
      List<String> dartFiles,
      List<String> translationFiles,
      String targetDir,
      MessageExtraction messageExtraction,
      MessageGeneration messageGeneration}) {
    throw 'Deprecated ';
  }
}
