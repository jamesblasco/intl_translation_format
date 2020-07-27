import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';
import 'package:xml/xml_events.dart';

// http://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html

typedef _ParseFunc = Element Function(XliffParserState parserState);
final Map<String, _ParseFunc> elementParsers = <String, _ParseFunc>{
  'xliff': (e) => XliffElement(e),
  'file': (e) => FileElement(e),
  'group': (e) => GroupElement(e),
  'unit': (e) => UnitElement(e),
  'segment': (e) => SegmentElement(e),
  'ignorable': (e) => IgnorableElement(e),
  'source': (e) => SourceElement(e),
  //v1.2
  'body': (e) => BodyElement(e),
};

abstract class Element {
  Element(this._state)
      : depth = _state.depth,
        parent = _state.depth == _state.currentElement?.depth
            ? _state.currentElement?.parent
            : _state.currentElement {
    _state.elementCountForCurrentDepth()[key] ??= 0;
    _state.elementCountForCurrentDepth()[key] += 1;
    if (!allowsMultiple && _state.elementCountForCurrentDepth()[key] > 1) {
      throw XliffParserException(
          title: 'Multiple $key elements are not allowed');
    }
    attributes = Map.fromEntries(
      _generateAttributes().map(
        (e) => MapEntry(e.name, e.value),
      ),
    );
  }
  final int depth;
  final Element parent;

  void warn(String content) {
    _state.warn(content);
  }

  bool get required => false; //Not usable yet
  bool get allowsMultiple => true; //Not usable yet

  bool get shouldParseTextChild => false;
  void parseTextChild(XmlTextEvent event) {}

  final XliffParserState _state;

  List<String> get requiredAttributes => [];
  List<String> get optionalAttributes => [];

  String get key;

  Iterable<XmlEventAttribute> _generateAttributes() sync* {
    final attributes = List.from(_state.attributes);
    for (final att in requiredAttributes) {
      final result = _state.attributes
          .firstWhere((e) => e.name == att, orElse: () => null);
      if (result != null) {
        attributes.remove(result);
        yield result;
      } else {
        throw XliffParserException(
            title: '$att attribute is required for <$key>');
      }
    }
    for (final att in optionalAttributes) {
      final result = _state.attributes
          .firstWhere((e) => e.name == att, orElse: () => null);
      if (result != null) {
        attributes.remove(result);
        yield result;
      }
    }
    if (attributes.isNotEmpty) {
      warn(
          'Extra arguments ${attributes.map((e) => e.name).join(', ')} in $key will not be parsed');
    }
  }

  Map<String, String> attributes;

  void onStart() {}
  void onEnd() {}
}

///
/// Root element for XLIFF documents.
///
/// Contains:
///
/// - One or more <file> elements
/// Attributes:
///
/// - version, REQUIRED
/// - srcLang, REQUIRED
/// - trgLang, OPTIONAL
/// - xml:space, OPTIONAL
/// - attributes from other namespaces, OPTIONAL
/// Constraints
///
/// The trgLang attribute is REQUIRED if and only if the XLIFF Document contains <target> elements that are children of <segment> or <ignorable>.
///
class XliffElement extends Element {
  final XliffParserState parserState;
  XliffElement(this.parserState) : super(parserState);

  @override
  bool get allowsMultiple => false;

  @override
  bool get required => true;

  @override
  List<String> get requiredAttributes => ['version', 'srcLang'];
  @override
  List<String> get optionalAttributes => ['trgLang', 'xml:space'];

  @override
  String get key => 'xliff';

  @override
  void onStart() {
    if (parserState.root != null) {
      throw XliffParserException(
          title: 'Unsupported nested <xliff> element.',
          description:
              'The root <xliff> element contained an unsupported nested Xliff element.',
          context: 'In element <xliff>');
    }

    final version = attributes['version'];
    final srcLang = attributes['srcLang'];
    final trgLang = attributes['trgLang'];

    if (!parserState.multilingual && trgLang != null) {
      throw XliffParserException(
          title: 'Invalid Xliff parser.',
          description:
              'Current format ${keyForVersion(parserState.version)} does not '
              'support multiple locales in the same file, use '
              '${keyForVersion(parserState.version, true)} instead',
          context: 'In element <xliff>');
    }

    final parsedVersion = parseVersion(version);
    if (parserState.version != parsedVersion) {
      throw XliffParserException(
          title: 'Invalid Xliff version parser',
          description: 'Using format ${keyForVersion(parserState.version)}, '
              'while the file format ${version} requires ${parsedVersion}}',
          context: 'In element <xliff>');
    }

    parserState.root = MessagesForLocale({}, locale: srcLang);
  }

