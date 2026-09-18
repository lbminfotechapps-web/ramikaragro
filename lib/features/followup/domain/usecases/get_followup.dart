import '../entities/followup_entity.dart';
import '../repositories/followup_repository.dart';

class GetUpcomingFollowup {
  final FollowupRepository repository;

  GetUpcomingFollowup(
    this.repository,
  );

  Future<List<FollowupEntity>> call({
    required String fromDate,
    required String toDate,
    required String type,
    required String userId,
  }) async {
    return await repository.getUpcomingFollowup(
      fromDate: fromDate,
      toDate: toDate,
      type: type,
      userId: userId,
    );
  }
}