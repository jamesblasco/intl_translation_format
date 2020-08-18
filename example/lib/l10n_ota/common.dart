import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const url =
    'https://firebasestorage.googleapis.com/v0/b/jaimeblascoandres.appspot.com/o/gsoc%2Fintl_messages_fr.json?alt=media&token=6debf01c-1049-4959-a3e3-c9bd4acd8a8f';

const proxy = 'https://cors-anywhere.herokuapp.com/';
const translationJsonFileUrl = kDebugMode? proxy + url: url;

class LocalizationControl extends StatelessWidget {
  final Locale locale;
  final void Function(Locale) onLocaleChanged;

  const LocalizationControl({Key key, this.locale, this.onLocaleChanged})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Locale: $locale',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Spacer(),
        CupertinoSlidingSegmentedControl(
          thumbColor: Colors.white,
          groupValue: locale,
          children: {
            Locale('en'): Text('en'),
            Locale('es'):
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.folder_open, size: 16),
              SizedBox(width: 10),
              Text('es'),
            ]),
            Locale('fr'):
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.cloud_download, size: 16),
              SizedBox(width: 10),
              Text('fr'),
            ]),
          },
          onValueChanged: onLocaleChanged,
        )
      ],
    );
  }
}
