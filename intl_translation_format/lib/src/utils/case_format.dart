import 'dart:core';

enum Case {
  /// camelCase
  camelCase,

  /// CONSTANT_CASE
  constantCase,

  /// Sentence case
  sentenceCase,

  // snake_case
  snakeCase,

  /// dot.case
  dotCase,

  /// param-case
  paramCase,

  /// path/case
  pathCase,

  /// PascalCase
  pascalCase,

  /// Header-Case
  headerCase,

  /// Title Case
  titleCase,

  /// colon:case
  colonCase,

  /// double::colon::case
  doubleColonCase,
}

class CaseFormat {
  static final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
  static final RegExp _symbolRegex = RegExp(r'[ ./_\-:]');

  final Case textCase;
  CaseFormat(this.textCase);

  String parse(String text) {
    final _words = _groupIntoWords(text);
    switch (textCase) {
      case Case.camelCase:
        return _getCamelCase(_words);
      case Case.constantCase:
        return _getConstantCase(_words);
      case Case.sentenceCase:
        return _getSentenceCase(_words);
      case Case.snakeCase:
        return _getSnakeCase(_words);
      case Case.dotCase:
        return _getSnakeCase(_words, separator: '.');
      case Case.paramCase:
        return _getSnakeCase(_words, separator: '-');
      case Case.pathCase:
        return _getSnakeCase(_words, separator: '/');
      case Case.pascalCase:
        return _getPascalCase(_words);
      case Case.headerCase:
        return _getPascalCase(_words, separator: '-');
      case Case.titleCase:
        return _getPascalCase(_words, separator: ' ');
      case Case.colonCase:
        return _getSnakeCase(_words, separator: ':');
      case Case.doubleColonCase:
        return _getSnakeCase(_words, separator: '::');
    }
  }

  static List<String> _groupIntoWords(String text) {
    StringBuffer sb = StringBuffer();
    List<String> words = [];
    bool isAllCaps = !text.contains(RegExp('[a-z]'));

    for (int i = 0; i < text.length; i++) {
      String char = String.fromCharCode(text.codeUnitAt(i));
      String nextChar = (i + 1 == text.length
          ? null
          : String.fromCharCode(text.codeUnitAt(i + 1)));

      if (_symbolRegex.hasMatch(char)) {
        continue;
      }

      sb.write(char);

      bool isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          _symbolRegex.hasMatch(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  static String _getCamelCase(List<String> words, {String separator = ''}) {
    List<String> _words = words.map(_upperCaseFirstLetter).toList();
    _words[0] = _words[0].toLowerCase();

    return _words.join(separator);
  }

  static String _getConstantCase(List<String> words, {String separator = '_'}) {
    List<String> _words = words.map((word) => word.toUpperCase()).toList();

    return _words.join(separator);
  }

  static String _getPascalCase(List<String> words, {String separator = ''}) {
    List<String> _words = words.map(_upperCaseFirstLetter).toList();

    return _words.join(separator);
  }

  static String _getSentenceCase(List<String> words, {String separator: ' '}) {
    List<String> _words = words.map((word) => word.toLowerCase()).toList();
    _words[0] = _upperCaseFirstLetter(words[0]);

    return _words.join(separator);
  }

  static String _getSnakeCase(List<String> words, {String separator = '_'}) {
    List<String> _words = words.map((word) => word.toLowerCase()).toList();

    return _words.join(separator);
  }

  static String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
