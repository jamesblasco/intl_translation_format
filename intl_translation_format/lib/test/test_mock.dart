import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation/src/intl_message.dart';


class MockTemplate extends TranslationTemplate {
  MockTemplate(
    String projectName,
    this.messages, {
    String locale = 'en',
  }) : super(
          projectName,
          locale: locale,
        );
  @override
  final Map<String, MainMessage> messages;
}
