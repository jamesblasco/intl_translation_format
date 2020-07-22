library extract;
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation/src/directory_utils.dart';




main(List<String> args) async {
  final parser = ExtractArgParser();
  print(args);
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
