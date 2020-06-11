import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
  String get currentLocale => Intl.defaultLocale;
  set currentLocale(String locale) => Intl.defaultLocale = locale;

  List<String> supportedLanguages = ["es", "en"];

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future setup() async {
    for (final local in supportedLanguages) {
      final couldLoad = await initializeMessages(local);
      log('Local $local loaded: $couldLoad');
    }

    setState(() {
      currentLocale = supportedLanguages.first;
    });
  }

  void showLanguages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: supportedLanguages
            .map((locale) => ListTile(
                  title: Text(locale),
                  onTap: () {
                    if (locale != currentLocale) {
                      setState(() {
                        currentLocale = locale;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locale: $currentLocale'),
      ),
      body: Center(child: Localized()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showLanguages(context),
        tooltip: 'Increment',
        child: Icon(Icons.language),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Localized extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text),
        Text(
          textWithMetadata,
        ),
        Text(
          pluralExample(2),
        ),
      ],
    );
  }
}
