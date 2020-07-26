import 'package:xml/xml_events.dart';


String getAttribute(
  List<XmlEventAttribute> attributes,
  String name, {
  String def = '',
  String namespace,
}) {

  for (final attribute in attributes) {
    if (attribute.name == name) {
      return attribute.value;
    }
  }
  return def;
}