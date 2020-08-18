library intl_translation_ota;

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl/src/intl_helpers.dart';

export 'src/file.dart';

class OntheGoLookup extends MessageLookupByLibrary {
  OntheGoLookup(this.localeName, List<CatalogTranslatedMessage> messages)
      : messages = _notInlinedMessages(messages);

  @override
  final String localeName;

  final messages;
  static _notInlinedMessages(List<CatalogTranslatedMessage> messages) {
    final entries = messages.map(
      (message) => MapEntry(
        message.id,
        messageToLookup(message)
      ),
    );
    return Map.fromEntries(entries);
  }

  static Function messageToLookup(CatalogTranslatedMessage message) {
    try {
      final string = messageToIcuString(message.message);
      return MessageLookupByLibrary.simpleMessage(string);
    } catch (e) {
      // TranslatedMessages don't know their placeholders
      return (a) => 'Plurals/Genders are not supported yet';
    }
  }
}

class TranslationLoader {
  Map<String, OntheGoLookup> _messagesByLocale = {};

  TranslationLoader(this.catalog) : assert(catalog != null);

  final TranslationCatalog catalog;

  /// User programs should call this before using [localeName] for messages.
  Future<bool> initializeMessages(String localeName) async {
    var availableLocale = Intl.verifiedLocale(
        localeName, (locale) => catalog.locales.contains(locale),
        onFailure: (_) => null);
    if (availableLocale == null) {
      return new Future.value(false);
    }
    if (catalog.translatedMessages[availableLocale] == null) return false;
    _messagesByLocale[availableLocale] = OntheGoLookup(
        availableLocale,
        catalog.translatedMessages[availableLocale]
            .map((e) => CatalogTranslatedMessage(e.id, e.message, catalog))
            .toList());
    initializeInternalMessageLookup(() => new CompositeMessageLookup());
    messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);

    return new Future.value(true);
  }

  MessageLookupByLibrary _findExact(String localeName) {
    return _messagesByLocale[localeName];
  }

  bool _messagesExistFor(String locale) {
    try {
      return _findExact(locale) != null;
    } catch (e) {
      return false;
    }
  }

  MessageLookupByLibrary _findGeneratedMessagesFor(String locale) {
    var actualLocale =
        Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
    if (actualLocale == null) return null;
    return _findExact(actualLocale);
  }
}
