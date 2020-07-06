
import 'package:intl_translation/src/intl_message.dart';

class ICUParser {
  /// Return a version of the message string with with ICU parameters "{variable}"
  /// rather than Dart interpolations "$variable".
  String icuMessageToString(Message message) {
    return   message.expanded(_turnInterpolationIntoICUForm);
  }
    

  String _turnInterpolationIntoICUForm(Message message, chunk,
      {bool shouldEscapeICU = false}) {
    if (chunk is String) {
      return shouldEscapeICU ? _escape(chunk) : chunk;
    }
    if (chunk is int && chunk >= 0 && chunk < message.arguments.length) {
      return "{${message.arguments[chunk]}}";
    }
    if (chunk is SubMessage) {
      return chunk.expanded((message, chunk) =>
          _turnInterpolationIntoICUForm(message, chunk, shouldEscapeICU: true));
    }
    if (chunk is Message) {
      return chunk.expanded((message, chunk) => _turnInterpolationIntoICUForm(
          message, chunk,
          shouldEscapeICU: shouldEscapeICU));
    }
    throw FormatException("Illegal interpolation: $chunk");
  }

  String _escape(String s) {
    return s
        .replaceAll("'", "''")
        .replaceAll("{", "'{'")
        .replaceAll("}", "'}'");
  }
}
