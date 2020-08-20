This repository contains multiple packages

# Intl_translation_format

This package provides the tools to support a new translation format file with Intl package: 

- Message extraction from dart code
- Code generation from translated messages 

It also implements arb, xliff formats by default.

Current supported formats:

- [X] **Arb** - [Specification](https://github.com/google/app-resource-bundle)
- [X] **Xliff v1.2** - [Specification](http://docs.oasis-open.org/xliff/v1.2/os/xliff-core.html)
- [X] **Xliff v2.0** - [Specification](http://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html)


### Getting started

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






# **intl_translation_arb**

This package implements intl_translation_format for arb files


# **intl_translation_xliff**

This package implements intl_translation_format for xliff files


GSoC 2020 Project by Jaime Blasco Andres
