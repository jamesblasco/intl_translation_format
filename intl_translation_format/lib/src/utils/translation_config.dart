import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:yaml/yaml.dart';

/// Configuration for a traslation catalog.
/// Usually definded in a yaml file
///
///
///
///
class TranslationConfig {
  final String projectName;
  final String outputDir;
  final String defaultLocale;
  final String format;
  final List<String> sourceFiles;
  final List<String> translationFiles;

  TranslationConfig({
    this.projectName = 'intl_messages',
    this.outputDir = 'lib/intl/',
    this.defaultLocale = 'en',
    this.format = 'arb',
    this.sourceFiles = const [],
    this.translationFiles = const [],
  });

  factory TranslationConfig.fromYaml(
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

    return TranslationConfig(
      projectName: node['project_name'],
      outputDir: node['output_dir'],
      format: node['format'],
      defaultLocale: node['default_locale'],
      sourceFiles: List<String>.from(node['sources']),
      translationFiles: List<String>.from(node['translations']),
    );
  }
}

class GenerationConfig {
  bool useJson;
  bool useDeferredLoading;
  String codegenMode;

  GenerationConfig({
    this.useJson,
    this.useDeferredLoading,
    this.codegenMode,
  });

  MessageGeneration getMessageGeneration() {
    final generation =
        (useJson ?? false) ? JsonMessageGeneration() : MessageGeneration();
    generation.useDeferredLoading = useDeferredLoading ?? true;
    generation.codegenMode = codegenMode ?? '';
    return generation;
  }
}

class ExtractConfig {
  bool suppressLastModified;
  bool suppressWarnings;
  bool suppressMetaData;
  bool warningsAreErrors;
  bool allowEmbeddedPluralsAndGenders;
  bool includeSourceText;
  bool descriptionRequired;

  ExtractConfig({
    this.suppressLastModified,
    this.suppressWarnings,
    this.suppressMetaData,
    this.warningsAreErrors,
    this.allowEmbeddedPluralsAndGenders,
    this.includeSourceText,
    this.descriptionRequired,
  });

  setToMessageExtraction(MessageExtraction extraction) {
    extraction
      ..allowEmbeddedPluralsAndGenders = allowEmbeddedPluralsAndGenders ?? true
      ..descriptionRequired = descriptionRequired ?? false
      ..warningsAreErrors = warningsAreErrors ?? true
      ..suppressWarnings = suppressWarnings ?? false
      ..suppressLastModified = suppressLastModified ?? false
      ..suppressMetaData = suppressMetaData ?? false
      ..includeSourceText = includeSourceText ?? true;
  }
}
