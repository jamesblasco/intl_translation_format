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

import 'package:intl_translation/src/directory_utils.dart';

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

       catalog = TranslationCatalog(parser.projectName);
      await catalog.addTemplateMessages(
        dartFileRef,
        config: parser.extractConfig,
      );
     
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
    await catalog.addTranslations([file], format: format);

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
