import 'dart:io';
import 'package:args/args.dart';


import 'package:intl_translation_format/src/utils/translation_config.dart';

import 'formats.dart';



class TranslationArgParser {
  String projectName;
  String outputDir;
  String formatKey;

  bool transformer; //Todo: Support transformer and extraction data

  String _configurationFile;
  TranslationConfig configuration;

  String sourcesListFile;

  ExtractConfig extractConfig;

  ArgParser parser;

  String get usage => parser?.usage;

  ExtractConfig parseExtractConfig(ArgParser parser) {
    ExtractConfig _extractConfig = ExtractConfig();
    parser.addFlag("suppress-last-modified",
        defaultsTo: false,
        callback: (x) => _extractConfig.suppressLastModified = x,
        help: 'Suppress @@last_modified entry.');
    parser.addFlag("suppress-warnings",
        defaultsTo: false,
        callback: (x) => _extractConfig.suppressWarnings = x,
        help: 'Suppress printing of warnings.');
    parser.addFlag("suppress-meta-data",
        defaultsTo: false,
        callback: (x) => _extractConfig.suppressMetaData = x,
        help: 'Suppress writing meta information');
    parser.addFlag("warnings-are-errors",
        defaultsTo: false,
        callback: (x) => _extractConfig.warningsAreErrors = x,
        help: 'Treat all warnings as errors, stop processing ');
    parser.addFlag("embedded-plurals",
        defaultsTo: true,
        callback: (x) => _extractConfig.allowEmbeddedPluralsAndGenders = x,
        help: 'Allow plurals and genders to be embedded as part of a larger '
            'string, otherwise they must be at the top level.');
    parser.addFlag("require-descriptions",
        defaultsTo: false,
        help: "Fail for messages that don't have a description.",
        callback: (val) => _extractConfig.descriptionRequired = val);
    parser.addFlag("with-source-text",
        defaultsTo: false,
        callback: (x) => _extractConfig.includeSourceText = x,
        help: 'Include source_text in meta information.');
    return extractConfig;
  }

  ArgParser createParser(Iterable<String> args) {
    final _parser = ArgParser();
    _parser.addOption("config",
        abbr: 'c',
        callback: (x) => _configurationFile = x,
        help: 'Path of yaml file with configuration.');

    _parser.addFlag("transformer",
        defaultsTo: false,
        callback: (x) => transformer = x,
        help: "Assume that the transformer is in use, so name and args "
            "don't need to be specified for messages.");

    _parser.addOption("project-name",
        defaultsTo: 'intl',
        callback: (x) => projectName = x,
        help: 'Your project name will be used in the generated files');

    _parser.addOption("output-dir",
        defaultsTo: '.',
        callback: (value) => outputDir = value,
        help: 'Specify the output directory.');

    _parser.addOption("sources-list-file",
        callback: (value) => sourcesListFile = value,
        help: 'A file that lists the Dart files to read, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');

    _parser.addOption("format",
        allowed: defaultFormats.keys,
        help: "Select one of the supported translation formats",
        callback: (val) => formatKey = val);

    extractConfig = parseExtractConfig(_parser);

    if (args.isEmpty) {
      print(
          'Accepts Dart files and produces a intl translate file with the desired format');
      print('Usage: extract_to_arb [options] [files.dart]');
      print(_parser.usage);
      exit(0);
    }
    parser = parser;
    return _parser;
  }

  void parse(Iterable<String> args) {
    final parser = createParser(args);
    parser.parse(args);

    if (_configurationFile != null) {
      final yaml = File(_configurationFile).readAsStringSync();
      configuration = TranslationConfig.fromYaml(
        yaml,
        _configurationFile,
      );

      projectName = configuration.projectName ?? projectName;
      outputDir = configuration.outputDir ?? outputDir;
      formatKey = configuration.format ?? formatKey;
    }
  }
}

class ExtractArgParser extends TranslationArgParser {
  String locale;

  @override
  ArgParser createParser(Iterable<String> args) {
    final _parser = super.createParser(args);
    _parser.addOption("locale",
        defaultsTo: null,
        callback: (value) => locale = value,
        help: 'Specify the locale set inside the arb file.');
    return _parser;
  }
}



class GenerateArgParser extends TranslationArgParser {
  String translationsListFile;

  GenerationConfig generationConfig = GenerationConfig();

  @override
  ArgParser createParser(Iterable<String> args) {
    final _parser = super.createParser(args);

    _parser.addFlag('json',
        defaultsTo: false,
        callback: (x) => generationConfig.useJson = x,
        help:
            'Generate translations as a JSON string rather than as functions.');

    _parser.addFlag("use-deferred-loading",
        defaultsTo: true,
        callback: (x) => generationConfig.useDeferredLoading = x,
        help:
            'Generate message code that must be loaded with deferred loading. '
            'Otherwise, all messages are eagerly loaded.');
    _parser.addOption('codegen_mode',
        allowed: ['release', 'debug'],
        defaultsTo: 'debug',
        callback: (x) => generationConfig.codegenMode = x,
        help:
            'What mode to run the code generator in. Either release or debug.');

    _parser.addOption("translations-list-file",
        callback: (value) => translationsListFile = value,
        help:
            'A file that lists the translation files to process, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');

    return _parser;
  }
}
