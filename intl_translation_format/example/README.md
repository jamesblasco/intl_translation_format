# Example

This is an example Flutter app using intl_translation_format and xliff translation files.

## Getting Started

1. Recreate flutter project
  - `flutter create .` It will create the android/ios/web.. folders
  - `flutter pub get`

2. Extract the messages to xliff
  - `sh ./tools/extract.sh`

3. Add translations
  - Translations for `es` and `gr` are added already.
  - To add a translation:
    - Create the a new translation file `lib/l10n/intl_{locale}.xliff`
    - Add the file path to the file `./tool/generage.sh`
    - Add the new locale inside the `availableLocales` list param at `lib/main.dart`

3. Generate translated messages from xliff
  - `sh ./tools/generate.sh`  

4. Run the flutter app  