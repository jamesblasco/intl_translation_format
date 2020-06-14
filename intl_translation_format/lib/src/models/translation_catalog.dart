import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:intl_translation_format/src/file/file_provider.dart';
import 'package:intl_translation_format/src/models/translation_template.dart';
import 'package:intl_translation_format/src/utils/message_generation_config.dart';

import '../../intl_translation_format.dart';

class TranslationCatalog {
  String projectName;
  String defaultLocale;
  DateTime lastModified;

  Map<String, MainMessage> mainMessages = {};
  Map<String, List<TranslatedMessage>> translatedMessages = {};
  Map<String, String> metadata;

  List<String> get locales => translatedMessages?.keys?.toList() ?? [];

  TranslationCatalog({this.defaultLocale = 'en', this.projectName = ''});

  TranslationCatalog.fromTemplate(TranslationTemplate template)
      : defaultLocale = template.defaultLocale ?? 'en',
        lastModified = template.lastModified,
        mainMessages = template.messages,
        projectName = template.projectName;

  Future addTranslationsFromFiles(
    List<FileProvider> translationFiles, {
    TranslationFormat format,
  }) async {
    await format.parseMessagesFromFileIntoCatalog(
      translationFiles,
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
      print(locale);
      print(translation);
      final content =
          generation.generateIndividualMessageFileContent(locale, translation);
      final file = StringFileData(content, '${basename}_$locale.dart');
      files.add(file);
    });

    final content = generation.generateMainImportFile();
    final mainFile = StringFileData(content, '${basename}_all.dart');
    files.add(mainFile);
    return files;
  }
}
