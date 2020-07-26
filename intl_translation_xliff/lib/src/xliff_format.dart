import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';

import 'package:xml/xml.dart';


const xliffAttributes = {
  'xmlns': 'urn:oasis:names:tc:xliff:document:2.0',
  'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation':
      'urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd',
};

class XliffFormat extends SingleLanguageFormat {
  static const key = 'xliff-2';

  @override
  String get fileExtension => 'xliff';

  @override
  String buildTemplateFileContent(
    TranslationTemplate catalog,
  ) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0 encoding="UTF-8""');
    builder.element('xliff', attributes: {
      ...xliffAttributes,
      'version': '2.0',
      'srcLang': catalog.defaultLocale,
      //trgLang="es"  Templates don't need target
    }, nest: () {
      builder.element('file', nest: () {
        catalog.messages.forEach((key, message) {
          final text = ICUParser().icuMessageToString(message);
          builder.element('unit', attributes: {'id': key, 'name': key},
              nest: () {
            builder.element('segment', nest: () {
              builder.element('notes', nest: () {
                builder.element('note', attributes: {'category': 'format'},
                    nest: () {
                  builder.text('icu');
                });
              });
              builder.element('source', nest: () {
                builder.text(text);
              });
              // Templates don't need target
              // builder.element('target', nest: () {
              //   builder.attribute('lang', 'english');
              //   builder.text('todo');
              // });
            });
          });
        });
      });
    });
    return builder.build().toXmlString(pretty: true);
  }

  @override
  Map<String, BasicTranslatedMessage> parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    final messages = XliffParser().parse(content);
    return messages.messages;
  }
}