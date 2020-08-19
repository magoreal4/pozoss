import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pozoss/db/db.dart';
import 'package:pozoss/location/file_manager.dart';
import 'package:pozoss/location/location_callback_handler.dart';
import 'package:pozoss/pages/firstlog_page.dart';
import 'package:pozoss/pages/newreg_page.dart';
import 'package:pozoss/utils/conectivity.dart';
import 'package:pozoss/utils/sendRegister.dart';

import 'package:provider/provider.dart';

import 'package:pozoss/utils/sharedP.dart';
import 'package:pozoss/pages/settings_page.dart';
// import 'package:pozos/providers/push_notification.dart';
import 'pages/home_page.dart';
// import 'mensaje_page.dart';
import 'provider/push_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.instance.init();
  final prefs = new SharedP();
  await prefs.initPrefs();

  runApp(ChangeNotifierProvider(
    create: (context) => SharedP(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final GlobalKey<NavigatorState> navigatorKey =
  //     new GlobalKey<NavigatorState>();
  ReceivePort port = ReceivePort();
  Map<String, dynamic> reporte;
  StreamSubscription<ConnectivityResult> _status;

  final prefs = new SharedP();

  @override
  void initState() {
    super.initState();
    if (prefs.log) {
      initPlatformState();
    }
    final pushProvider = PushNotificaton();
    pushProvider.initNotifications();
    _status = checkStatus();
    if (IsolateNameServer.lookupPortByName(
            LocationCallbackHandler.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationCallbackHandler.isolateName);
    }
    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationCallbackHandler.isolateName);
    port.listen(
      (dynamic data) async {
        Map reporte = {
          "title": "traking",
          "date":
              DateTime.fromMicrosecondsSinceEpoch(data['time'].round() * 1000)
                  .toString(),
          "status": "publish",
          "fields": {
            "lat": data['latitude'],
            "lon": data['longitude'],
            "estadia": data['estadia']
          }
        };
        print(reporte);
        sendRegister(reporte);
      },
    );

    // pushProvider.mensajesStream.listen((data) {
    // print('argumento desde main: $data');
    // Navigator.pushNamed(context, 'mensaje');
    //   navigatorKey.currentState.pushNamed('mensaje', arguments: data);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    DB.instance.close();
    _status.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final modo = Provider.of<SharedP>(context);
    // navigatorKey: navigatorKey,
    return MaterialApp(
        title: 'Pozos',
        theme: modo.modoOscuro
            ? ThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.amber[300],
                accentColor: Colors.amber[100],
                buttonColor: Colors.amber[400],
                buttonTheme: ButtonTheme.of(context),
                sliderTheme: SliderThemeData.fromPrimaryColors(
                    primaryColor: Colors.amber[300],
                    primaryColorDark: Colors.black87,
                    primaryColorLight: Colors.black87,
                    valueIndicatorTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                iconTheme: IconThemeData(color: Colors.amber[300]))
            : ThemeData(
                canvasColor: Colors.amber[50],
                brightness: Brightness.light,
                primaryColor: Colors.amber[300],
                accentColor: Colors.amber[300],
                buttonColor: Colors.amber[400],
                buttonTheme: ButtonTheme.of(context),
                sliderTheme: SliderThemeData.fromPrimaryColors(
                    primaryColor: Colors.amber[300],
                    primaryColorDark: Colors.black87,
                    primaryColorLight: Colors.black87,
                    valueIndicatorTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                iconTheme: IconThemeData(color: Colors.amber[300])),
        initialRoute: prefs.log ? 'home' : 'firstlog',
        routes: {
          'home': (context) => HomePage(),
          'ajustes': (context) => SettingsPage(),
          'registro': (context) => NuevoRegistroPage(),
          'firstlog': (context) => FirstLogPage(),
        });
  }
}

Future<void> initPlatformState() async {
  Location _location = new Location();

  // isRunning = await BackgroundLocator.isServiceRunning();
  // if (!isRunning) {
  print('1. Initializing...');
  await BackgroundLocator.initialize();
  String logStr = await FileManager.readFile();
  if (logStr == '') {
    print('2. No hay información $logStr');
    LocationData locationData = await _location.getLocation();
    double _time = DateTime.now().toUtc().millisecondsSinceEpoch.toDouble();
    Map<String, dynamic> _timeInicial = {
      'latitude': locationData.latitude ?? -17.7607517,
      'longitude': locationData.longitude ?? -63.182725,
      'accuracy': 20.0,
      'speed': 0.0,
      'speed_accuracy': 0.0,
      'heading': 90.0,
      'time': _time
    };
    print(json.encode(_timeInicial));
    await FileManager.writeFile(json.encode(_timeInicial));
  } else {
    print('2. Hay algo en el archivo');
    print(logStr);
  }
  if (await LocationCallbackHandler.checkLocationPermission()) {
    print('3. Permission ok');
    LocationCallbackHandler.startLocator();
  } else {
    print('3. Permission fail');
  }
}
