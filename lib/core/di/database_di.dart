import 'package:get_it/get_it.dart';
import 'package:solufine/core/location_tracking/app_database.dart';
import 'package:solufine/features/ai/presentation/database/ai_chat_database_operations.dart';

final getIt = GetIt.instance;

void databaseDi() {
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  }

  if (!getIt.isRegistered<AiChatDatabaseOperations>()) {
    getIt.registerLazySingleton<AiChatDatabaseOperations>(
      () => AiChatDatabaseOperations(getIt<AppDatabase>()),
    );
  }
}
