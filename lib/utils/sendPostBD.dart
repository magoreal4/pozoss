import 'package:pozoss/db/db.dart';

import '../api/api_WP.dart';
import '../db/db.dart';
import 'package:sembast/sembast.dart';

final StoreRef<String, Map> _store = StoreRef('REPORTES');
final Database _db = DB.instance.database;

var _log;
WPAPI wordPress = new WPAPI();
String loginURL = 'http://www.pozos.xyz/wp-json/jwt-auth/v1/token';
String postURL = 'http://www.pozos.xyz/wp-json/wp/v2/registros';

void sendPostBD() async {
  List<RecordSnapshot<String, Map>> registros = await _store.find(_db);
  print(registros.length);

  if (registros.length > 0) {
    _log = await wordPress.login();
    if (_log.statusCode == 200) {
      registros.map((RecordSnapshot<String, Map> e) async {
        try {
          await wordPress.post(data: e.value, token: _log.data['token']);
          await _store.record(e.key).delete(_db);
          print("key: ${e.key}");
        } catch (e) {
          print(e);
        }
      }).toList();
    }
  }
}
