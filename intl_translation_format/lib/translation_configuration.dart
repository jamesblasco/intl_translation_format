import 'package:yaml/yaml.dart';

/// Configuration for a traslation catalog.
/// Usually definded in a yaml file
///
///
///
///
class TranslationConfiguration {
  final String projectName;
  final String outputDir;
  final String defaultLocale;
  final String format;
  final List<String> sourceFiles;
  final List<String> translationFiles;

  TranslationConfiguration({
    this.projectName = 'intl_messages',
    this.outputDir = 'lib/intl/',
    this.defaultLocale = 'en',
    this.format = 'arb',
    this.sourceFiles = const [],
    this.translationFiles = const [],
  });

  factory TranslationConfiguration.fromYaml(
    String content,
    String fileName,
  ) {
    final yaml = loadYaml(content);

    if (yaml == null) {
      throw '$fileName is empty';
    }

    final node = yaml['intl_translation'];
    if (node == null) {
      throw '$fileName does not contain a intl_translation';
    }

    return TranslationConfiguration(
      projectName: node['project_name'],
      outputDir: node['output_dir'],
      format: node['format'],
      defaultLocale: node['default_locale'],
      sourceFiles: List<String>.from(node['sources']),
      translationFiles: List<String>.from(node['translations']),
    );
  }
}
