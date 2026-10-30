import '../../domain/entities/dealer_activity.dart';
import '../../domain/repositories/dealer_activity_repository.dart';
import '../datasources/dealer_activity_remote_data_source.dart';

class DealerActivityRepositoryImpl
    implements DealerActivityRepository {
  final DealerActivityRemoteDataSource dataSource;

  const DealerActivityRepositoryImpl(
    this.dataSource,
  );

  @override
  Future<String> submitActivity(
    DealerActivity activity,
  ) {
    return dataSource.submitActivity(activity);
  }
}