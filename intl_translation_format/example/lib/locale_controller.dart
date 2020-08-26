import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/intl_messages_all.dart';

class LocaleController extends ValueNotifier<String> {
  List<String> _availableLocales;

  LocaleController(String initialLocale, {List<String> availableLocales})
      : _availableLocales = availableLocales ?? [initialLocale],
        super(initialLocale);
}

class DefaultLocale extends InheritedNotifier<LocaleController> {
  const DefaultLocale({
    Key key,
    LocaleController localeController,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child, notifier: localeController);

  static LocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DefaultLocale>().notifier;
}

class DefaultLocaleController extends StatefulWidget {
  final String initialLocale;
  final List<String> availableLocales;
  final Widget child;

  const DefaultLocaleController(
      {Key key,
      this.initialLocale,
      @required this.child,
      this.availableLocales})
      : super(key: key);
  @override
  _DefaultLocaleState createState() => _DefaultLocaleState();
}

class _DefaultLocaleState extends State<DefaultLocaleController> {
  LocaleController controller;

  @override
  void initState() {
    controller = LocaleController(widget.initialLocale,
        availableLocales: widget.availableLocales);

    controller.addListener(updateIntlLocale);
    updateIntlLocale();
    super.initState();
  }

  void updateIntlLocale() {
    initializeMessages(controller.value);
    Intl.defaultLocale = controller.value;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLocale(
      child: widget.child,
      localeController: controller,
    );
  }

  @override
  void dispose() {
    controller.removeListener(updateIntlLocale);
    controller.dispose();
    super.dispose();
  }
}

class LocaleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = DefaultLocale.of(context);
    return CupertinoSlidingSegmentedControl<String>(
      groupValue: controller.value,
      children: Map.fromEntries(
        controller._availableLocales.map(
          (locale) => MapEntry(
            locale,
            Text(locale),
          ),
        ),
      ),
      onValueChanged: (newLocale) {
        controller.value = newLocale;
      },
    );
  }
}
