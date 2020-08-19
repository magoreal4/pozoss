import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificaton {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _mensajesStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajesStream => _mensajesStreamController.stream;

  static Future<dynamic> backgroundMessage(Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      // final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  initNotifications() async {
    // await _firebaseMessaging.requestNotificationPermissions();
    // final token = await _firebaseMessaging.getToken();
    // print('============ FCM token ===========');
    // print(token);

    _firebaseMessaging.configure(
        onMessage: onMessage,
        onBackgroundMessage: backgroundMessage,
        onLaunch: onLaunch,
        onResume: onResume);
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print('============ onMesagge ===========');
    print('Mensage: $message');
    // final argumento = message['data']['comida'] ?? 'no-data';
    // print(argumento);
    // _mensajesStreamController.sink.add(argumento);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print('============ onLaunch ===========');
    // final argumento = message['data']['comida'] ?? 'no-data';
    // _mensajesStreamController.sink.add(argumento);
    print('Mensage: $message');
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    print('============ onResume ===========');
    print('Mensage: $message');
    // final argumento = message['data']['comida'] ?? 'no-data';
    // _mensajesStreamController.sink.add(argumento);
  }

  dispose() {
    _mensajesStreamController?.close();
  }
}
