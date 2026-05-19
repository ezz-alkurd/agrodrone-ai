import '../../domain/entities/drone_status_entity.dart';

class DroneStatusModel extends DroneStatusEntity {
  const DroneStatusModel({
    required super.connectionStatus,
    required super.batteryPercent,
    required super.signalPercent,
    required super.altitudeMeters,
    required super.speedKmh,
    required super.latitude,
    required super.longitude,
    required super.weatherCondition,
    required super.temperatureCelsius,
    required super.fieldCoveragePercent,
  });

  factory DroneStatusModel.fromJson(Map<String, dynamic> json) => DroneStatusModel(
        connectionStatus: DroneConnectionStatus.values.byName(
            json['connectionStatus'] as String? ?? 'online'),
        batteryPercent: json['batteryPercent'] as int? ?? 0,
        signalPercent: json['signalPercent'] as int? ?? 0,
        altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble() ?? 0,
        speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        weatherCondition: json['weatherCondition'] as String? ?? 'Clear',
        temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 0,
        fieldCoveragePercent: json['fieldCoveragePercent'] as int? ?? 0,
      );

  // Mock data — replace with real API payload
  static const DroneStatusModel mock = DroneStatusModel(
    connectionStatus: DroneConnectionStatus.online,
    batteryPercent: 78,
    signalPercent: 92,
    altitudeMeters: 45.0,
    speedKmh: 18.5,
    latitude: 33.3152,
    longitude: 44.3661,
    weatherCondition: 'Partly Cloudy',
    temperatureCelsius: 28.4,
    fieldCoveragePercent: 62,
  );
}
