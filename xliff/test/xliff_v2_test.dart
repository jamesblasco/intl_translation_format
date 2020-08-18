import 'package:intl_translation_format/intl_translation_format.dart';

import 'package:intl_translation_format/test/format_test.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:test/test.dart';

void main() {
  group('Xliff v2.0 Format -', () {
    
    testFormatParserWithDefaultMessages(XliffFormat(), simpleMessage: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="simpleMessage" name="simpleMessage">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
  </file>
</xliff>''', messageWithMetadata: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
          <note category="description">This is a description</note>
        </notes>
        <source>Message With Metadata</source>
      </segment>
    </unit>
  </file>
</xliff>''', pluralMessage: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
  </file>
</xliff>''', messageWithVariable: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''', allMessages: '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" version="2.0" srcLang="en">
  <file>
    <unit id="simpleMessage" name="simpleMessage">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Simple Message</source>
      </segment>
    </unit>
    <unit id="messageWithMetadata" name="messageWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
          <note category="description">This is a description</note>
        </notes>
        <source>Message With Metadata</source>
      </segment>
    </unit>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
    <unit id="messageWithVariable" name="messageWithVariable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Share {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''');
  });
}
