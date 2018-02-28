import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'parsers.dart';

/// See http://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf for more detail.
/// The default constructors simply create an object with the parameters. The
/// `request*` static methods perform an async network request to create the
/// object and return a `Future`.
/// TODO: a lot of the member variables are the same (tag, title, shortTitle), a
/// lot of the request code is the same, etc.  They could probably be cleaned up
/// using inheritance (like some sort of NextBusObject parent class, and then
/// just have a request_uri method that gets overridden) but for now this is
/// fine.


// I thought about making command an enum, but it doesn't actually get me
// anything. I suppose it would prevent typos but this isn't a public api so it
// doesn't matter as much.
// If we had rust enums (i.e. sum types) it would be nice.

/// The values in `queryParameters` must be either a `String` or an
/// `Iterable<String>`.
Uri _nextbus_command(String command, [Map<String, dynamic> commandParameters]) {
	var parameters = {'command': command};
	if (commandParameters != null) {
		parameters.addAll(commandParameters);
	}
	return new Uri(scheme: "http",
				   host: "webservices.nextbus.com",
		   		   path: "/service/publicXMLFeed",
				   queryParameters: parameters);
}

/// An agency is essentially a specific bus service.
class Agency {
	final String tag;
	final String title;
	/// May be null
	final String shortTitle;
	final String regionTitle;

	Agency(this.tag, this.title, this.shortTitle, this.regionTitle);

	static Future<List<Agency>> request_agencies() async {
		var uri = _nextbus_command('agencyList');

		return http.get(uri).then((r) => parse_agencies(r.body));
	}

	@override
	int get hashCode => tag.hashCode;
}

/// A list of the currently active routes of an agency. Only use this class if
/// you want the names of the routes and not the actual route data.
class RouteList {
	List<RouteDescription> routes;

	RouteList(this.routes);

	static Future<RouteList> request_route_list(String agency) async {
		var uri = _nextbus_command('routeList', {'a': agency});

		return http.get(uri).then((r) => parse_route_list(r.body));
	}
}

/// The description of a route, i.e. the name and tag. Generally you don't want
/// to use this and should use the `Route` class instead.
class RouteDescription {
	final String tag;
	final String title;
	final String shortTitle;

	RouteDescription(this.tag, this.title, this.shortTitle);

	@override
	int get hashCode => tag.hashCode;
}

class Route {
	/// These could be an embedded `RouteInfo` but 
	final String tag;
	final String title;
	final String shortTitle;
	final String colorCode;
	/// "Color that most contrasts with route color." Either white or black. 
	final String oppositeColorCode;

	/// List of stops given by combining all stops from all "directions" in the route.
	final List<Stop> stops;
	/// May be null if route paths were not requested. The x coordinate is
	/// longitude and the y coordinate is latitude, which doesn't match how
	/// coordinates in lat/lon are usually presented, but the other option is
	/// to have the `point.x` be the vertical component, which is equally
	/// undesirable. 
	final List<List<Point<num>>> paths;

	/// Represents the min/max bounds of the stops of the route as
	/// latitude/longitude coordinates. Note that the corners of the rectangle
	/// may not be actual points on any of the routes. Also note that the
	/// points in `paths` may go beyond these extents.
	final Rectangle<num> extents;

	Route(this.tag, this.title, this.shortTitle, this.colorCode,
			this.oppositeColorCode, this.stops, this.paths, num latMin, num
			latMax, num lonMin, num lonMax) :
		this.extents = new Rectangle.fromPoints(new Point(lonMax, latMax),
											   new Point(lonMin, latMin));

	/// Request the route data for a specific route.
	///
	/// Generally you don't want to use this unless you are really starved for
	/// data, or you know the agency has a lot of bus routes. In most cases it
	/// will save time and data to request all routes with `request_routes`.
	static Future<Route> request_route(String agencyTag, String routeTag, [bool wantPaths = false]) {
		var params = {'a': agencyTag, 'r': routeTag};
		if (!wantPaths) {
			// It doesn't actually matter what the parameter is, the nextbus
			// api just checks that the parameter is there or not.
			params['terse'] = null;
		}
		var uri = _nextbus_command('routeConfig', params);
		return http.get(uri).then((r) => parse_routes(r.body).first);
	}

