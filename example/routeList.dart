import 'package:nextbus/nextbus.dart';

void printRoutes(RouteList routes) {
  for (RouteDescription r in routes.routes) {
    print("${r.title}");
  }
}

/*
main() {
	var routes = RouteList.request_route_list('rutgers')
		.then(printRoutes)
		.catchError((e) => print(e.toString()));

}
*/

// Alternative with await/async
main() async {
  try {
    var routes = await RouteList.request_route_list('rutgers');
    printRoutes(routes);
  } catch (e) {
    print(e.toString());
  }
}
