import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _useCase;
  StreamSubscription<NotificationEntity>? _liveSub;
  final List<NotificationEntity> _all = [];

  NotificationsCubit(this._useCase) : super(const NotificationsInitial());

  Future<void> load() async {
    emit(const NotificationsLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(NotificationsError(f.message)),
      (list) {
        _all
          ..clear()
          ..addAll(list);
        _emitLoaded();
        _subscribeLive();
      },
    );
  }

  void _subscribeLive() {
    _liveSub?.cancel();
    _liveSub = _useCase.liveStream.listen((notification) {
      _all.insert(0, notification);
      _emitLoaded();
    });
  }

  void markAllRead() {
    for (var i = 0; i < _all.length; i++) {
      _all[i] = _all[i].copyWith(isRead: true);
    }
    _emitLoaded();
  }

  void _emitLoaded() {
    final unread = _all.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(notifications: List.unmodifiable(_all), unreadCount: unread));
  }

  @override
  Future<void> close() {
    _liveSub?.cancel();
    return super.close();
  }
}
