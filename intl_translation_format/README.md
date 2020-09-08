
<img src="https://github.com/jamesblasco/intl_translation_format/blob/master/intl_translation_format/image_header.jpg?raw"/>

# intl_translation_format

This package provides multiformat support for the Intl package.

This package provides the tools to support a new translation format to work with the intl_translation package: 

- Message extraction from Dart code
- Code generation from translated messages 
- New formats can be added without modifying this package, but it includes the ARB and XLIFF formats by default.

To learn more read the next section **Getting Started** and check the [Example](https://github.com/jamesblasco/intl_translation_format/tree/master/intl_translation_format/example) project.

# Getting started

#### 1. Add package
Add this to your package's pubspec.yaml file:
```yaml
dev_dependencies:
  intl_translation_format: [current version]
```

#### 2. Add messages
Create your messages using the [intl](https://pub.dev/packages/intl) package

```dart
 String continueMessage() => Intl.message(
      'Hit any key to continue',
      name: 'continueMessage');
```

#### 3. Export messages

Run the following command to export the messages to the desired format:

```zsh
pub run intl_translation_format:extract 
    lib/main.dart --output-dir lib/l10n/ --format arb
```

#### 4. Translate messages

Translate the messages manually or with a translation tool

#### 5. Generate translations

Run the following command to generate the code from translation messages:

```zsh
pub run intl_translation_format:generate 
    --project-name intl_messages
    --output-dir lib/l10n/  
    --format arb
    lib/main.dart 
    lib/l10n/arb/intl_messages_en.arb 
    lib/l10n/arb/intl_messages_es.arb   
```

### Implement a new translation file format

The intl_translation_format brings the tools needed to support a new translation format. 
You can extend the class TranslationFormat and complete the functions that will take care of the extracting of the messages
and create templates. There are several classes to make this task easier: `MonoLingualFormat`, `BinaryMonolingualFormat`,
`MultiLingualFormat`.

As an example, this guide will show you how the JSON file format is implemented.
While in the package both monolingual and multilingual JSON has been implemented, 
this steps will only explain the monolingual JSON format

1. Learning about your format

It is important to do some research about the format you are interested to implement. Some good questions would be:
 1. Is there a standard or other definitive document that can tell us how to resolve any questions about the implementation? 
  eg. [ARB](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification) and [XLIFF](http://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html) are standardized, 
 2. Is it a binary or text-based format?
  eg. [.po](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) is a text based format while [.mo](https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html) is binary. 
 3. Does it contain a translation for multiple languages per file or is it just one language per file?
  eg. ARB contains a language per file while XLIFF can contain the translation and the source language.
 4. How does it handle Plurals, Genders, and Variables?

Let's answer these questions for our new JSON format:
 1. While it is a standard data interchange format, there is no official standard for translations. Multiple frameworks create their implementations like `i18next` or `ng2-translate` for `Angular`.

 Because the [`ICU Format`](https://unicode-org.github.io/icu/userguide/format_parse/messages/) is the core of the dart intl library, we decided to create a value/key simple JSON with ICU messages. 

 As an example: 
 ```json
 {
   "message1" : "This is a message",
   "message2" : "Hello { userName }, this a message with a variable",
   "message2" : "You have { howMany, plural, =0 { none Apples} one { one Apple} other { {howMany} Apples} }"
 } 
 ```

Learn more about ICU message format with [this article]( https://phrase.com/blog/posts/guide-to-the-icu-message-format/)
 2. It is a text-based format
 3. It contains one locale translation per file.
 4. We will use the ICU format for plurals, genders, and variables.


2. Start coding

 - Create a new dart package and add intl_translation_format as a dependency.

- Choose what `TranslationFormat` class to extend. In our case, our format will be monolingual and text-based so we will extend `MonolingualFormat`. You can see the implementation of other classes in other packages.

```dart 
class JsonFormat extends MonoLingualFormat {

  @override
  String get fileExtension => 'json';
  ...
}  
```
The first thing will be to add the `fileExtension` in our case `JSON`. You can override the `fileExtensions` getter in case your format supports multiple extensions (eg. XLIFF supports .xliff and xlf).

3. Implement the method to generate a template.

A template is a class that contains the messages in the source language. By default this language is `en`.

This method will generate a file in the desired format that will contain the messages from the template.

```dart
@override
String generateTemplateFile(
  TranslationTemplate catalog,
) {
  final messages = catalog.messages;
  var json = '{\n';
  messages.forEach((key, value) {
    // Expands the MainMessage into an icu string
    final message = messageToIcuString(value);
    json += '  "$key": "$message",\n';
  });
  if (messages.isNotEmpty) json = json.substring(0, json.length - 2) + '\n';
  json += '}';
  return json;
}
```
The param `catalog` contains the list of `MainMessage`s. These `MainMessages` can be expanded into a string with your transform function. For ICU messages there is an already built method `messageToIcuString` that expands the message into an ICU string.

This method should return a String that contains the file content with the desired format.

4. Implement the method to extract messages: 

It will return `MessagesForLocale` object with the messages and an optional locale in case it is indicated inside the file.

```dart
@override
  MessagesForLocale parseFile(
    String content, {
    MessageGeneration generation,
  }) {
    final json = jsonEncoder.decode(content) as Map<String, Object>;
    final messages = <String, BasicTranslatedMessage>{};
     // foldMap Creates a flat map with a set of keys per value.
    foldMap<String>(json).forEach(
      (keys, value) {
        final unformattedKey =
            keys.reduce((string1, string2) => '$string1 $string2');

        final key = CaseFormat(Case.camelCase).format(unformattedKey);

        final message = BasicTranslatedMessage(key, IcuMessage.fromIcu(value));
        messages[key] = message;
      },
    );
    return MessagesForLocale(messages);
```

The important part here is to parse the string message into a Message class. You can manually manually parse the Message to create a syntax tree but for ICU there is already a default parser: `IcuMessage.fromIcu(value)`

For each message, we will create a BasicTranslatedMessage that will contain the identifier (the message's keyname) and the Message.


5. Testing the new format:

It is important to add tests that will assure us that the format parsing is working as expected. The intl_translation_format comes with some utility methods for testing.

```dart
/// Compares a file content with the messages that are expected
/// after parsing the file with the indicated [format]
void expectFormatParsing(
  String content,
  MonoLingualFormat format, {
  List<MainMessage> messages = const [],
})
```

```dart
/// Compares MainMessages with the template file that would be
/// generated using the indicated [format].
void expectFormatTemplateGeneration(
  String content,
  MonoLingualFormat format, {
  List<MainMessage> messages = const [],
})
```


We suggest creating MainMessages with the ICU format during testing.

```dart
IcuMainMessage('This is a message with a { variable }');
```

We have created a common test to use across all the formats. It is a class that tests your format across 5 cases so far:
 - A simple message
 - A simple message with metadata
 - A message with plurals
 - A message with a variable
 - All messages together.

Extend the `FormatTester` class and implement the file content for each case.

```dart
class JsonFormatTester extends MonolingualFormatTester {
  @override
  MonoLingualFormat get format => JsonFormat();

  @override
  String get simpleMessage => '''
{
  "simpleMessage": "Simple Message"
}''';
  ....
```

To execute the test just call `testFormat(JsonFormatTester())`;

This will test each case with both parsing a file and generating a template file.


If you still have doubts or you are struggling to implement a new format, ping me at [@jamesblasco](https://twitter.com/JamesBlasco) or git@jaimeblasco.com.
