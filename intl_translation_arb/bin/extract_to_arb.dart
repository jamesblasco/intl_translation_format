library extract_to_arb;

import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/src/directory_utils.dart';
import 'package:intl_translation_arb/arb_format.dart';
import 'package:path/path.dart' as path;

import 'package:intl_translation_format/intl_translation_format.dart';

main(List<String> args) {
  var targetDir;
  var outputFilename;
  String sourcesListFile;
  bool transformer; //Todo: Support transformer and extraction data
  var parser = new ArgParser();
  var extraction = new MessageExtraction();
  String locale;
  parser.addFlag("suppress-last-modified",
      defaultsTo: false,
      callback: (x) => extraction.suppressLastModified = x,
      help: 'Suppress @@last_modified entry.');
  parser.addFlag("suppress-warnings",
      defaultsTo: false,
      callback: (x) => extraction.suppressWarnings = x,
      help: 'Suppress printing of warnings.');
  parser.addFlag("suppress-meta-data",
      defaultsTo: false,
      callback: (x) => extraction.suppressMetaData = x,
      help: 'Suppress writing meta information');
  parser.addFlag("warnings-are-errors",
      defaultsTo: false,
      callback: (x) => extraction.warningsAreErrors = x,
      help: 'Treat all warnings as errors, stop processing ');
  parser.addFlag("embedded-plurals",
      defaultsTo: true,
      callback: (x) => extraction.allowEmbeddedPluralsAndGenders = x,
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
      callback: (x) => extraction.includeSourceText = x,
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
      callback: (val) => extraction.descriptionRequired = val);

  parser.parse(args);
  if (args.length == 0) {
    print('Accepts Dart files and produces $outputFilename');
    print('Usage: extract_to_arb [options] [files.dart]');
    print(parser.usage);
    exit(0);
  }

  var dartFiles = args.where((x) => x.endsWith(".dart")).toList();
  dartFiles.addAll(linesFromFile(sourcesListFile));
  String content = IntlTranslation.extractMessages(
    format: ArbFormat(),
    locale: locale,
    dartFiles:  dartFiles,
  );

  final file = new File(path.join(targetDir, outputFilename));

  file.writeAsStringSync(content);
  if (extraction.hasWarnings && extraction.warningsAreErrors) {
    exit(1);
  }
}
