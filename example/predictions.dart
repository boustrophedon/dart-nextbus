import 'package:nextbus/nextbus.dart';

void printPredictions(List<Predictions> route_preds) {
	print("${route_preds.first.routeTitle} predictions");

	for (Predictions preds in route_preds) {
		if (preds.predictions.isNotEmpty) {
			print("${preds.stopTitle}");
			for (Prediction pred in preds.predictions) {
				print("  ${pred.dirTitle}");
				print("  in ${pred.minutes} minutes");
			}
			print("");
		}
	}
}

main() async {
	var route = await Route.request_route('rutgers', 'h', true)
		.catchError((e) => print("${e.runtimeType} ${e.toString()}\n${e.stackTrace}"));

	var predictions = Predictions.request_route_predictions('rutgers', route)
		.then(printPredictions)
		.catchError((e) => print("${e.runtimeType} ${e.toString()}\n${e.stackTrace}"));

}
