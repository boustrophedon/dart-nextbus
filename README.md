# nextbus

A dart library for getting bus data from the Nextbus API.

## Usage

A simple usage example:

    import 'package:nextbus/nextbus.dart';

    main() {
      var scott_h_bus = await Predictions.request_stop_predictions("rutgers", "h", "scott");
	  var minutes = scott_h_bus.predictions.first.minutes;
	  print("next h arriving at scott hall in ${minutes} minutes");
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/boustrophedon/nextbus-dart/issues
