import 'dart:math';

import 'package:intl_translation_xliff/src/xliff_data.dart';
import 'package:intl_translation_xliff/src/xml_parsers.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'elements.dart';

enum XliffVersion { v2, v1 }

class XliffParser {
  final bool displayWarnings;

  XliffParser({this.displayWarnings = true});

  /// Parses SVG from a string to a [DrawableRoot].
  ///
  /// The [key] parameter is used for debugging purposes.
  Future<LocaleTranslationData> parse(String str, {String key}) async {
    return await XliffParserState(parseEvents(str), key,
            displayWarnings: displayWarnings)
        .parse();
  }
}

class XliffParserException implements Exception {
  final String title;
  final String description;
  final String context;

  XliffParserException({this.title, this.description, this.context});

  @override
  String toString() {
    return '''
    Error while parsing xliff
    $title:
    $description,
    Context: $context
    ''';
  }
}

/// The implementation of [XliffParser].
///
/// Maintains state while pushing an [XmlPushReader] through the XML tree.
class XliffParserState {
  /// Creates a new [XliffParserState].
  XliffParserState(Iterable<XmlEvent> events, this._key,
      {this.displayWarnings = true})
      : assert(events != null),
        _eventIterator = events.iterator;

  final Iterator<XmlEvent> _eventIterator;
  bool displayWarnings;

  final String _key;

  LocaleTranslationData root;
  XliffVersion version;

  List<XmlEventAttribute> _currentAttributes;
  XmlStartElementEvent currentStartElement;

  String currentTranslationId;
  String currentTranslationMessage;

  final Map<int, Map<String, int>> _elementCountByDepth = {};

  Map<String, int> elementCountForCurrentDepth() {
    return _elementCountByDepth[depth] ??= {};
  }

  /// The current depth of the reader in the XML hierarchy.
  int depth = 0;

  void _discardSubtree() {
    final subtreeStartDepth = depth;
    while (_eventIterator.moveNext()) {
      final event = _eventIterator.current;
      if (event == null) {
        return;
      }
      if (event is XmlStartElementEvent && !event.isSelfClosing) {
        depth += 1;
      } else if (event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
      }
      _currentAttributes = <XmlEventAttribute>[];
      currentStartElement = null;
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  Iterable<XmlEvent> _readSubtree() sync* {
    final subtreeStartDepth = depth;
    while (_eventIterator.moveNext()) {
      final event = _eventIterator.current;
      if (event == null) {
        return;
      }
      var isSelfClosing = false;
      if (event is XmlStartElementEvent) {
        _currentAttributes = event.attributes;
        currentStartElement = event;
        depth += 1;
        isSelfClosing = event.isSelfClosing;
      }
      yield event;

      if (isSelfClosing || event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
        _currentAttributes = <XmlEventAttribute>[];
        currentStartElement = null;
      }
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  Element currentElement;

  /// Drive the [XmlTextReader] to EOF and produce a [DrawableRoot].
  Future<LocaleTranslationData> parse() async {
    for (final event in _readSubtree()) {
      if (event is XmlStartElementEvent) {
        if (startElement(event)) {
          continue;
        }
        final parseFunc = elementParsers[event.name];

        final element = await parseFunc?.call(this);

        if (parseFunc == null) {
          if (!event.isSelfClosing) {
            _discardSubtree();
          }
          assert(() {
            unhandledElement(event);
            return true;
          }());
        } else {
          currentElement = element;
          currentElement?.onStart();
        }
      } else if (event is XmlEndElementEvent) {
        currentElement?.onEnd();

        currentElement = currentElement.parent;
        endElement(event);
      } else if (event is XmlTextEvent) {
        if (currentElement?.shouldParseTextChild ?? false) {
          currentElement?.parseTextChild(event);
        }
      }
    }
    return root;
  }

  /// The XML Attributes of the current node in the tree.
  List<XmlEventAttribute> get attributes => _currentAttributes;

  /// Gets the attribute for the current position of the parser.
  String attribute(String name, {String def, String namespace}) =>
      getAttribute(attributes, name, def: def, namespace: namespace);

  /// Handles the end of an XML element.
  bool startElement(XmlStartElementEvent event) {
    warn('start $event');
    /*   if (event.name == _parentDrawables.last.name) {
      _parentDrawables.removeLast();
    }
    if (event.name == 'defs') {
      _inDefs = false;
    } */
    return false;
  }

  /// Handles the end of an XML element.
  void endElement(XmlEndElementEvent event) {
    warn('end $event');
    /*   if (event.name == _parentDrawables.last.name) {
      _parentDrawables.removeLast();
    }
    if (event.name == 'defs') {
      _inDefs = false;
    } */
  }

  /// Prints an error for unhandled elements.
  ///
  /// Will only print an error once for unhandled/unexpected elements, except for
  /// `<style/>`, `<title/>`, and `<desc/>` elements.
  void unhandledElement(XmlStartElementEvent event) {
    warn('unhandled element ${event.name}; Picture key: $_key');
  }

  void warn(Object content) {
    if (displayWarnings) print(content);
  }
}
