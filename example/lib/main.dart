import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n_ota/dart_intl.dart';
import 'l10n_ota/flutter_localization.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTA Localization'),
      ),
      body: Column(
        children: <Widget>[
          DartIntl(),
          LocalizationFlutter(),
        ],
      ),
    );
  }
}

String get text => Intl.message('text');

String get textWithMetadata =>
    Intl.message('textWithMetadata', examples: {'a': 'hello'});

String variable(int variable) =>
    Intl.message('Hello $variable', name: 'variable', args: [variable]);

String pluralExample(int howMany) => Intl.plural(howMany,
    zero: 'No items',
    one: 'One item',
    many: 'A lot of items',
    other: '$howMany items',
    name: 'pluralExample',
    args: [howMany]);
