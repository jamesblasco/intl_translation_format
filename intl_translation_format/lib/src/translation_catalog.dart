import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation_format/src/file/file_provider.dart';
import 'package:intl_translation_format/src/translation_format.dart';
import 'package:intl_translation_format/src/utils/translation_config.dart';

import '../intl_translation_format.dart';

class TranslationTemplate {
  ///  Project name for the translation project
  ///  The name of translation files will need to follow the following pattern
  ///  {projectName}_{locale}.{format}  eg: intl_en.arb
  ///
  ///  Generated dart files will be named {projectName}_messages_{locale}.dart
  ///  eg: intl_messages.ard
  ///
  final String projectName;

  final String defaultLocale;

  DateTime lastModified = DateTime.now();

  Map<String, List<MainMessage>> _originalMessage = {};

  final Map<String, MainMessage> messages = {};

  TranslationTemplate(
    this.projectName, {
    String locale,
  })  : assert(projectName != null),
        defaultLocale = locale ?? 'en';

  Future addTemplateMessages(
    List<FileProvider> dartFiles, {
    ExtractConfig config,
  }) async {
    final extraction = MessageExtraction();
    config?.setToMessageExtraction(extraction);

    for (final file in dartFiles) {
      final data = await file.readAsString();

      final result = extraction.parseContent(data, file.name, false);

      result.forEach((key, value) {
        _originalMessage.putIfAbsent(key, () => <MainMessage>[]).add(value);
      });

      messages.addAll(result);
    }

    lastModified = DateTime.now();
  }

  List<FileData> extractTemplate(TranslationFormat format) {
    return format.generateTemplateFiles(this);
  }
}

///  Catalog that stores all translation messages
///
///
class TranslationCatalog extends TranslationTemplate {
  ///  Project name for the translation project
  ///  The name of translation files will need to follow the following pattern
  ///  {projectName}_{locale}.{format}  eg: intl_en.arb
  ///
  ///  Generated dart files will be named {projectName}_messages_{locale}.dart
  ///  eg: intl_messages.ard
  ///
  String projectName;

  ///  The default locale
  ///
  ///
  String defaultLocale;
  DateTime lastModified;

  Map<String, List<BasicTranslatedMessage>> translatedMessages = {};
  Map<String, String> metadata;

  List<String> get locales => translatedMessages?.keys?.toList() ?? [];

  TranslationCatalog(this.projectName, {String locale})
      : super(projectName, locale: locale);

  Future addTranslations(
    List<RedableFile> files, {
    TranslationFormat format,
  }) async {
    await format.parseFiles(
      files,
      catalog: this,
    );
  }

  List<FileData> generateDartMessages({GenerationConfig config}) {
    final generation = (config ?? GenerationConfig()).getMessageGeneration();
    generation.allLocales.addAll(locales);

    print(translatedMessages);

    final nameHasMessageWord = projectName.endsWith('_messages');
    final basenameWithoutMessage = nameHasMessageWord
        ? '${projectName.substring(0, projectName.length - 9)}_'
        : '${projectName}_';

    final basename = '${basenameWithoutMessage}messages';
    generation.generatedFilePrefix = basenameWithoutMessage;

    final files = <FileData>[];
    translatedMessages.forEach((locale, translation) {
      final messages = translation.map((e) => e.toCatalogMessage(this));
      final content = generation.contentForLocale(locale, messages);
      final file = StringFileData(content, '${basename}_$locale.dart');
      files.add(file);
    });

    final content = generation.generateMainImportFile();
    final mainFile = StringFileData(content, '${basename}_all.dart');
    files.add(mainFile);
    return files;
  }
}

/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class CatalogTranslatedMessage extends TranslatedMessage {
  final TranslationCatalog catalog;

  CatalogTranslatedMessage(
    String name,
    Message translated,
    this.catalog,
  ) : super(name, translated);

  List<MainMessage> get originalMessages => (super.originalMessages == null)
      ? _findOriginals()
      : super.originalMessages;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  List<MainMessage> _findOriginals() =>
      originalMessages = catalog._originalMessage[id];
}

/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class BasicTranslatedMessage extends TranslatedMessage {
  BasicTranslatedMessage(
    String name,
    Message translated,
  ) : super(name, translated);

  CatalogTranslatedMessage toCatalogMessage(TranslationCatalog catalog) {
    return CatalogTranslatedMessage(id, translated, catalog);
  }
}
