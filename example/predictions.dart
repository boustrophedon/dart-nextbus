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
  try {
    var route = await Route.request_route('rutgers', 'h', wantPaths: true);

    var predictions = Predictions
        .request_route_predictions('rutgers', route)
        .then(printPredictions);
  } catch (e) {
    print("${e.runtimeType} ${e.toString()}");
  }
}
