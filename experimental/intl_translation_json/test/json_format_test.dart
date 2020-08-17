import 'package:intl_translation_format/test.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:test/test.dart';

void main() {
  group('Json Format -', () {
    testFormatParserWithDefaultMessages(JsonFormat(), simpleMessage: '''
{
  "simpleMessage": "Simple Message"
}''', messageWithMetadata: '''
{
  "messageWithMetadata": "Message With Metadata"
}''', pluralMessage: '''
{
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}"
}''', messageWithVariable: '''
{
  "messageWithVariable": "Share {variable}"
}''', allMessages: '''
{
  "simpleMessage": "Simple Message",
  "messageWithMetadata": "Message With Metadata",
  "pluralExample": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}",
  "messageWithVariable": "Share {variable}"
}''');
  });
}
