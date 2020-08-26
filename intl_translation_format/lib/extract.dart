library extract;

import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation/src/directory_utils.dart';

main(List<String> args, [Map<String, TranslationFormatBuilder> formats]) async {
  final parser = ExtractArgParser()..parse(args);

  final translationFormat =
      TranslationFormat.fromKey(parser.formatKey, supportedFormats: formats);

  final dartFiles = <String>[
    ...?parser.configuration?.sourceFiles,
    ...args.where((x) => x.endsWith(".dart")),
    ...linesFromFile(parser.sourcesListFile)
  ].map((file) => LocalFile(file)).toList();

  final template = TranslationTemplate(
    parser.projectName,
    locale: parser.locale,
  );

  await template.addTemplateMessages(dartFiles, config: parser.extractConfig);

  final templateFiles = template.generateTemplate(translationFormat);

  for (final file in templateFiles) {
    await LocalFile(parser.outputDir + file.name).write(file);
  }
}
