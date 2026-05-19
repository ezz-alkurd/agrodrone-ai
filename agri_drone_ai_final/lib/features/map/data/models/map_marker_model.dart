import '../../domain/entities/map_marker_entity.dart';

class MapMarkerModel extends MapMarkerEntity {
  const MapMarkerModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.label,
    required super.detectedAt,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) => MapMarkerModel(
        id: json['id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        type: MarkerType.values.byName(json['type'] as String),
        label: json['label'] as String,
        detectedAt: DateTime.parse(json['detectedAt'] as String),
      );

  static List<MapMarkerModel> get mockMarkers => [
        MapMarkerModel(
          id: 'm001',
          latitude: 33.3162,
          longitude: 44.3671,
          type: MarkerType.fire,
          label: 'Fire — Zone A',
          detectedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        MapMarkerModel(
          id: 'm002',
          latitude: 33.3140,
          longitude: 44.3690,
          type: MarkerType.disease,
          label: 'Fungal Disease — Zone B',
          detectedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
        MapMarkerModel(
          id: 'm003',
          latitude: 33.3180,
          longitude: 44.3640,
          type: MarkerType.waypoint,
          label: 'Waypoint — Zone C',
          detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

  static DronePathEntity get mockPath => DronePathEntity(
        currentPosition: const LatLng(33.3152, 44.3661),
        pathPoints: const [
          LatLng(33.3100, 44.3600),
          LatLng(33.3115, 44.3620),
          LatLng(33.3130, 44.3645),
          LatLng(33.3140, 44.3690),
          LatLng(33.3152, 44.3661),
          LatLng(33.3162, 44.3671),
          LatLng(33.3152, 44.3661),
        ],
      );
}
