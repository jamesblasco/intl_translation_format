import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';
import 'package:intl_translation_xliff/src/parser/xml_parser.dart';
import 'package:xml/xml_events.dart';

// http://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html

abstract class XliffElement extends Element<XliffParserState> {}

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
class XliffRootElement extends XliffElement {
  XliffRootElement();

  @override
  bool get allowsMultiple => false;

  @override
  bool get required => true;

  @override
  Set<String> get requiredAttributes => {
        'version',
        if (state.version == XliffVersion.v2) 'srcLang' else 'source-language',
      };
  @override
  Set<String> get optionalAttributes => {
        if (state.version == XliffVersion.v2)
          'trgLang'
        else if (state.multilingual)
          'target-language',
        'xml:space',
      };

  @override
  String get key => 'xliff';

  @override
  void onStart() {
    if (state.sourceMessages != null) {
      throw XliffParserException(
          title: 'Unsupported nested <xliff> element.',
          description:
              'The root <xliff> element contained an unsupported nested Xliff element.',
          context: 'In element <xliff>');
    }

    final version = attributes['version'];

    final parsedVersion = parseVersion(version);
    if (state.version != parsedVersion) {
      throw XliffParserException(
          title: 'Invalid Xliff version parser',
          description: 'Using format ${keyForVersion(state.version)}, '
              'while the file format ${version} requires ${parsedVersion}}',
          context: 'In element <xliff>');
    }

    final srcLang = state.version == XliffVersion.v2
        ? attributes['srcLang']
        : attributes['source-language'];
    final trgLang = state.version == XliffVersion.v2
        ? attributes['trgLang']
        : attributes['target-language'];

    if (state.sourceLocale != null && srcLang != state.sourceLocale) {
      throw XliffParserException(
          title: 'Invalid scrLang.',
          description: 'scrLang was expected to be ${state.sourceLocale} ',
          context: 'In element <xliff>');
    }

    if (trgLang != null) {
      state.multilingual = true;
    }

    state.sourceMessages = MessagesForLocale({}, locale: srcLang);

    if (state.multilingual) {
      state.targetMessages = MessagesForLocale({}, locale: trgLang);
    }
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
class FileElement extends XliffElement {
  FileElement();

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
  GroupElement() : super();

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
class UnitElement extends XliffElement {
  UnitElement();

  @override
  Set<String> get requiredAttributes => {'id'};

  @override
  String get key => state.version == XliffVersion.v2 ? 'unit' : 'trans-unit';

  @override
  void onStart() {
    final id = attributes['id'];
    assert(state.currentTranslationId == null,
        'The parser is already parsing a message with id: ${state.currentTranslationId}');
    state.currentTranslationId = id;
    //warn(id);
  }

  @override
  void onEnd() {
    final id = attributes['id'];
    assert(state.currentTranslationId != null,
        'The current state is not parsing this element id: $id');

    if (state.sourceMessages.messages[id] != null) {
      warn(
          'A message with the same id $id already exits and it will be overrided');
    }
    state.sourceMessages.messages[id] = BasicTranslatedMessage(
      id,
      IcuMessage.fromIcu(state.currentTranslationMessage),
    );

    if (state.multilingual) {
      if (state.currentTargetTranslationMessage == null) {
        throw XliffParserException(
            title: 'Not target message found.', context: 'In element <$key>');
      }
      state.targetMessages.messages[id] = BasicTranslatedMessage(
        id,
        IcuMessage.fromIcu(state.currentTargetTranslationMessage),
      );
    }

    state.currentTranslationId = null;
    state.currentTranslationMessage = null;
    state.currentTargetTranslationMessage = null;
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
  SegmentElement() : super();

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
class IgnorableElement extends XliffElement {
  IgnorableElement() : super();

  @override
  String get key => 'ignorable';

  @override
  void onStart() {}
}

/// Portion of text to be translated.
///
///
class SourceElement extends XliffElement {
  SourceElement();

  @override
  String get key => 'source';

  @override
  void onStart() {}

  @override
  void parseTextChild(XmlTextEvent event) {
    state.currentTranslationMessage ??= '';
    state.currentTranslationMessage += event.text;
  }
}

/// The translation of the sibling <source> element.
///
///
class TargetElement extends XliffElement {
  TargetElement();

  @override
  String get key => 'target';

  @override
  void onStart() {}

  @override
  void parseTextChild(XmlTextEvent event) {
    state.currentTargetTranslationMessage ??= '';
    state.currentTargetTranslationMessage += event.text;
  }
}

/// V1.2
class BodyElement extends XliffElement {
  BodyElement();

  @override
  String get key => 'body';

  @override
  void onStart() {}
}
