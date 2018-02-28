import 'package:nextbus/nextbus.dart';

main() async {
  var scott_h_bus =
      await Predictions.request_stop_predictions("rutgers", "h", "scott");
  var minutes = scott_h_bus.predictions.first.minutes;
  print("next h arriving at scott hall in ${minutes} minutes");
}
