import 'dart:async';

import 'package:pozoss/api/api_WP.dart';
import 'package:pozoss/db/db.dart';
import 'package:pozoss/db/wpreportes.dart';
import 'package:pozoss/location/permissionService.dart';
import 'package:pozoss/utils/reporteModel.dart';
import 'package:pozoss/utils/sendPostBD.dart';

import '../utils/sharedP.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:location/location.dart';

import 'package:sembast/sembast.dart';
import 'package:toast/toast.dart';

const PADDING_8 = EdgeInsets.all(8.0);
// const URL_POSTS = '$URL_WP_BASE/registros';

class NuevoRegistroPage extends StatefulWidget {
  static final String routeName = 'registro';

  @override
  _NuevoRegistroPageState createState() => _NuevoRegistroPageState();
}

class _NuevoRegistroPageState extends State<NuevoRegistroPage> {
  final prefs = new SharedP();
  final formKey = GlobalKey<FormState>();
  final Database _db = DB.instance.database;
  final ReporteModel repForm = new ReporteModel();
  final Fields repFormFields = new Fields();
  final WPAPI wordPress = new WPAPI();
  double _valorSlider;
  var store = StoreRef.main();
  var _log, _post;
  Map<String, dynamic> reporte;
  bool _isValidating = false;
  // LocationData _location;

  @override
  void initState() {
    super.initState();
    _valorSlider = prefs.nivelCamion.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Nuevo Registro"),
        ),
        body: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              children: <Widget>[
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Container(
                        child: _overlapped(),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 240,
                        child: _crearSlider(),
                      ),
                    )
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: _flete(),
                    ),
                    Flexible(
                        flex: 3,
                        child: SizedBox(
                          width: 100.0,
                          child: _precio(),
                        )),
                  ],
                ),
                Center(
                  child: _boton(),
                )
              ],
            )));
  }

  Widget _overlapped() {
    final items = [
      Image.asset('assets/cam0.png', fit: BoxFit.contain, height: 260),
      Image.asset(
        'assets/cam${_valorSlider.toInt()}.png',
        fit: BoxFit.contain,
        height: 260,
      ),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
        child: items[index],
      );
    });

    return Stack(children: stackLayers);
  }

  Widget _crearSlider() {
    String _label() {
      switch (_valorSlider.toInt()) {
        case 0:
          {
            return 'vacio';
          }
        case 1:
          {
            return '1/4';
          }
        case 2:
          {
            return 'medio';
          }
        case 3:
          {
            return '3/4';
          }
        case 4:
          {
            return 'lleno';
          }
      }
      return 'vacio';
    }

    return RotatedBox(
        quarterTurns: 3,
        child: Slider(
            value: _valorSlider,
            min: 0.0,
            max: 4.0,
            divisions: 4,
            onChanged: (valor) {
              setState(() {
                _valorSlider = valor;
              });
            },
            label: _label(),
            onChangeEnd: (valor) {
              repFormFields.nivel = valor.round();
            }));
  }

  Widget _flete() {
    return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Flete'),
        activeColor: Theme.of(context).primaryColor,
        checkColor: Theme.of(context).canvasColor,
        value: repFormFields.flete ?? false,
        onChanged: (bool val) {
          setState(() {
            repFormFields.flete = val;
          });
        });
  }

  Widget _precio() {
    return TextFormField(
      initialValue: '',
      decoration: InputDecoration(labelText: 'Precio'),
      onSaved: (value) =>
          repForm.title == null ? repForm.title = value : repForm.title = '---',
      keyboardType: TextInputType.number,
    );
  }

  Widget _boton() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: _isValidating ? () {} : _submit,
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: Theme.of(context).buttonColor,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: _isValidating
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text('REGISTRAR'),
              ),
            ),
          ]),
    );
  }

  Future<void> _submit() async {
    LocationData _locationData;
    prefs.nivelCamion = repFormFields.nivel;

    setState(() {
      _isValidating = true;
    });
    // Verificar el estado de permisos y conexión
    await checkPermissions();
    print("1. Permisos Verificados");
    await checkService();
    print("2. Servicios Verificados");

    try {
      _locationData = await location.getLocation();
      print("3. Coordenadas");
      print("Latitud ${_locationData.latitude}");
      print("Longitud ${_locationData.longitude}");
    } catch (err) {
      print(err.code);
    }

    formKey.currentState.save();
    repForm.date = DateTime.now().toUtc().toString();

    reporte = {
      "title": repForm.title ?? "0",
      "date": repForm.date,
      "status": "publish",
      "fields": {
        "lat": _locationData.latitude,
        "lon": _locationData.longitude,
        "nivel": repFormFields.nivel ?? 0,
        "flete": repFormFields.flete ?? false,
      }
    };

    bool connect = await store.record('CONNECT').get(_db);
    print("4. Conexión a internet: $connect");
    if (connect) {
      // Log con WordPress
      _log = await wordPress.login();
      // Si el Log es exitoso se postea y regresa a home
      if (_log.statusCode == 200) {
        _post = await wordPress.post(data: reporte, token: _log.data['token']);
        setState(() {
          _isValidating = false;
        });
        if (_post.statusCode == 201) {
          Toast.show("Reporte Enviado", context,
              duration: 4,
              gravity: Toast.CENTER,
              backgroundColor: Colors.green);
          Timer(
              Duration(seconds: 2), () => Navigator.pushNamed(context, 'home'));
          sendPostBD();
        } else {
          // Si falla el post emite mensaje
          Toast.show("Error ${_post.statusCode}: Comunique el error por favor",
              context,
              duration: 5,
              gravity: Toast.CENTER,
              backgroundColor: Colors.red[400]);
        }
        // Si falla el Log va a Settings
      } else {
        Toast.show(
            "Credenciales inválidas. Revise Usuario y/o teléfono", context,
            duration: 4,
            gravity: Toast.CENTER,
            backgroundColor: Colors.red[400]);
        await ReportesStore.instance.save(reporte);
        setState(() {
          _isValidating = false;
        });
        Timer(Duration(seconds: 4),
            () => Navigator.pushNamed(context, 'ajustes'));
      }
      setState(() {
        _isValidating = false;
      });
    } else {
      setState(() {
        _isValidating = false;
      });
      Toast.show("Reporte Guardado", context,
          duration: 4, gravity: Toast.CENTER, backgroundColor: Colors.green);
      await ReportesStore.instance.save(reporte);
      Timer(Duration(seconds: 2), () => Navigator.pushNamed(context, 'home'));
    }
  }
}
