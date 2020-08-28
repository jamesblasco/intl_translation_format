import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test_utils.dart';

import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:test/test.dart';

void main() {
  group('Xliff v1.2 -', () {
    group('with Target Language -', () {
      testFormat(_ParserTesterWithTargetLanguage());
    });

    testFormat(_ParserTester());

    testFormat(_TemplateGenerationTester());
  });
}

// Tests for xliff v1.2 with a target language
class _ParserTesterWithTargetLanguage extends MultilingualParsingTester {
  @override
  MultiLingualFormat get format => XliffFormat(XliffVersion.v1);

  @override
  String get simpleMessage => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es" >
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
      <target>Mensaje simple</target>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get messageWithMetadata => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es" >
  <file>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
      <target>Mensaje con Metadatos</target>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get pluralMessage => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es" >
  <file>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      <target>{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}</target>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get variableMessage => '''<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es" >
  <file>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
      <target>Compartir {variable}</target>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get allMessages => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es" >
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
      <target>Mensaje simple</target>
    </trans-unit>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
      <target>Mensaje con Metadatos</target>
    </trans-unit>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      <target>{howMany,plural, =0{Ningún elemento}=1{Un elemento}many{Muchos elementos}other{{howMany} elementos}}</target>
    </trans-unit>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
      <target>Compartir {variable}</target>
    </trans-unit>
  </file>
</xliff>''';
}

// Tests for xliff v1.2 without a target language
class _ParserTester extends MultilingualParsingTester {
  @override
  MultiLingualFormat get format => XliffFormat(XliffVersion.v1);

  @override
  String get simpleMessage => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get messageWithMetadata => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get pluralMessage => '''
<?xml version="1.0 encoding="UTF-8""?>  
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get variableMessage => '''
<?xml version="1.0 encoding="UTF-8""?>  
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </trans-unit>
  </file>
</xliff>''';

  @override
  String get allMessages => '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
    </trans-unit>
    <trans-unit id="messageWithMetadata">
      <notes>
        <note category="format">icu</note>
        <note category="description">This is a description</note>
      </notes>
      <source>Message With Metadata</source>
    </trans-unit>
    <trans-unit id="pluralExample">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
    </trans-unit>
    <trans-unit id="messageWithVariable">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Share {variable}</source>
    </trans-unit>
  </file>
</xliff>''';
}

class _TemplateGenerationTester extends MultilingualGenerateTemplateTester {
  @override
  TranslationFormat<StringFileData> get format => XliffFormat(XliffVersion.v1);
  @override
  String get templateSimpleMessage => '<?xml version="1.0 encoding="UTF-8""?>\n'
      '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
      '  <file>\n'
      '    <trans-unit id="simpleMessage">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>Simple Message</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '  </file>\n'
      '</xliff>';

  @override
  String get templateMessageWithMetadata =>
      '<?xml version="1.0 encoding="UTF-8""?>\n'
      '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
      '  <file>\n'
      '    <trans-unit id="messageWithMetadata">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '        <note category="description">This is a description</note>\n'
      '      </notes>\n'
      '      <source>Message With Metadata</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '  </file>\n'
      '</xliff>';

  @override
  String get templatePluralMessage => '<?xml version="1.0 encoding="UTF-8""?>\n'
      '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
      '  <file>\n'
      '    <trans-unit id="pluralExample">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '  </file>\n'
      '</xliff>';

  @override
  String get templateVariableMessage =>
      '<?xml version="1.0 encoding="UTF-8""?>\n'
      '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
      '  <file>\n'
      '    <trans-unit id="messageWithVariable">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>Share {variable}</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '  </file>\n'
      '</xliff>';
  @override
  String get templateAllMessages => '<?xml version="1.0 encoding="UTF-8""?>\n'
      '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en">\n'
      '  <file>\n'
      '    <trans-unit id="simpleMessage">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>Simple Message</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '    <trans-unit id="messageWithMetadata">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '        <note category="description">This is a description</note>\n'
      '      </notes>\n'
      '      <source>Message With Metadata</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '    <trans-unit id="pluralExample">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '    <trans-unit id="messageWithVariable">\n'
      '      <notes>\n'
      '        <note category="format">icu</note>\n'
      '      </notes>\n'
      '      <source>Share {variable}</source>\n'
      '      <target></target>\n'
      '    </trans-unit>\n'
      '  </file>\n'
      '</xliff>';
}
