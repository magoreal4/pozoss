// To parse this JSON data, do
//
//     final modelPosition = modelPositionFromJson(jsonString);

import 'dart:convert';

ModelPosition modelPositionFromJson(String str) =>
    ModelPosition.fromJson(json.decode(str));

String modelPositionToJson(ModelPosition data) => json.encode(data.toJson());

class ModelPosition {
  ModelPosition({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.time,
    this.isMocked,
  });

  double latitude;
  double longitude;
  int accuracy;
  int altitude;
  double speed;
  int speedAccuracy;
  double heading;
  int time;
  bool isMocked;

  factory ModelPosition.fromJson(Map<String, dynamic> json) => ModelPosition(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        accuracy: json["accuracy"],
        altitude: json["altitude"],
        speed: json["speed"].toDouble(),
        speedAccuracy: json["speed_accuracy"],
        heading: json["heading"].toDouble(),
        time: json["time"],
        isMocked: json["is_mocked"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "altitude": altitude,
        "speed": speed,
        "speed_accuracy": speedAccuracy,
        "heading": heading,
        "time": time,
        "is_mocked": isMocked,
      };
}
