import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<List<NotificationEntity>> getNotificationList({
    required int userId,
    required bool isLogin,
    required String userType,
    required int startLimit,
  }) {
    return remoteDataSource.getNotificationList(
      userId: userId,
      isLogin: isLogin,
      userType: userType,
      startLimit: startLimit,
    );
  }
}