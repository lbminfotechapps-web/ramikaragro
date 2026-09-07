
import 'package:get_it/get_it.dart';

import 'package:demo/features/reports/data/datasources/notification_remote_data_source.dart';
import 'package:demo/features/reports/data/repositories/notification_repository_impl.dart';

import 'package:demo/features/reports/domain/repositories/notification_repository.dart';
import 'package:demo/features/reports/domain/usecases/get_notification_list.dart';

import 'package:demo/features/reports/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> initNotificationDi() async {
  // =========================================================
  // NOTIFICATION
  // =========================================================

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      sl<NotificationRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetNotificationList>(
    () => GetNotificationList(
      sl<NotificationRepository>(),
    ),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      sl<GetNotificationList>(),
    ),
  );
}

