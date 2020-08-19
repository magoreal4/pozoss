import 'package:location/location.dart';

final Location location = new Location();
PermissionStatus _permissionGranted;
bool _serviceEnabled;

Future<void> checkPermissions() async {
  final PermissionStatus permissionGrantedResult =
      await location.hasPermission();
  _permissionGranted = permissionGrantedResult;
  print(_permissionGranted);
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
}

Future<void> checkService() async {
  final bool serviceEnabledResult = await location.serviceEnabled();
  _serviceEnabled = serviceEnabledResult;
  print('Servicio localización: $_serviceEnabled');
  if (_serviceEnabled == null || !_serviceEnabled) {
    final bool serviceRequestedResult = await location.requestService();
    _serviceEnabled = serviceRequestedResult;
    if (!serviceRequestedResult) {
      return;
    }
  }
}
