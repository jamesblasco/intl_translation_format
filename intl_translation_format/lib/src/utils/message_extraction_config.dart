import 'package:intl_translation/extract_messages.dart';

class ExtractConfig {
  bool suppressLastModified;
  bool suppressWarnings;
  bool suppressMetaData;
  bool warningsAreErrors;
  bool allowEmbeddedPluralsAndGenders;
  bool includeSourceText;
  bool descriptionRequired;

  ExtractConfig({
    this.suppressLastModified,
    this.suppressWarnings,
    this.suppressMetaData,
    this.warningsAreErrors,
    this.allowEmbeddedPluralsAndGenders,
    this.includeSourceText,
    this.descriptionRequired,
  });

  setToMessageExtraction(MessageExtraction extraction) {
    extraction
      ..allowEmbeddedPluralsAndGenders = allowEmbeddedPluralsAndGenders ?? true
      ..descriptionRequired = descriptionRequired ?? false
      ..warningsAreErrors = warningsAreErrors ?? true
      ..suppressWarnings = suppressWarnings ?? false
      ..suppressLastModified = suppressLastModified ?? false
      ..suppressMetaData = suppressMetaData ?? false
      ..includeSourceText = includeSourceText ?? true;
  }
}
