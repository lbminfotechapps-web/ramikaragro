import '../../domain/entities/notification.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial
    extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading
    extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded
    extends NotificationState {
  final List<NotificationEntity> notifications;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.notifications,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      notifications:
          notifications ?? this.notifications,
      hasMore:
          hasMore ?? this.hasMore,
      isLoadingMore:
          isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NotificationError
    extends NotificationState {
  final String message;

  const NotificationError({
    required this.message,
  });
}