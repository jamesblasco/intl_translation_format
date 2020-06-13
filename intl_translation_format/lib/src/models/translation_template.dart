import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/src/intl_message.dart';
import '../../intl_translation_format.dart';

class TranslationTemplate {
  final String projectName;
  final String defaultLocale;
  DateTime lastModified = DateTime.now();

  Map<String, MainMessage> messages = {};

  TranslationTemplate(
    this.projectName, {
    String locale = 'en',
  }) : defaultLocale = locale;

  Future addMessagesfromDartFiles(
    List<FileReference> dartFiles, {
    ExtractConfig config,
  }) async {
    final extraction = MessageExtraction();
    config?.setToMessageExtraction(extraction);

    Map<String, MainMessage> allMessages = {};
    for (final file in dartFiles) {
      final data = await file.readAsString();
      final content = extraction.parseFileContent(data, file.name, false);
      content.forEach((key, value) {
        originalMessage.putIfAbsent(key, () => <MainMessage>[]).add(value);
      });

      allMessages.addAll(messages);
    }
    messages.addAll(allMessages);
    lastModified = DateTime.now();
  }

  List<FileData> extractTemplate(TranslationFormat format) {
    return format.buildTemplate(this);
  }
}
