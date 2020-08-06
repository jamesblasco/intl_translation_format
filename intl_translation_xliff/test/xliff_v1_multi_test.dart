import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_format/test.dart';


import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:test/test.dart';

void main() {
  group('Xliff v1.2 Multilingual Format -', () {
    testMultiLingualFormatWithDefaultMessages(
      MultipleLanguageXliffFormat(XliffVersion.v1),
      simpleMessage: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd" version="1.2" source-language="en" target-language="es"  target-language="es" >
  <file>
    <trans-unit id="simpleMessage">
      <notes>
        <note category="format">icu</note>
      </notes>
      <source>Simple Message</source>
      <target>Mensaje simple</target>
    </trans-unit>
  </file>
</xliff>''',
      messageWithMetadata: '''
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
</xliff>''',
      pluralMessage: '''
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
</xliff>''',
      messageWithVariable: '''<?xml version="1.0 encoding="UTF-8""?>
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
</xliff>''',
      allMessages: '''
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
</xliff>''',
    );
  });
}