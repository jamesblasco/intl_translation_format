import 'package:intl_translation_format/src/utils/case_format.dart';
import 'package:test/test.dart';

void main() {
  test('camelCase - generate', () {
    final result = CaseFormat(Case.camelCase).parse('exampleCase');
    expect(result, 'exampleCase');
  });

  test('camelCase - extract', () {
    final result = CaseFormat(Case.camelCase).parse('exampleCase');
    expect(result, 'exampleCase');
  });

  test('CONSTANT_CASE - generate', () {
    final result = CaseFormat(Case.constantCase).parse('exampleCase');
    expect(result, 'EXAMPLE_CASE');
  });

  test('CONSTANT_CASE  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('EXAMPLE_CASE');
    expect(result, 'exampleCase');
  });

  test('Sentence case - generate', () {
    final result = CaseFormat(Case.sentenceCase).parse('exampleCase');
    expect(result, 'Example case');
  });

  test('Sentence case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('Example case');
    expect(result, 'exampleCase');
  });

  test('snake_case - generate', () {
    final result = CaseFormat(Case.snakeCase).parse('exampleCase');
    expect(result, 'example_case');
  });

  test('snake_case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example_case');
    expect(result, 'exampleCase');
  });

  test('dot.case - generate', () {
    final result = CaseFormat(Case.dotCase).parse('exampleCase');
    expect(result, 'example.case');
  });

  test('dot.case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example.case');
    expect(result, 'exampleCase');
  });

  test('param-case - generate', () {
    final result = CaseFormat(Case.paramCase).parse('exampleCase');
    expect(result, 'example-case');
  });

  test('param-case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example-case');
    expect(result, 'exampleCase');
  });

  test('path/case - generate', () {
    final result = CaseFormat(Case.pathCase).parse('exampleCase');
    expect(result, 'example/case');
  });

  test('path/case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example/case');
    expect(result, 'exampleCase');
  });

  test('PascalCase - generate', () {
    final result = CaseFormat(Case.pascalCase).parse('exampleCase');
    expect(result, 'ExampleCase');
  });

  test('PascalCase  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('ExampleCase');
    expect(result, 'exampleCase');
  });

  test('Header-Case - generate', () {
    final result = CaseFormat(Case.headerCase).parse('exampleCase');
    expect(result, 'Example-Case');
  });

  test('Header-Case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('Example-Case');
    expect(result, 'exampleCase');
  });

  test('Title Case - generate', () {
    final result = CaseFormat(Case.titleCase).parse('exampleCase');
    expect(result, 'Example Case');
  });

  test('Title Case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('Example Case');
    expect(result, 'exampleCase');
  });
  test('colon:case - generate', () {
    final result = CaseFormat(Case.colonCase).parse('exampleCase');
    expect(result, 'example:case');
  });

  test('colon:case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example:case');
    expect(result, 'exampleCase');
  });

  test('double::colon::case - generate', () {
    final result = CaseFormat(Case.doubleColonCase).parse('exampleCase');
    expect(result, 'example::case');
  });

  test('double::colon::case  - extract', () {
    final result = CaseFormat(Case.camelCase).parse('example::case');
    expect(result, 'exampleCase');
  });
}
