import 'package:pozoss/db/db.dart';
import 'package:sembast/sembast.dart';

class ReportesStore {
  ReportesStore._internal();
  static ReportesStore _instance = ReportesStore._internal();
  static ReportesStore get instance => _instance;
  final Database _db = DB.instance.database;
  Map _reporte;

  final StoreRef<String, Map> _store = StoreRef('REPORTES');

  save(Map reporte) async {
    this._reporte = reporte;
    await this._store.record(reporte['date']).put(this._db, this._reporte);
    print("Reporte guardado");
  }
}
