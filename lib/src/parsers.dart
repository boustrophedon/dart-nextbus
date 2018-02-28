import 'dart:math';

import 'package:xml/xml.dart' as xml;
import 'nextbus.dart';
import 'parse_utils.dart';

List<Agency> parse_agencies(String responseXml) {
  var document = xml.parse(responseXml);
  var agencies = document.rootElement.findElements('agency').map((node) {
    var tag = attr_to_string("tag", node);
    var title = attr_to_string("title", node);
    var shortTitle = attr_to_string("shortTitle", node);
    var regionTitle = attr_to_string("regionTitle", node);

    return new Agency(tag, title, shortTitle, regionTitle);
  }).toList();
  return agencies;
}

RouteList parse_route_list(String responseXml) {
  var document = xml.parse(responseXml);
  var routes = document.rootElement.findElements('route').map((node) {
    var tag = attr_to_string("tag", node);
    var title = attr_to_string("title", node);
    var shortTitle = attr_to_string("shortTitle", node);

    return new RouteDescription(tag, title, shortTitle);
  }).toList();

  return new RouteList(routes);
}

List<Route> parse_routes(String responseXml) {
  var document = xml.parse(responseXml);
  var routes =
      document.rootElement.findElements('route').map(_parse_route).toList();
  return routes;
}

List<Predictions> parse_predictions(String responseXml) {
  var document = xml.parse(responseXml);
  var predictions = document.rootElement
      .findElements('predictions')
      .map(_parse_predictions)
      .toList();
  return predictions;
}

Route _parse_route(xml.XmlElement node) {
  var tag = attr_to_string("tag", node);
  var title = attr_to_string("title", node);
  var shortTitle = attr_to_string("shortTitle", node);
  var colorCode = attr_to_string("colorCode", node);
  var oppositeColorCode = attr_to_string("oppositeColorCode", node);

  var latMin = attr_to_num("latMin", node);
  var latMax = attr_to_num("latMax", node);
  var lonMin = attr_to_num("lonMin", node);
  var lonMax = attr_to_num("lonMax", node);

  // not findAllElements, because that would give the ones inside the
  // direction tags as well
  var stops = node.findElements('stop').map(_parse_stop).toList();

  var paths = node.findElements('path').map((pathNode) {
    var path = new List<Point<num>>();
    for (var pointNode in pathNode.findElements("point")) {
      num lat = attr_to_num("lat", pointNode);
      num lon = attr_to_num("lon", pointNode);
      path.add(new Point(lon, lat));
    }
    return path;
  }).toList();

  return new Route(tag, title, shortTitle, colorCode, oppositeColorCode, stops,
      paths, latMin, latMax, lonMin, lonMax);
}

Stop _parse_stop(xml.XmlElement stopNode) {
  var tag = attr_to_string("tag", stopNode);
  var title = attr_to_string("title", stopNode);
  var shortTitle = attr_to_string("shortTitle", stopNode);

  var lat = attr_to_num("lat", stopNode);
  var lon = attr_to_num("lon", stopNode);

  var stopId = attr_to_int("stopId", stopNode);

  return new Stop(tag, title, shortTitle, lat, lon, stopId);
}

Predictions _parse_predictions(xml.XmlElement predsNode) {
  String agencyTitle = attr_to_string("agencyTitle", predsNode);
  String routeTag = attr_to_string("routeTag", predsNode);
  String routeTitle = attr_to_string("routeTitle", predsNode);
  String stopTag = attr_to_string("stopTag", predsNode);
  String stopTitle = attr_to_string("stopTitle", predsNode);
  String dirTitleBecauseNoPredictions =
      attr_to_string("dirTitleBecauseNoPredictions", predsNode);
  List<Prediction> predictions = predsNode
      .findElements("direction")
      .map((dir) {
        var dirTitle = attr_to_string("title", dir);
        return dir
            .findElements("prediction")
            .map((pred) => _parse_prediction(pred, dirTitle));
      })
      .expand((p) => p)
      .toList();

  List<String> messages =
      predsNode.findElements("message").map((msgNode) => msgNode.text).toList();

  return new Predictions(agencyTitle, routeTag, routeTitle, stopTag, stopTitle,
      dirTitleBecauseNoPredictions, predictions, messages);
}

Prediction _parse_prediction(xml.XmlElement predNode, String dirTitle) {
  int seconds = attr_to_int("seconds", predNode);
  int minutes = attr_to_int("minutes", predNode);
  int secondsSinceEpoch = attr_to_int("epochTime", predNode);
  bool isDeparture = attr_to_bool("", predNode);
  int blockId = attr_to_int("blockId", predNode);
  bool affectedByLayover = attr_to_bool("affectedByLayover", predNode);
  String dirTag = attr_to_string("dirTag", predNode);
  String vehicle = attr_to_string("vehicle", predNode);

  return new Prediction(seconds, minutes, secondsSinceEpoch, isDeparture,
      blockId, affectedByLayover, dirTag, dirTitle, vehicle);
}
