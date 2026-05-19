import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.locationLabel,
    required super.timestamp,
    super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.byName(json['type'] as String),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        locationLabel: json['locationLabel'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  // Seed data for the mock service
  static List<NotificationModel> get seedList => [
        NotificationModel(
          id: 'n001',
          title: 'Fire Detected',
          body: 'Thermal anomaly detected in Zone A — immediate attention required.',
          type: NotificationType.fire,
          latitude: 33.3162,
          longitude: 44.3671,
          locationLabel: 'Zone A — Block 3',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        NotificationModel(
          id: 'n002',
          title: 'Plant Disease Detected',
          body: 'Possible fungal infection detected on wheat crop in Zone B.',
          type: NotificationType.disease,
          latitude: 33.3140,
          longitude: 44.3690,
          locationLabel: 'Zone B — Wheat Field',
          timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
        NotificationModel(
          id: 'n003',
          title: 'Low Battery Warning',
          body: 'Drone battery at 22 %. Returning to base.',
          type: NotificationType.warning,
          latitude: 33.3152,
          longitude: 44.3661,
          locationLabel: 'En-route to base',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        ),
        NotificationModel(
          id: 'n004',
          title: 'Scan Complete',
          body: 'Zone C scan completed. No anomalies found.',
          type: NotificationType.info,
          latitude: 33.3180,
          longitude: 44.3640,
          locationLabel: 'Zone C — Date Palms',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
      ];
}
