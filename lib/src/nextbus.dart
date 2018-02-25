import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

const baseUrl = "http://webservices.nextbus.com/service/publicXMLFeed";

class Agency {}
class Route {}
class Stop {}
class StopTime {}

Future<List<Agency>> get_agencies() async {

}

Future<List<Route>> get_routes(Agency agency) async {
}

Future<List<Stop>> get_stops(Route route) async {
}

Future<StopTime> get_prediction(Route route, Stop stop) async {
}

Future<List<StopTime>> get_predictions(Route route, List<Stop> stops) async {
}
