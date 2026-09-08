abstract class NotificationEvent {
  const NotificationEvent();
}

class GetNotificationListEvent
    extends NotificationEvent {
  final int userId;
  final bool isLogin;
  final String userType;

  const GetNotificationListEvent({
    required this.userId,
    required this.isLogin,
    required this.userType,
  });
}

class LoadMoreNotificationsEvent
    extends NotificationEvent {
  const LoadMoreNotificationsEvent();
}

class RefreshNotificationListEvent
    extends NotificationEvent {
  final int userId;
  final bool isLogin;
  final String userType;

  const RefreshNotificationListEvent({
    required this.userId,
    required this.isLogin,
    required this.userType,
  });
}