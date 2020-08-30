
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
[TBD]


