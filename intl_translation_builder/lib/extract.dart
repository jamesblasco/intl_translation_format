library extract;

import 'dart:async';

import 'package:args/args.dart';
import 'package:build/build.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'dart:io';

import 'package:intl_translation/src/directory_utils.dart';
import 'package:intl_translation_format/src/file/local/local_file.dart';
import 'package:intl_translation_format/src/models/formats.dart';
import 'package:intl_translation_format/translation_configuration.dart';


main(List<String> args) async {
  final parser = ExtractArgParser();

  parser.parse(args);

  final translationFormat = TranslationFormat.fromKey(parser.formatKey);

  var dartFiles =
      parser.sourceFiles ?? args.where((x) => x.endsWith(".dart")).toList();
  dartFiles.addAll(linesFromFile(parser.sourcesListFile));

  final files = dartFiles.map((file) => LocalFile(file)).toList();

  final template = TranslationTemplate(parser.baseName, locale: parser.locale);
  await template.addTemplateMessages(files, config: parser.extractConfig);

  final templateFiles = template.extractTemplate(translationFormat);
  for (final files in templateFiles) {
    await LocalFile(parser.targetDir + files.name).write(files);
  }

  // Todo: Check where to add this.
  /* if (extraction.hasWarnings && parser.warningsAreErrors) {
    exit(1);
  } */
}

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
