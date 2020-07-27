library extract;

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation/src/directory_utils.dart';

main(List<String> args) async {
  final parser = ExtractArgParser()..parse(args);

  final translationFormat = TranslationFormat.fromKey(parser.formatKey);

  final dartFiles = [
    if (parser.sourceFiles != null) parser.sourceFiles,
    ...args.where((x) => x.endsWith(".dart")),
    ...linesFromFile(parser.sourcesListFile)
  ].map((file) => LocalFile(file)).toList();

  final template = TranslationTemplate(
    parser.baseName,
    locale: parser.locale,
  );

  await template.addTemplateMessages(dartFiles, config: parser.extractConfig);

  final templateFiles = template.extractTemplate(translationFormat);
  
  for (final file in templateFiles) {
    await LocalFile(parser.targetDir + file.name).write(file);
  }

  // Todo: Check where to add this.
  /* if (extraction.hasWarnings && parser.warningsAreErrors) {
    exit(1);
  } */
}
