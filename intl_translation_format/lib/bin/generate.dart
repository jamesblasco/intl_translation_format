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

import 'dart:io';

import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation/src/directory_utils.dart';

main(
  List<String> args, [
  Map<String, TranslationFormatBuilder> formats,
]) async {
  final parser = GenerateArgParser()..parse(args);

  final format =
      TranslationFormat.fromKey(parser.formatKey, supportedFormats: formats);

  final dartFiles = <String>[
    ...?parser.configuration?.sourceFiles,
    ...args.where((x) => x.endsWith(".dart")),
    ...linesFromFile(parser.sourcesListFile)
  ].map((file) => LocalFile(file)).toList();

  final translationFiles = <String>[
    ...?parser.configuration?.translationFiles,
    ...args.where((x) => format.isFileSupported(x)).toList(),
    ...linesFromFile(parser.translationsListFile)
  ].map((file) => LocalFile(file)).toList();

  if (dartFiles.isEmpty || translationFiles.isEmpty) {
    print('No files added');
    print('Usage: generate [options]'
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

  final catalog = TranslationCatalog(parser.projectName);

  await catalog.addTemplateMessages(
    dartFiles,
    config: parser.extractConfig,
  );

  await catalog.addTranslations(translationFiles, format: format);

  final generatedFiles =
      catalog.generateDartMessages(config: parser.generationConfig);

  generatedFiles
      .forEach((file) => LocalFile(parser.outputDir + file.name).write(file));
}
