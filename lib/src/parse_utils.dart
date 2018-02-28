import 'package:xml/xml.dart' as xml;

String attr_to_string(String attribute, xml.XmlElement node) {
  var attr = node.getAttribute(attribute);
  if (attr == null) {
    attr = "";
  }

  return attr;
}

int attr_to_int(String attribute, xml.XmlElement node) {
  var attr_ = node.getAttribute(attribute);
  var attr = null;
  if (attr_ != null) {
    attr = int.parse(attr_);
  }

  return attr;
}

num attr_to_num(String attribute, xml.XmlElement node) {
  var attr_ = node.getAttribute(attribute);
  var attr = null;
  if (attr_ != null) {
    attr = num.parse(attr_);
  }

  return attr;
}

bool attr_to_bool(String attribute, xml.XmlElement node) {
  var attr_ = attr_to_string(attribute, node);

  return (attr_ == "true" || attr_ == "1");
}
