import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:gettext_parser/gettext_parser.dart' as gettext;


class PoFormat extends MonoLingualFormat {
  static const key = 'po';

  @override
  String get fileExtension => 'po';

  @override
  String generateTemplateFile(
    TranslationTemplate catalog,
  ) {
   return gettext.po.compile({
      'charset': 'iso-8859-1',
      'headers': {
        'content-type': 'text/plain; charset=iso-8859-1',
        'plural-forms': 'nplurals=2; plural=(n!=1);'
      },
      'translations': {
        '': {
          'text': {
            'msgid': 'text',
            'msgstr': ['text'],
          },
          'textWithMetadata': {
            'msgid': 'textWithMetadata',
            'msgstr': ['textWithMetadata'],
          },
        }
      }
    });
  }

   @override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    final po = gettext.po.parse(content);
    var messages = <String, BasicTranslatedMessage>{};

    Map.from(po['translations']).forEach((key, value) {
      Map.from(value).forEach((key, value) {
        final m = Map.from(value);
        final id = m['msgid'];

        final str = (m['msgstr'] as List);
        print(m['msgstr']);
        final message =
            (str != null && str.isNotEmpty) ? str.join().toString() : id;

        if (id == null) return;
        print('$id, $message');
        messages[id] = BasicTranslatedMessage(id, Message.from(message, null));
      });
    });
    return MessagesForLocale(messages);
  }
}
