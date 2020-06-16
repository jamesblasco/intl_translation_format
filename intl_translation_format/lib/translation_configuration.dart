import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:yaml/yaml.dart';

class TranslationConfiguration {
  final String projectName;
  final String outputDir;
  final String defaultLocale;
  final String format;
  final List<String> sourceFiles;
  final List<String> translationFiles;

  TranslationConfiguration( {
    this.projectName = 'intl_messages',
    this.outputDir = 'lib/intl/',
    this.defaultLocale = 'en',
    this.format = 'arb',
    this.sourceFiles,
    this.translationFiles,
  });

  factory TranslationConfiguration.fromYaml(String content, String fileName) {
    final yaml = loadYaml(content);
    if (yaml == null) {
      throw '$fileName is empty';
    }
    final translationNode = yaml['intl_translation'];
    if (translationNode == null) {
      throw '$fileName does not contain a intl_translation';
    }
    final projectName = translationNode['project_name'];
    final outputDir = translationNode['output_dir'];
    final format = translationNode['format'];
     final defaultLocale = translationNode['default_locale'];
    final sources = (translationNode['sources'] as YamlList)
        .map((element) => element as String)
        .toList();
    final translations = (translationNode['translations'] as YamlList)
        .map((element) => element as String)
        .toList();

    return TranslationConfiguration(
      projectName: projectName,
      defaultLocale: defaultLocale,
      format: format,
      outputDir: outputDir,
      sourceFiles: sources,
      translationFiles: translations,
    );
  }
}
