import 'package:nextbus/nextbus.dart';

void printRoute(Route route) {
  print("Route: ${route.title} \n");
  for (Stop stop in route.stops) {
    print(
        "${stop.title} is at ${stop.latitude}, ${stop.longitude}, stop id ${stop.stopId}");
  }

  num left = route.paths.first.first.x;
  for (var path in route.paths) {
    for (var point in path) {
      if (point.x < left) {
        left = point.x;
      }
    }
  }

  print("");
  print("Extents of path: ${route.extents}");
  print("Smallest latitude of paths: ${left}");
}

main() {
  var route = Route
      .request_route('rutgers', 'ee', true)
      .then(printRoute)
      .catchError(
          (e) => print("${e.runtimeType} ${e.toString()}\n${e.stackTrace}"));
}
