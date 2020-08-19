import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pozoss/main.dart';

import 'package:toast/toast.dart';

import 'package:pozoss/utils/sharedP.dart';
import 'package:pozoss/api/api_WP.dart';

class FirstLogPage extends StatefulWidget {
  static final String routeName = 'settings';

  @override
  _FirstLogPageState createState() => _FirstLogPageState();
}

class _FirstLogPageState extends State<FirstLogPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final prefs = new SharedP();
  final WPAPI wordPress = new WPAPI();

  bool _isValidating = false;
  TextEditingController _nameController, _telfController;
  var _log;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController(text: prefs.nameUser);
    _telfController = new TextEditingController(text: prefs.telfUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('INGRESO'),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Credenciales',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                )),
            Divider(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: 'Nombre',
                          helperText: 'Unicamente el nombre'),
                      onChanged: (value) {
                        prefs.nameUser = value;
                      },
                    ),
                    TextField(
                      controller: _telfController,
                      decoration: InputDecoration(labelText: 'Teléfono'),
                      onChanged: (value) {
                        prefs.telfUser = value;
                      },
                    ),
                    Divider(),
                    RaisedButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 2.0),
                      color: Theme.of(context).buttonColor,
                      onPressed: _isValidating ? () {} : _ingresar,
                      // onPressed: () => Navigator.pushNamed(context, 'registro'),
                      child: _isValidating
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text("INGRESAR"),
                    ),
                  ],
                )),
          ],
        ));
  }

  Future<void> _ingresar() async {
    setState(() {
      _isValidating = true;
    });
    _log = await wordPress.login();
    if (_log.statusCode == 200) {
      await _firebaseMessaging.requestNotificationPermissions();
      final token = await _firebaseMessaging.getToken();
      print('============token==============');
      print(token);
      setState(() {
        _isValidating = false;
      });
      prefs.log = true;
      initPlatformState();
      Navigator.pushNamed(context, 'home');
    } else {
      Toast.show("Credenciales inválidas. Revise Usuario y/o teléfono", context,
          duration: 4, gravity: Toast.CENTER, backgroundColor: Colors.red[400]);
      setState(() {
        _isValidating = false;
      });
    }
  }
}
