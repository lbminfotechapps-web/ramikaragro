import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.notificationId,
    required super.title,
    required super.message,
    required super.notificationDate,
    required super.notificationTime,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      notificationId:
          json['fld_notification_id']?.toString() ?? '',

      title:
          json['fld_title']?.toString() ?? '',

      message:
          json['fld_message']?.toString() ?? '',

      notificationDate:
          json['notificationDate']?.toString() ?? '',

      notificationTime:
          json['notificationTime']?.toString() ?? '',
    );
  }
}