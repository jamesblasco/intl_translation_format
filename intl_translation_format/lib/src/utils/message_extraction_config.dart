import 'dart:io';
import 'package:args/args.dart';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation_format/src/models/formats.dart';

import '../../translation_configuration.dart';

class ExtractArgParser {
  String baseName;
  String targetDir;
  List<String> sourceFiles;
  String sourcesListFile;
  String formatKey;
  bool transformer; //Todo: Support transformer and extraction data
  String locale;
  String _configurationFile;
  TranslationConfiguration configuration;
  ExtractConfig extractConfig = ExtractConfig();

  void parse(Iterable<String> args) {
    final parser = ArgParser();
    parser.addOption("config",
        abbr: 'c',
        callback: (x) => _configurationFile = x,
        help: 'Path of yaml file with configuration.');
    parser.addFlag("suppress-last-modified",
        defaultsTo: false,
        callback: (x) => extractConfig.suppressLastModified = x,
        help: 'Suppress @@last_modified entry.');
    parser.addFlag("suppress-warnings",
        defaultsTo: false,
        callback: (x) => extractConfig.suppressWarnings = x,
        help: 'Suppress printing of warnings.');
    parser.addFlag("suppress-meta-data",
        defaultsTo: false,
        callback: (x) => extractConfig.suppressMetaData = x,
        help: 'Suppress writing meta information');
    parser.addFlag("warnings-are-errors",
        defaultsTo: false,
        callback: (x) => extractConfig.warningsAreErrors = x,
        help: 'Treat all warnings as errors, stop processing ');
    parser.addFlag("embedded-plurals",
        defaultsTo: true,
        callback: (x) => extractConfig.allowEmbeddedPluralsAndGenders = x,
        help: 'Allow plurals and genders to be embedded as part of a larger '
            'string, otherwise they must be at the top level.');
    parser.addFlag("transformer",
        defaultsTo: false,
        callback: (x) => transformer = x,
        help: "Assume that the transformer is in use, so name and args "
            "don't need to be specified for messages.");

    parser.addOption("project-name",
        defaultsTo: 'intl',
        callback: (x) => baseName = x,
        help: 'Your project name will be used in the generated files');
    parser.addOption("locale",
        defaultsTo: null,
        callback: (value) => locale = value,
        help: 'Specify the locale set inside the arb file.');
    parser.addFlag("with-source-text",
        defaultsTo: false,
        callback: (x) => extractConfig.includeSourceText = x,
        help: 'Include source_text in meta information.');
    parser.addOption("output-dir",
        defaultsTo: '.',
        callback: (value) => targetDir = value,
        help: 'Specify the output directory.');

    parser.addOption("sources-list-file",
        callback: (value) => sourcesListFile = value,
        help: 'A file that lists the Dart files to read, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');
    parser.addFlag("require-descriptions",
        defaultsTo: false,
        help: "Fail for messages that don't have a description.",
        callback: (val) => extractConfig.descriptionRequired = val);

    parser.addOption("format",
        allowed: defaultFormats.keys,
        help: "Select one of the supported translation formats",
        callback: (val) => formatKey = val);

    if (args.length == 0) {
      print(
          'Accepts Dart files and produces a intl translate file with the desired format');
      print('Usage: extract_to_arb [options] [files.dart]');
      print(parser.usage);
      exit(0);
    }

    parser.parse(args);

    if (_configurationFile != null) {
      final yaml = File(_configurationFile).readAsStringSync();
      configuration = TranslationConfiguration.fromYaml(
        yaml,
        _configurationFile,
      );

      baseName = configuration.projectName ?? baseName;
      formatKey = configuration.format ?? formatKey;
      sourceFiles = configuration.sourceFiles;
      targetDir = configuration.outputDir;
    }
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
