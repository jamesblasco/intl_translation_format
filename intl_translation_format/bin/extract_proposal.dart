library extract;

import 'package:args/args.dart';
import 'package:intl_translation/extract_messages.dart';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/src/directory_utils.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:path/path.dart' as path;

import 'formats.dart';

main(List<String> args) {
  final parser = ExtractArgParser();

  parser.parse(args);

  final translationFormat = TranslationFormat.fromFormat(
    format: parser.formatKey,
    supportedFormats: availableFormats,
  );

  var dartFiles = args.where((x) => x.endsWith(".dart")).toList();
  dartFiles.addAll(linesFromFile(parser.sourcesListFile));

  final files = Map.fromEntries(
      dartFiles.map((e) => MapEntry(e, File(e).readAsStringSync())));


  
  final template = TranslationCatalogTemplate.fromDartFiles(
    locale: parser.locale,
    dartFiles: files,
    config: parser.extractConfig,
  );

  final content = template.generateTemplateFile(translationFormat);

  final file = new File(path.join(parser.targetDir, parser.outputFilename));

  file.writeAsStringSync(content);
  // Todo: Check where to add this.
  /* if (extraction.hasWarnings && parser.warningsAreErrors) {
    exit(1);
  } */
}

class ExtractArgParser {
  String targetDir;
  String outputFilename;
  String sourcesListFile;
  String formatKey;
  bool transformer; //Todo: Support transformer and extraction data
  String locale;
  ExtractConfig extractConfig = ExtractConfig();


  void parse(Iterable<String> args) {
    final parser = ArgParser();

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
    parser.addOption("output-file",
        defaultsTo: 'intl_messages.arb',
        callback: (value) => outputFilename = value,
        help: 'Specify the output file.');
    parser.addOption("sources-list-file",
        callback: (value) => sourcesListFile = value,
        help: 'A file that lists the Dart files to read, one per line.'
            'The paths in the file can be absolute or relative to the '
            'location of this file.');
    parser.addFlag("require_descriptions",
        defaultsTo: false,
        help: "Fail for messages that don't have a description.",
        callback: (val) => extractConfig.descriptionRequired = val);

    parser.addOption("format",
        allowed: availableFormats.keys,
        help: "Select one of the supported translation formats",
        callback: (val) => formatKey = val);

    if (args.length == 0) {
      print('Accepts Dart files and produces $outputFilename');
      print('Usage: extract_to_arb [options] [files.dart]');
      print(parser.usage);
      exit(0);
    }

    parser.parse(args);
  }
}
