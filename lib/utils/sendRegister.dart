import '../api/api_WP.dart';
import '../db/db.dart';
import '../db/wpreportes.dart';
// import '../utils/sendPostBD.dart';
import 'package:sembast/sembast.dart';

final WPAPI wordPress = new WPAPI();
var _log, _post;
var store = StoreRef.main();
final Database _db = DB.instance.database;

Future<void> sendRegister(reporte) async {
  bool connect = await store.record('CONNECT').get(_db);
  print("4. Conexión a internet: $connect");
  if (connect) {
    // Log con WordPress
    _log = await wordPress.login();

    // Si el Log es exitoso se postea y regresa a home
    if (_log.statusCode == 200) {
      _post = await wordPress.post(data: reporte, token: _log.data['token']);

      if (_post.statusCode == 201) {
        print("Reporte Enviado online");
      } else {
        print("Error ${_post.statusCode}: Comunique el error por favor");
      }
      // Si falla el Log va a Settings
    } else {
      print("Credenciales inválidas. Revise Usuario y teléfono");
      await ReportesStore.instance.save(reporte);
    }
  } else {
    await ReportesStore.instance.save(reporte);
  }
}
