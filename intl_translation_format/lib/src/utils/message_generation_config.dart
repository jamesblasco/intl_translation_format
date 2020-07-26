import 'dart:io';

import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/src/models/formats.dart';
import 'package:intl_translation_format/translation_configuration.dart';

import '../../intl_translation_format.dart';
import 'package:args/args.dart';

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

class GenerateArgParser {
  String projectName;
  String formatKey;

  String targetDir;
  String translationsListFile;
  String sourcesListFile;
  bool transformer; //Todo: Support transformer and extraction data

  bool suppressWarnings;

  String _configurationFile;
  TranslationConfiguration configuration;

  ExtractConfig extractConfig = ExtractConfig();
  GenerationConfig generationConfig = GenerationConfig();

  final parser = ArgParser();

  String get usage => parser.usage;
  void parse(Iterable<String> args) {
    parser.addOption("config",
        abbr: 'c',
        callback: (x) => _configurationFile = x,
        help: 'Path of yaml file with configuration.');
    parser.addFlag('json',
        defaultsTo: false,
        callback: (x) => generationConfig.useJson = x,
        help:
            'Generate translations as a JSON string rather than as functions.');
    parser.addFlag("suppress-warnings",
        defaultsTo: false,
        callback: (x) => suppressWarnings = x,
        help: 'Suppress printing of warnings.');
    parser.addOption('output-dir',
        defaultsTo: '.',
        callback: (x) => targetDir = x,
        help: 'Specify the output directory.');
    parser.addOption("project-name", defaultsTo: 'intl', callback: (x) {
      projectName = x;
    }, help: 'Specify a prefix to be used for the generated file names.');
    parser.addFlag("use-deferred-loading",
        defaultsTo: true,
        callback: (x) => generationConfig.useDeferredLoading = x,
        help:
            'Generate message code that must be loaded with deferred loading. '
            'Otherwise, all messages are eagerly loaded.');
    parser.addOption('codegen_mode',
        allowed: ['release', 'debug'],
        defaultsTo: 'debug',
        callback: (x) => generationConfig.codegenMode = x,
        help:
            'What mode to run the code generator in. Either release or debug.');
    parser.addOption("sources-list-file",
        callback: (value) => sourcesListFile = value,
        help: 'A file that lists the Dart files to read, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');
    parser.addOption("translations-list-file",
        callback: (value) => translationsListFile = value,
        help:
            'A file that lists the translation files to process, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');
    parser.addFlag("transformer",
        defaultsTo: false,
        callback: (x) => transformer = x,
        help: "Assume that the transformer is in use, so name and args "
            "don't need to be specified for messages.");

    parser.addOption("format",
        allowed: defaultFormats.keys,
        help: "Select one of the supported translation formats",
        callback: (val) => formatKey = val);

    if (args.length == 0) {
      print('Usage: generate [options]'
          ' file1.dart file2.dart ...'
          ' translation1_<languageTag>.arb translation2.arb ...');
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

      projectName = configuration.projectName ?? projectName;
      formatKey = configuration.format ?? formatKey;
      targetDir = configuration.outputDir;
    }
    
  }
}
