import 'dart:math';

import 'package:example/l10n/intl_messages_all.dart';
import 'package:example/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String get homePageTitle => Intl.message('Flutter Demo Home Page');

  @override
  Widget build(BuildContext context) {
    return DefaultLocaleController(
      initialLocale: 'en',
      availableLocales: ['en', 'es', 'gr'],
      child: Builder(
        builder: (context) {
          final locale = DefaultLocale.of(context).value;
          return MaterialApp(
            locale: Locale(locale),
            title: 'Flutter Demo - ${locale}',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: MyHomePage(
                title: homePageTitle + ' - ${locale}'),
          );
        },
      ),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter = max(_counter - 1, 0);
    });
  }

  String counterText(int value) => Intl.plural(value,
      zero: 'You haven\'t pushed the button yet',
      one: 'You have pushed the button one time',
      other: 'You have pushed the button $value times',
      args: [value],
      name: 'counterText');

  String get increment => Intl.message('Increment');

  String get decrement => Intl.message('Decrement');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(counterText(_counter)),
            SizedBox(height: 40),
            Row(
              children: [
                Spacer(flex: 2),
                FloatingActionButton(
                  backgroundColor: _counter != 0 ? null : Colors.grey,
                  onPressed: _counter != 0 ? _decrementCounter : null,
                  tooltip: decrement,
                  child: Icon(Icons.remove),
                ),
                Spacer(),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: increment,
                  child: Icon(Icons.add),
                ),
                Spacer(flex: 2),
              ],
            ),
            Spacer(),
            LocaleSwitcher(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
