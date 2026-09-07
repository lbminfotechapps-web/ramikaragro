
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notification_list.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationList getNotificationList;

  static const int pageSize = 20;

  int startLimit = 0;

  bool _isRequestRunning = false;

  int _userId = 0;
  bool _isLogin = false;
  String _userType = '';

  NotificationBloc(
    this.getNotificationList,
  ) : super(
          const NotificationInitial(),
        ) {
    on<GetNotificationListEvent>(
      _onGetNotificationList,
    );

    on<LoadMoreNotificationsEvent>(
      _onLoadMoreNotifications,
    );

    on<RefreshNotificationListEvent>(
      _onRefreshNotificationList,
    );
  }

  Future<void> _onGetNotificationList(
    GetNotificationListEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (_isRequestRunning) {
      return;
    }

    _userId = event.userId;
    _isLogin = event.isLogin;
    _userType = event.userType;

    _isRequestRunning = true;
    startLimit = 0;

    emit(
      const NotificationLoading(),
    );

    try {
      debugPrint(
        '========== NOTIFICATION FIRST LOAD ==========',
      );

      final List<NotificationEntity>
          notifications =
          await getNotificationList(
        userId: _userId,
        isLogin: _isLogin,
        userType: _userType,
        startLimit: startLimit,
      );

      final bool hasMore =
          notifications.length >= pageSize;

      startLimit += notifications.length;

      debugPrint(
        'Received: ${notifications.length}',
      );

      debugPrint(
        'Next startLimit: $startLimit',
      );

      emit(
        NotificationLoaded(
          notifications: notifications,
          hasMore: hasMore,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== NOTIFICATION ERROR ==========',
      );

      debugPrint(
        'ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      emit(
        NotificationError(
          message: e.toString(),
        ),
      );
    } finally {
      _isRequestRunning = false;
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (_isRequestRunning) {
      return;
    }

    final currentState = state;

    if (currentState
        is! NotificationLoaded) {
      return;
    }

    if (!currentState.hasMore) {
      return;
    }

    _isRequestRunning = true;

    emit(
      currentState.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      debugPrint(
        '========== NOTIFICATION PAGINATION ==========',
      );

      debugPrint(
        'Current startLimit: $startLimit',
      );

      final List<NotificationEntity>
          newNotifications =
          await getNotificationList(
        userId: _userId,
        isLogin: _isLogin,
        userType: _userType,
        startLimit: startLimit,
      );

      final List<NotificationEntity>
          updatedNotifications = [
        ...currentState.notifications,
        ...newNotifications,
      ];

      final bool hasMore =
          newNotifications.length >= pageSize;

      startLimit += newNotifications.length;

      debugPrint(
        'New notifications: '
        '${newNotifications.length}',
      );

      debugPrint(
        'Total notifications: '
        '${updatedNotifications.length}',
      );

      debugPrint(
        'Next startLimit: $startLimit',
      );

      emit(
        NotificationLoaded(
          notifications:
              updatedNotifications,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== PAGINATION ERROR ==========',
      );

      debugPrint(
        'ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      emit(
        currentState.copyWith(
          isLoadingMore: false,
        ),
      );
    } finally {
      _isRequestRunning = false;
    }
  }

  Future<void> _onRefreshNotificationList(
    RefreshNotificationListEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (_isRequestRunning) {
      return;
    }

    _userId = event.userId;
    _isLogin = event.isLogin;
    _userType = event.userType;

    _isRequestRunning = true;
    startLimit = 0;

    try {
      debugPrint(
        '========== NOTIFICATION REFRESH ==========',
      );

      final List<NotificationEntity>
          notifications =
          await getNotificationList(
        userId: _userId,
        isLogin: _isLogin,
        userType: _userType,
        startLimit: 0,
      );

      startLimit += notifications.length;

      emit(
        NotificationLoaded(
          notifications: notifications,
          hasMore:
              notifications.length >= pageSize,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'REFRESH ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      emit(
        NotificationError(
          message: e.toString(),
        ),
      );
    } finally {
      _isRequestRunning = false;
    }
  }
}