  XliffVersion parseVersion(String version) {
    switch (version) {
      case '2.0':
        return XliffVersion.v2;
      case '1.2':
        return XliffVersion.v1;
      default:
        throw 'Xliff version $version is not supported';
    }
  }
}

///
/// Container for localization material extracted from an entire single document, or another high level self
/// contained logical node in a content structure that cannot be described in the terms of documents.
///
/// NOT SUPPORTED YET, all localization material from different files will be grouped together
///
///
class FileElement extends Element {
  final XliffParserState parserState;
  FileElement(this.parserState) : super(parserState);

  @override
  bool get required => true;

  @override
  String get key => 'file';

  @override
  void onStart() {
    warn(
        'Multiple files will be omitted and all localization material will be grouped in a single file');
  }
}

class GroupElement extends Element {
  final XliffParserState parserState;
  GroupElement(this.parserState) : super(parserState);

  @override
  String get key => 'group';

  @override
  void onStart() {
    warn(
        'Multiple groups will be omitted and all localization material will be group in a single group');
  }
}

/// Static container for a dynamic structure of elements holding the
/// extracted translatable source text, aligned with the Translated text.
///
class UnitElement extends Element {
  final XliffParserState parserState;
  UnitElement(this.parserState) : super(parserState);

  @override
  List<String> get requiredAttributes => ['id'];

  @override
  String get key =>
      parserState.version == XliffVersion.v2 ? 'unit' : 'trans-unit';

  @override
  void onStart() {
    final id = attributes['id'];
    assert(parserState.currentTranslationId == null,
        'The parser is already parsing a message with id: ${parserState.currentTranslationId}');
    parserState.currentTranslationId = id;
    //warn(id);
  }

  @override
  void onEnd() {
    final id = attributes['id'];
    assert(parserState.currentTranslationId != null,
        'The current state is not parsing this element id: $id');

    if (parserState.root.messages[id] != null) {
      warn(
          'A message with the same id $id already exits and it will be overrided');
    }
    parserState.root.messages[id] = BasicTranslatedMessage(
      id,
      messageParser.parse(parserState.currentTranslationMessage).value,
    );
    parserState.currentTranslationId = null;
    parserState.currentTranslationMessage = null;
  }
}

/// This element is a container to hold in its aligned pair of children
/// elements the minimum portion of translatable source text and its
/// Translation in the given Segmentation.
///
/// We don't support segment ordering
/// We join multiple segments. This is not allowed when order is  not consecutive.
/// http://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html#segmentation
///
///
class SegmentElement extends Element {
  final XliffParserState parserState;
  SegmentElement(this.parserState) : super(parserState);

  @override
  String get key => 'segment';

  @override
  void onStart() {}
}

/// Part of the extracted content that is not included in a segment
/// (and therefore not translatable).
///
/// For example tools can use <ignorable> to store the white space and/or codes
/// that are between two segments.
///
///
class IgnorableElement extends Element {
  final XliffParserState parserState;
  IgnorableElement(this.parserState) : super(parserState);

  @override
  String get key => 'ignorable';

  @override
  void onStart() {}
}

/// Portion of text to be translated.
///
///
class SourceElement extends Element {
  final XliffParserState parserState;
  SourceElement(this.parserState) : super(parserState);

  @override
  String get key => 'source';

  @override
  void onStart() {}

  @override
  bool get shouldParseTextChild => true;

  @override
  void parseTextChild(XmlTextEvent event) {
    parserState.currentTranslationMessage ??= '';
    parserState.currentTranslationMessage += event.text;
  }
}

/* 
TBD


/// The translation of the sibling <source> element.
/// 
///
class TargetElement extends Element {
  final XliffParserState parserState;
  TargetElement(this.parserState) : super(parserState);

  @override
  String get key => 'target';

  @override
  void parse() {
   
  }
} */

/// V1.2
class BodyElement extends Element {
  final XliffParserState parserState;
  BodyElement(this.parserState) : super(parserState);

  @override
  String get key => 'body';

  @override
  void onStart() {}
}
