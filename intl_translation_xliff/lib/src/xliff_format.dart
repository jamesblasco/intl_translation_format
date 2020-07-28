import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';

import 'package:xml/xml.dart';

class XliffFormat extends SingleLanguageFormat {
  final XliffVersion version;

  XliffFormat([this.version = XliffVersion.v2]);

  @override
  String get fileExtension => 'xliff';

  @override
  List<String> get supportedFileExtensions => ['xliff', 'xlf'];

  @override
  String generateTemplateFile(
    TranslationTemplate catalog,
  ) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0 encoding="UTF-8""');
    builder.element('xliff', attributes: {
      ...attributesForVersion(version),
      if (version == XliffVersion.v1) ...{
        'version': '1.2',
        'source-language': catalog.defaultLocale,
      } else ...{
        'version': '2.0',
        'srcLang': catalog.defaultLocale,
      }

      //trgLang="es"  Templates don't need target
    }, nest: () {
      builder.element('file', nest: () {
        catalog.messages.forEach((key, message) {
          final text = icuMessageToString(message);
          if (version == XliffVersion.v2) {
            builder.element('unit', attributes: {'id': key, 'name': key},
                nest: () {
              builder.element('segment', nest: () {
                builder.element('notes', nest: () {
                  builder.element('note', attributes: {'category': 'format'},
                      nest: () {
                    builder.text('icu');
                  });
                  if (message.description != null) {
                    builder.element('note',
                        attributes: {'category': 'description'}, nest: () {
                      builder.text(message.description);
                    });
                  }
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
          } else {
            builder.element('trans-unit', attributes: {'id': key}, nest: () {
              builder.element('notes', nest: () {
                builder.element('note', attributes: {'category': 'format'},
                    nest: () {
                  builder.text('icu');
                });
                if (message.description != null) {
                  builder.element('note',
                      attributes: {'category': 'description'}, nest: () {
                    builder.text(message.description);
                  });
                }
              });
              builder.element('source', nest: () {
                builder.text(text);
              });
            });
          }
        });
      });
    });
    return builder.build().toXmlString(pretty: true);
  }

  @override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    return XliffParser(version: version).parse(content);
  }
}
