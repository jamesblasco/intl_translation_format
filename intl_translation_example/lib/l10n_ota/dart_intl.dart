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

Future loadAssetsTranslations() async {
  final catalog = TranslationCatalog('intl');
  await catalog.addTranslations(
    [
      AssetFile('assets/l10n/intl_messages_es.json'),
      AssetFile('assets/l10n/intl_messages_en.json'),
    ],
    format: JsonFormat(),
  );
  TranslationLoader(catalog).initializeMessages('es');
}

Future loadNetworkTranslations() async {
  final catalog = TranslationCatalog('intl');

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
}

class Localized extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text),
        Text(
          textWithMetadata,
        ),
        Text(
          pluralExample(0),
        ),
        Text(
          embedded(0),
        ),
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

  List<String> availableLanguages = ['en'];

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
      log('Local $local loaded: $couldLoad');
    }

    setState(() {
      currentLocale = availableLanguages.first;
    });
  }

  Future addAssetTranslation() async {
    try {
      log('asset');
      await loadAssetsTranslations();
      log('loaded');
      availableLanguages.add('es');
      setState(() {
        currentLocale = 'es';
      });
    } catch (e) {
      log(e);
    }
  }

  Future addNetworkTranslation() async {
    await loadNetworkTranslations();
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
              child: Localized(),
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
                  await addNetworkTranslation();
                } else if (locale == 'es') {
                  await addAssetTranslation();
                }
              }),
        ],
      ),
    );
  }
}
