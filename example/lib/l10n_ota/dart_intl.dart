import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_translation_example/l10n/intl_messages_all.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_ota_flutter/intl_translation_ota_flutter.dart';

import '../main.dart';
import 'common.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text),
        Text(textWithMetadata),
        Text(pluralExample(0)),
        Text(pluralExample(2)),
      ],
    );
  }
}

class DartIntl extends StatefulWidget {
  @override
  _DartIntlState createState() => _DartIntlState();
}

class _DartIntlState extends State<DartIntl> {
  String get currentLocale => Intl.defaultLocale;

  set currentLocale(String locale) => Intl.defaultLocale = locale;

  List<String> availableLanguages = ['en', 'es'];

  @override
  void initState() {
    super.initState();
    if (Intl.defaultLocale == null)
      Intl.defaultLocale = availableLanguages.first;
    setup();
  }

  Future setup() async {
    for (final local in availableLanguages) {
      final couldLoad = await initializeMessages(local);
      log('Local "$local" loaded: $couldLoad');
    }

    setState(() {
      currentLocale = availableLanguages.first;
    });
  }

  Future addGermanTranslationFromAssets() async {
    try {
      final catalog = TranslationCatalog('intl_messages');
      await catalog.addTranslations(
        [AssetFile('assets/l10n/intl_messages_gr.json')],
        format: JsonFormat(),
      );
      TranslationLoader(catalog).initializeMessages('gr');

      availableLanguages.add('gr');
      setState(() {
        currentLocale = 'gr';
      });
    } catch (e) {
      log(e);
    }
  }

  Future addFrenchTranslationFromNetwork() async {
    final catalog = TranslationCatalog('intl_messages');

    await catalog.addTranslations(
      [
        NetworkFile(
          translationJsonFileUrl,
          'intl_messages_fr.json',
        )
      ],
      format: JsonFormat(),
    );

    TranslationLoader(catalog).initializeMessages('fr');
    availableLanguages.add('fr');
    setState(() {
      currentLocale = 'fr';
    });
  }

  @override
  Widget build(BuildContext context) {
    print(currentLocale);
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            'Dart Intl Library',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Messages(),
            ),
          ),
          SizedBox(height: 20),
          LocalizationControl(
              locale: Locale(currentLocale),
              onLocaleChanged: (l) async {
                final locale = l.languageCode;
                if (availableLanguages.contains(locale)) {
                  setState(() => this.currentLocale = locale);
                } else if (locale == 'fr') {
                  await addFrenchTranslationFromNetwork();
                } else if (locale == 'gr') {
                  await addGermanTranslationFromAssets();
                }
              }),
        ],
      ),
    );
  }
}
