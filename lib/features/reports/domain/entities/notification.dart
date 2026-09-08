class NotificationEntity {
  final String notificationId;
  final String title;
  final String message;
  final String notificationDate;
  final String notificationTime;

  const NotificationEntity({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.notificationDate,
    required this.notificationTime,
  });
}