	/// Request the route data for all routes operated by the agency with tag
	/// `agencyTag`.
	static Future<List<Route>> request_routes(String agencyTag, [bool wantPaths = false]) {
		var params = {'a': agencyTag};
		if (!wantPaths) {
			// It doesn't actually matter what the parameter is, the nextbus
			// api just checks that the parameter is there or not.
			params['terse'] = null;
		}
		var uri = _nextbus_command('routeConfig', params);
		return http.get(uri).then((r) => parse_routes(r.body));
	}

	@override
	int get hashCode => tag.hashCode;
}

class Stop {
	final String tag;
	final String title;
	final String shortTitle;
	final num latitude;
	final num longitude;
	/// May be null if it does not have a stop id.
	final int stopId;

	Stop(this.tag, this.title, this.shortTitle, this.latitude, this.longitude,
			this.stopId);

	@override
	int get hashCode => tag.hashCode;
}

class Predictions {
	final String agencyTitle;
	final String routeTag;
	final String routeTitle;
	final String stopTag;
	final String stopTitle;
	/// Not null if no predictions.
	final String dirTitleBecauseNoPredictions;
	final List<Prediction> predictions;
	final List<String> messages;

	Predictions(this.agencyTitle, this.routeTag, this.routeTitle, this.stopTag,
			this.stopTitle, this.dirTitleBecauseNoPredictions,
			this.predictions, this.messages);

	/// Returns predictions for all buses stopping at every stop on `Route route`. 
	static Future<List<Predictions>> request_route_predictions(String agency, Route route) {
		Map<String, dynamic> params = {'a': agency};
		var stopsStrings = route.stops
			.map((stop) => route.tag+"|"+stop.tag)
			.toList();
		params['stops'] = stopsStrings;
		var uri = _nextbus_command('predictionsForMultiStops', params);
		return http.get(uri).then((r) => parse_predictions(r.body));
	}

	/// Returns predictions for all buses on the route with the given
	/// `routeTag` stopping at the stop with the given `stopTag`.
	static Future<Predictions> request_stop_predictions(String agency, String routeTag, String stopTag) {
		var params = {'a': agency, 'r': routeTag, 's': stopTag};
		var uri = _nextbus_command('predictions', params);
		return http.get(uri).then((r) => parse_predictions(r.body).first);
	}
	
	/// Returns predictions for all buses stopping at the stop with the given `stopId`.
	static Future<List<Predictions>> request_stop_predictions_all(String agency, int stopId) {
		var params = {'a': agency, 'stopId':stopId};
		var uri = _nextbus_command('predictions', params);
		return http.get(uri).then((r) => parse_predictions(r.body));

	}

}

/// The predictions returned by the API differ a lot between agencies and
/// sometimes contain agency-specific attributes. Additionally, there are
/// attributes that appear in the predictions but are not documented.
class Prediction {
	final int seconds;
	final int minutes;
	final DateTime datetime;
	final bool isDeparture;
	/// It is unclear what this is. The documentation says "Specifies the block
	/// number assigned to the vehicle as defined in the configuration data."
	/// But it is not clear which configuration data it is referring to.
	final int blockId;
	final bool affectedByLayover;
	final String dirTag;
	final String dirTitle;
	/// Not documented, but appears for Rutgers buses at least.
	final String vehicle;

	Prediction(this.seconds, this.minutes, int secondsSinceEpoch,
			this.isDeparture, this.blockId, this.affectedByLayover,
			this.dirTag, this.dirTitle, this.vehicle) :
		this.datetime = new DateTime.fromMillisecondsSinceEpoch(1000*secondsSinceEpoch, isUtc: true);
}
