import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';

import 'package:xml/xml.dart';

class XliffFormat extends MonoLingualFormat {
  final XliffVersion version;

  XliffFormat([this.version = XliffVersion.v2]);

  @override
  String get fileExtension => 'xliff';

  @override
  List<String> get supportedFileExtensions => ['xliff', 'xlf'];

  @override
  String generateTemplateFile(TranslationTemplate template) {
    return generateTemplate(template, version);
  }

  @override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    return XliffParser(version: version).parse(content);
  }
}

class MultipleLanguageXliffFormat extends MultiLingualFormat {
  final XliffVersion version;

  MultipleLanguageXliffFormat([this.version = XliffVersion.v2]);

  @override
  String get fileExtension => 'xliff';

  @override
  List<String> get supportedFileExtensions => ['xliff', 'xlf'];

  @override
  String generateTemplateFile(TranslationTemplate catalog) {
    return generateTemplate(catalog, version);
  }

  @override
  List<MessagesForLocale> parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    return XliffParser(version: version).parseMultiLanguage(content);
  }
}

String generateTemplate(TranslationTemplate template, XliffVersion version) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0 encoding="UTF-8""');
  builder.element('xliff', attributes: {
    ...attributesForVersion(version),
    if (version == XliffVersion.v1) ...{
      'version': '1.2',
      'source-language': template.defaultLocale,
    } else ...{
      'version': '2.0',
      'srcLang': template.defaultLocale,
    }
  }, nest: () {
    builder.element('file', nest: () {
      template.messages.forEach((key, message) {
        final text = messageToIcuString(message);
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
                builder.element('note', attributes: {'category': 'description'},
                    nest: () {
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