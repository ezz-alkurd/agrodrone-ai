import 'dart:async';
import '../models/notification_model.dart';

abstract class NotificationDataSource {
  Future<List<NotificationModel>> getNotifications();
  Stream<NotificationModel> get liveStream;
}

/// Mock service — emits a new random notification every 30 s.
/// Replace [liveStream] with Firebase Messaging stream when backend is ready.
class NotificationDataSourceImpl implements NotificationDataSource {
  static final StreamController<NotificationModel> _controller =
      StreamController<NotificationModel>.broadcast();

  static Timer? _timer;

  NotificationDataSourceImpl() {
    _startMockStream();
  }

  void _startMockStream() {
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      final templates = [
        NotificationModel(
          id: 'live_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Fire Detected',
          body: 'New thermal anomaly in Zone D.',
          type: NotificationModel.seedList[0].type,
          latitude: 33.3170 + (DateTime.now().millisecond / 100000),
          longitude: 44.3680,
          locationLabel: 'Zone D — Live',
          timestamp: DateTime.now(),
        ),
        NotificationModel(
          id: 'live_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Plant Disease Alert',
          body: 'Rust disease suspected on barley field.',
          type: NotificationModel.seedList[1].type,
          latitude: 33.3145,
          longitude: 44.3700,
          locationLabel: 'Zone E — Barley',
          timestamp: DateTime.now(),
        ),
      ];
      final pick = templates[DateTime.now().second.isEven ? 0 : 1];
      if (!_controller.isClosed) _controller.add(pick);
    });
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return NotificationModel.seedList;
  }

  @override
  Stream<NotificationModel> get liveStream => _controller.stream;
}
