
// import 'package:solufine/core/di/auth_di.dart';
// import 'package:solufine/core/location_tracking/app_database.dart';
// import 'package:solufine/core/location_tracking/location_repository.dart';
// import 'package:solufine/core/location_tracking/location_tracking_service.dart';



// Future<void> initLocationTrackingDi() async {
//   sl.registerLazySingleton<AppDatabase>(
//     () => AppDatabase(),
//   );

//   sl.registerLazySingleton<LocationRepository>(
//     () => LocationRepository(
//       sl<AppDatabase>(),
//     ),
//   );

//   sl.registerLazySingleton<LocationTrackingService>(
//     () => LocationTrackingService(
//       sl<LocationRepository>(),
//     ),
//   );
// }