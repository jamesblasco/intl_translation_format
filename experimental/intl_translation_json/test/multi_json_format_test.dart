import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation_format/test.dart';
import 'package:test/test.dart';

void main() {
  group('Json Multilingual Format -', () {
    testMultiLingualFormatWithDefaultMessages(MultiJsonFormat(),
        simpleMessage: '''
{
  "simpleMessage": {
    "en": "Simple Message", 
    "es": "Mensaje simple"
  }
}''',
        messageWithMetadata: '''
{
  "messageWithMetadata": {
    "en": "Message With Metadata", 
    "es": "Mensaje con Metadatos"
  }
}''',
        pluralMessage: '''
{
  "pluralExample": {
    "en": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}", 
    "es": "{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}"
  }
}''',
        messageWithVariable: '''
{
  "messageWithVariable": {
    "en": "Share {variable}", 
    "es": "Compartir {variable}"
  }
}''',
        allMessages: '''
{
  "simpleMessage": {
    "en": "Simple Message", 
    "es": "Mensaje simple"
  },
  "messageWithMetadata": {
    "en": "Message With Metadata", 
    "es": "Mensaje con Metadatos"
  },
  "pluralExample": {
    "en": "{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}", 
    "es": "{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}"
  },
  "messageWithVariable": {
    "en": "Share {variable}", 
    "es": "Compartir {variable}"
  }
}
''');
  });
}
