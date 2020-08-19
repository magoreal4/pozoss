import 'package:connectivity/connectivity.dart';
import '../db/db.dart';
import '../utils/sendPostBD.dart';
import 'package:sembast/sembast.dart';

checkStatus() {
  var store = StoreRef.main();
  final Database _db = DB.instance.database;
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      print("esta conectado");
      await store.record('CONNECT').put(_db, true);
      sendPostBD();
    } else {
      print("esta desconectado");
      await store.record('CONNECT').put(_db, false);
    }
  });
}
