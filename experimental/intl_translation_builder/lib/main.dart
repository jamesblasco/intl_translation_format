
import 'package:intl/intl.dart';



final String text = Intl.message('text');

final String textWithMetadata =
      Intl.message('textWithMetadata', examples: {'a': 'hello'});

String pluralExample(int howMany) => Intl.plural(howMany,
      zero: 'No items',
      one: 'One item',
      many: 'A lot of items',
      other: '$howMany items',
      name: 'pluralExample',
      args: [howMany]);