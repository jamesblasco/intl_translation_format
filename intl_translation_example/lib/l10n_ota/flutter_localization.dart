import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_translation_json/intl_translation_json.dart';
import 'package:intl_translation_ota_flutter/intl_translation_ota_flutter.dart';

import 'common.dart';
import 'dart_intl.dart';

class LocalizationFlutter extends StatefulWidget {
  @override
  _LocalizationFlutterState createState() => _LocalizationFlutterState();
}

class _LocalizationFlutterState extends State<LocalizationFlutter> {
  Locale locale = Locale('en');
  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: locale,
      delegates: [
        AppStrings.delegate(
          {
            'fr': NetworkFile(
              translationJsonFileUrl,
              'intl_messages_fr.json',
            ),
            'es': AssetFile('assets/arb/intl_messages_es.json'),
            'en': AssetFile('assets/arb/intl_messages_en.json'),
          },
          JsonFormat(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Flutter Localizations',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(AppStrings.of(context).string('text')),
                        SizedBox(height: 12),
                        Text(
                          AppStrings.of(context).string('textWithMetadata'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                LocalizationControl(
                  locale: locale,
                  onLocaleChanged: (locale) => setState(
                    () => this.locale = locale,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
