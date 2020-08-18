
import 'package:intl_translation/src/intl_message.dart';
import 'package:petitparser/petitparser.dart';

/// Parser from a icu string to a Message object
class _IcuParser {
  Parser get openCurly => char('{');

  Parser get closeCurly => char('}');
  Parser get quotedCurly => (string("'{'") | string("'}'")).map((x) => x[1]);

  Parser get icuEscapedText => quotedCurly | twoSingleQuotes;
  Parser get curly => (openCurly | closeCurly);
  Parser get notAllowedInIcuText => curly | char('<');
  Parser get icuText => notAllowedInIcuText.neg();
  Parser get notAllowedInNormalText => char('{');
  Parser get normalText => notAllowedInNormalText.neg();
  Parser get messageText =>
      (icuEscapedText | icuText).plus().map((x) => x.join());
  Parser get nonIcuMessageText => normalText.plus().map((x) => x.join());
  Parser get twoSingleQuotes => string("''").map((x) => "'");
  Parser get number => digit().plus().flatten().trim().map(int.parse);
  Parser get id => (letter() & (word() | char('_')).star()).flatten().trim();
  Parser get comma => char(',').trim();

  /// Given a list of possible keywords, return a rule that accepts any of them.
  /// e.g., given ["male", "female", "other"], accept any of them.
  Parser asKeywords(List<String> list) =>
      list.map(string).cast<Parser>().reduce((a, b) => a | b).flatten().trim();

  Parser get pluralKeyword => asKeywords(
      ['=0', '=1', '=2', 'zero', 'one', 'two', 'few', 'many', 'other']);
  Parser get genderKeyword => asKeywords(['female', 'male', 'other']);

  var interiorText = undefined();

  Parser get preface => (openCurly & id & comma).map((values) => values[1]);

  Parser get pluralLiteral => string('plural');
  Parser get pluralClause =>
      (pluralKeyword & openCurly & interiorText & closeCurly)
          .trim()
          .map((result) => [result[0], result[2]]);
  Parser get plural =>
      preface & pluralLiteral & comma & pluralClause.plus() & closeCurly;
  Parser get intlPlural => plural.map(
        (values) {
          _extractArgumentIfNeeded(values.first);
          return Plural.from(values.first, values[3], null);
        },
      );

  Parser get selectLiteral => string('select');
  Parser get genderClause =>
      (genderKeyword & openCurly & interiorText & closeCurly)
          .trim()
          .map((result) => [result[0], result[2]]);
  Parser get gender =>
      preface & selectLiteral & comma & genderClause.plus() & closeCurly;
  Parser get intlGender => gender.map((values) {
        _extractArgumentIfNeeded(values.first);
        Gender.from(values.first, values[3], null);
      });
  Parser get selectClause =>
      (id & openCurly & interiorText & closeCurly).map((x) => [x.first, x[2]]);
  Parser get generalSelect =>
      preface & selectLiteral & comma & selectClause.plus() & closeCurly;
  Parser get intlSelect => generalSelect.map(
        (values) {
          _extractArgumentIfNeeded(values.first);
          return Select.from(values.first, values[3], null);
        },
      );

  Parser get pluralOrGenderOrSelect => intlPlural | intlGender | intlSelect;

  Parser get contents => pluralOrGenderOrSelect | parameter | messageText;
  Parser get simpleText => (nonIcuMessageText | parameter | openCurly).plus();
  Parser get empty => epsilon().map((_) => '');

  Parser get parameter => (openCurly & id & closeCurly).map((param) {
        _extractArgumentIfNeeded(param[1]);
        return VariableSubstitution.named(param[1], null);
      });

  /// The primary entry point for parsing. Accepts a string and produces
  /// a parsed representation of it as a Message.
  Parser get message => (pluralOrGenderOrSelect | simpleText | empty)
      .map((chunk) => Message.from(chunk, mainMessage));

  final bool extractArguments;
  final MainMessage mainMessage;

  _IcuParser([this.mainMessage, this.extractArguments = false]) {
    // There is a cycle here, so we need the explicit set to avoid
    // infinite recursion.
    interiorText.set(contents.plus() | empty);
  }

  // If extractArguments is true and a MainMessage parent exits it will
  // extract the arguments to the MainMessage
  //
  // This is used when the templated is not generated from intl dart code.
  _extractArgumentIfNeeded(String arg) {
    if (mainMessage == null || !extractArguments) return;
    mainMessage.arguments ??= [];
    if (!mainMessage.arguments.contains(arg)) {
      mainMessage.arguments.add(arg);
    }
  }
}

/// A message generated from a icu string.
/// The arguments are added to the parent from
/// the message instead from the dart functions
class IcuMessage {
  static Message fromIcu(String icuString, [Message parent]) {
    final _IcuParser parser = _IcuParser();
    final Message message = parser.message.parse(icuString).value;
    return message..parent = parent;
  }
}

/// A main message generated from a icu string.
/// The arguments are extracted from
/// the message instead from the dart functions
class IcuMainMessage extends MainMessage {
  IcuMainMessage._();

  factory IcuMainMessage(String icuString, [String name]) {
    final message = IcuMainMessage._()
      ..arguments = []
      ..name = name
      ..id = name;

    final _IcuParser parser = _IcuParser(message, true);
    message.addPieces([parser.message.parse(icuString).value]);

    return message;
  }
}

/// Return a version of the message string with with ICU parameters "{variable}"
/// rather than Dart interpolations "$variable".
String messageToIcuString(Message message) {
  return message.expanded(_turnInterpolationIntoICUForm);
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
  return s.replaceAll("'", "''").replaceAll("{", "'{'").replaceAll("}", "'}'");
}
