library intl_translation_ota;

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl/src/intl_helpers.dart';

export 'src/file.dart';

class OntheGoLookup extends MessageLookupByLibrary {
  OntheGoLookup(this.localeName, List<TranslatedMessage> messages)
      : messages = _notInlinedMessages(messages);
  @override
  final String localeName;

  final messages;
  static _notInlinedMessages(List<TranslatedMessage> messages) =>
      Map.fromEntries(
        messages.map(
          (message) => MapEntry(
            message.id,
            MessageLookupByLibrary.simpleMessage(
              ICUParser().icuMessageToString(message.message),
            ),
          ),
        ),
      );
}

class TranslationLoader {
  Map<String, OntheGoLookup> _messagesByLocale = {};

  TranslationLoader(this.catalog) : assert(catalog != null);
  final TranslationCatalog catalog;

  /// User programs should call this before using [localeName] for messages.
  Future<bool> initializeMessages(String localeName) async {
    print(catalog.locales);
    var availableLocale = Intl.verifiedLocale(
        localeName, (locale) => catalog.locales.contains(locale),
        onFailure: (_) => null);
    if (availableLocale == null) {
      return new Future.value(false);
    }
    if (catalog.translatedMessages[availableLocale] == null) return false;
    _messagesByLocale[availableLocale] = OntheGoLookup(
        availableLocale, catalog.translatedMessages[availableLocale]);
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
