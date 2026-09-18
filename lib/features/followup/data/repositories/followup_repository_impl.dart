import '../../domain/entities/followup_entity.dart';
import '../../domain/repositories/followup_repository.dart';
import '../datasources/followup_remote_data_source.dart';

class FollowupRepositoryImpl
    implements FollowupRepository {
  final FollowupRemoteDataSource remoteDataSource;

  FollowupRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<FollowupEntity>> getUpcomingFollowup({
    required String fromDate,
    required String toDate,
    required String type,
    required String userId,
  }) async {
    return await remoteDataSource.getUpcomingFollowup(
      fromDate: fromDate,
      toDate: toDate,
      type: type,
      userId: userId,
    );
  }
}