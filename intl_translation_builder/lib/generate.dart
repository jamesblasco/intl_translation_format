#!/usr/bin/env dart
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A main program that takes as input a source Dart file and a number
/// of ARB files representing translations of messages from the corresponding
/// Dart file. See extract_to_arb.dart and make_hardcoded_translation.dart.
///
/// If the ARB file has an @@locale or _locale value, that will be used as
/// the locale. If not, we will try to figure out the locale from the end of
/// the file name, e.g. foo_en_GB.arb will be assumed to be in en_GB locale.
///
/// This produces a series of files named
/// "messages_<locale>.dart" containing messages for a particular locale
/// and a main import file named "messages_all.dart" which has imports all of
/// them and provides an initializeMessages function.

library generate;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:build/build.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/src/file/local/local_file.dart';
import 'package:intl_translation_format/src/models/formats.dart';
import 'package:intl_translation_format/src/models/translation_template.dart';
import 'package:intl_translation_format/src/utils/message_generation_config.dart';

import 'package:intl_translation/src/directory_utils.dart';
import 'package:intl_translation_format/translation_configuration.dart';
import 'package:path/path.dart' as p;

class GenerateBuilder extends Builder {
  final BuilderOptions options;
  TranslationFormat format;
  TranslationCatalog catalog;

  final parser = ExtractArgParser();

  GenerateBuilder(this.options) {
    log.info('test');
    parser.parse(['--config', './pubspec.yaml']);
    log.warning(parser.configuration);
    format = TranslationFormat.fromKey(parser.formatKey);
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (catalog == null) {
      var dartFiles = parser.configuration.sourceFiles;
      final dartFileRef = dartFiles
          .map((e) => LocalFile(Directory.current.path + '/' + e))
          .toList();

      final template = TranslationTemplate(parser.projectName);
      await template.addMessagesfromDartFiles(
        dartFileRef,
        config: parser.extractConfig,
      );
      catalog = TranslationCatalog.fromTemplate(template);
    }

    if (buildStep.inputId.path == r'lib/$lib$') {
      final files = await catalog.generateDartMessages();
      final id = AssetId(
        buildStep.inputId.package,
        p.join('lib/l10n', 'messages_all.intl.dart'),
      );
      final file = (files.last as StringFileData).contents.replaceAll('.dart\' deferred as messages_', '.intl.dart\' deferred as messages_');
      return await BuildFile(id, buildStep).writeAsString(file);
    }

    final id = buildStep.inputId;

    final file = BuildFile(buildStep.inputId, buildStep);
    await catalog.addTranslationsFromFiles([file], format: format);

    final files = await catalog.generateDartMessages();
    await BuildFile(id.changeExtension('.intl.dart'), buildStep)
        .write(files.first);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        //r'$lib$': ['messages_all.intl.dart'],
        '.json': ['.intl.dart'],
        r'$lib$': const ['/l10n/messages_all.intl.dart'],
      };
}

class BuildFile extends FileProvider {
  final AssetId id;
  final BuildStep buildStep;

  BuildFile(this.id, this.buildStep);
  @override
  String get name => p.basename(id.path);

  @override
  Future<Uint8List> readAsBytes() {
    return buildStep.readAsBytes(id);
  }

  @override
  Future<String> readAsString() {
    return buildStep.readAsString(id);
  }

  @override
  Future writeAsBytes(Uint8List bytes) {
    return buildStep.writeAsBytes(id, bytes);
  }

  @override
  Future writeAsString(String content) {
    return buildStep.writeAsString(id, content);
  }
}

main2(List<String> args) async {
  final parser = ExtractArgParser();
  parser.parse(args);

  final format = TranslationFormat.fromKey(parser.formatKey);

  var dartFiles = parser.configuration.sourceFiles ??
      args.where((x) => x.endsWith("dart")).toList();
  var jsonFiles = parser.configuration.translationFiles ??
      args.where((x) => format.isFileSupported(x)).toList();
  dartFiles.addAll(linesFromFile(parser.sourcesListFile));
  jsonFiles.addAll(linesFromFile(parser.translationsListFile));
  if (dartFiles.length == 0 || jsonFiles.length == 0) {
    print('No files added');
    print('Usage: generate_from_arb [options]'
        ' file1.dart file2.dart ...'
        ' translation1_<languageTag>.arb translation2.arb ...');
    print(parser.usage);
    exit(0);
  }

  // TODO(alanknight): There is a possible regression here. If a project is
  // using the transformer and expecting it to provide names for messages with
  // parameters, we may report those names as missing. We now have two distinct
  // mechanisms for providing names: the transformer and just using the message
  // text if there are no parameters. Previously this was always acting as if
  // the transformer was in use, but that breaks the case of using the message
  // text. The intent is to deprecate the transformer, but if this is an issue
  // for real projects we could provide a command-line flag to indicate which
  // sort of automated name we're using.
  //extraction.suppressWarnings = true;

  final files = jsonFiles.map((e) => LocalFile(e)).toList();
  final dartFileRef = dartFiles.map((e) => LocalFile(e)).toList();

  final template = TranslationTemplate(parser.projectName);
  await template.addMessagesfromDartFiles(
    dartFileRef,
    config: parser.extractConfig,
  );

  final catalog = TranslationCatalog.fromTemplate(template);
  await catalog.addTranslationsFromFiles(files, format: format);

  final generatedFiles =
      catalog.generateDartMessages(config: parser.generationConfig);
  generatedFiles
      .forEach((file) => LocalFile(parser.targetDir + file.name).write(file));
}

class ExtractArgParser {
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
    parser.addOption('config',
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
    parser.addOption("project-name", defaultsTo: '', callback: (x) {
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

    /*  if (args.length == 0) {
      print('Usage: generate [options]'
          ' file1.dart file2.dart ...'
          ' translation1_<languageTag>.arb translation2.arb ...');
      print(parser.usage);
      exit(0);
    } */

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
