import 'package:xml/xml_events.dart';

class XmlParserException implements Exception {
  final String title;
  final String description;
  final String context;

  XmlParserException({this.title, this.description, this.context});

  @override
  String toString() {
    return '''
    Error while parsing xml
    $title:
    $description,
    Context: $context
    ''';
  }
}

abstract class Element<T extends XmlParserState> {
  Element();

  T _state;

  T get state {
    if (_state == null) {
      throw 'Used state before the xml parse state creates this element';
    }
    return _state;
  }

  void _init(T state, Iterable<XmlEventAttribute> _attributes) {
    _state = state;
    depth = state.depth;
    parent = state.depth == state.currentElement?.depth
        ? state.currentElement?.parent
        : state.currentElement;

    state.elementCountForCurrentDepth[key] ??= 0;
    state.elementCountForCurrentDepth[key] += 1;

    if (!allowsMultiple && state.elementCountForCurrentDepth[key] > 1) {
      throw XmlParserException(
          title: 'Multiple <$key> elements are not allowed');
    }

    attributes = Map.fromEntries(
      _verifiedAttributes(_attributes).map(
        (e) => MapEntry(e.name, e.value),
      ),
    );
  }

  void warn(String content) {
    state.warn(content);
  }

  Element parent;
  int depth;

  bool get required => false; //Not usable yet
  bool get allowsMultiple => true; //Not usable yet

  void parseTextChild(XmlTextEvent event) {}

  Set<String> get requiredAttributes => {};
  Set<String> get optionalAttributes => {};

  String get key;

  Map<String, String> attributes;

  Iterable<XmlEventAttribute> _verifiedAttributes(
      Iterable<XmlEventAttribute> attributes) sync* {
    final _attributes = List.from(attributes);
    for (final att in requiredAttributes) {
      final result = _attributes.firstWhere(
        (e) => e.name == att,
        orElse: () => null,
      );
      if (result != null) {
        _attributes.remove(result);
        yield result;
      } else {
        throw XmlParserException(
            title: '\'$att\' attribute is required for <$key>');
      }
    }
    for (final att in optionalAttributes) {
      final result =
          _attributes.firstWhere((e) => e.name == att, orElse: () => null);
      if (result != null) {
        _attributes.remove(result);
        yield result;
      }
    }
    if (_attributes.isNotEmpty) {
      warn(
          'Extra arguments ${attributes.map((e) => e.name).join(', ')} in <$key> will not be parsed');
    }
  }

  void onStart() {}
  void onEnd() {}
}

/// Maintains state while pushing an [XmlPushReader] through the XML tree.
abstract class XmlParserState<T> {
  /// Creates a new [XmlParserState].
  XmlParserState(
    Iterable<XmlEvent> events,
    this._debugKey, {
    this.displayWarnings = true,
  })  : assert(events != null),
        _eventIterator = events.iterator;

  // Iterator that contains all the xml events
  final Iterator<XmlEvent> _eventIterator;

  // Key for refering parser state while debug
  final String _debugKey;

  // Display warning logs while debug
  bool displayWarnings;

  //List<XmlEventAttribute> _currentAttributes;

  XmlStartElementEvent currentStartElement;

  /// The current depth of the reader in the XML hierarchy.
  int depth = 0;

  final Map<int, Map<String, int>> _elementCountByDepth = {};

  Map<String, int> get elementCountForCurrentDepth {
    return _elementCountByDepth[depth] ??= {};
  }

  void _discardSubtree() {
    for (final _ in _readSubtree()) {
      // Ignore all subtrees
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
        currentStartElement = event;
        depth += 1;
        isSelfClosing = event.isSelfClosing;
      }
      yield event;

      if (isSelfClosing || event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);

        currentStartElement = null;
      }
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  Element currentElement;

  T get value;

  Map<String, ElementBuilder> get elementHandlers;

  /// Drive the [XmlTextReader] to EOF and produce a [DrawableRoot].
  T parse() {
    for (final event in _readSubtree()) {
      if (event is XmlStartElementEvent) {
        final element = elementHandlers[event.name]?.call();

        // If not element handler is found, we discard all the subtree
        if (element == null) {
          if (!event.isSelfClosing) {
            _discardSubtree();
          }
          assert(() {
            unhandledElement(event);
            return true;
          }());
        } else {
          startElement(event);
          element._init(this, event.attributes);
          currentElement = element;
          currentElement.onStart();
        }
      } else if (event is XmlEndElementEvent) {
        currentElement.onEnd();
        currentElement = currentElement.parent;
        endElement(event);
      } else if (event is XmlTextEvent) {
        currentElement?.parseTextChild(event);
      }
    }
    return value;
  }

  /// Handles the start of an XML element.
  void startElement(XmlStartElementEvent event) {
    warn('Start Event <${event.name}>');
  }

  /// Handles the end of an XML element.
  void endElement(XmlEndElementEvent event) {
    warn('End Event </${event.name}>');
  }

  /// Prints an error for unhandled elements.
  ///
  /// Will only print an error once for unhandled/unexpected elements
  void unhandledElement(XmlStartElementEvent event) {
    warn('Unhandled element <${event.name}>');
  }

  void warn(Object content) {
    if (displayWarnings) print('${content}, Key: $_debugKey');
  }
}

typedef ElementBuilder<T> = Element Function();
