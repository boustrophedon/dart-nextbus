import 'package:nextbus/nextbus.dart';

void printAgencies(List<Agency> agencies) {
  for (Agency a in agencies) {
    print("${a.title}");
  }
}

main() {
  var agencies = Agency
      .request_agencies()
      .then(printAgencies)
      .catchError((e) => print(e.toString()));
}
// Alternative with await/async
/*
main() async {
	try {
		var agencies = await Agency.request_agencies();
		printAgencies(agencies);
	}
	catch (e) {
		print(e.toString());
	}
}
*/
