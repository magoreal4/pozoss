import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'file_manager.dart';

import 'package:location_permissions/location_permissions.dart';
import 'package:background_locator/background_locator.dart';

bool isRunning;
String logStr = '';

class LocationCallbackHandler {
  static String isolateName = 'LocatorIsolate';
  // static Future<void> initCallback(Map<dynamic, dynamic> params) async {
  //   // LocationServiceRepository myLocationCallbackRepository =
  //   //     LocationServiceRepository();
  //   // await myLocationCallbackRepository.init(params);
  //   print("4. ***********Init callback handler");
  //   print('5. Initialization done');
  //   final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
  //   send?.send(null);
  // }

  // static Future<void> disposeCallback() async {
  //   // LocationServiceRepository myLocationCallbackRepository =
  //   //     LocationServiceRepository();
  //   // await myLocationCallbackRepository.dispose();
  // }

  static Future<void> callback(LocationDto locationDto) async {
    Map<String, dynamic> _time0 = json.decode(await FileManager.readFile());
    // print(_time0['time'].runtimeType);

    Map<String, dynamic> _time1 = locationDto.toJson();
    await FileManager.clearFile();
    await FileManager.writeFile(json.encode(_time1));
    // print(_time1['time'].runtimeType);

    final int difference = ((_time1['time'] - _time0['time']) / 1000).round();

    print('Segundos $difference');

    if (difference >= 20) {
      _time0.addAll({'estadia': '$difference'});
      final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
      send?.send(_time0);
    }
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }

  static void startLocator() async {
    // isRunning = await BackgroundLocator.isServiceRunning();

    // Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(
      callback,
      // initCallback: initCallback,
      // initDataCallback: data,
      // disposeCallback: disposeCallback,
      androidNotificationCallback: notificationCallback,
      settings: LocationSettings(
          notificationChannelName: "Location tracking service",
          notificationTitle: "Start Location Tracking",
          notificationMsg: "Track location in background",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 20,
          interval: 20),
    );
  }

  static Future<bool> checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }
}
