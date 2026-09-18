import '../entities/followup_entity.dart';

abstract class FollowupRepository {
  Future<List<FollowupEntity>> getUpcomingFollowup({
    required String fromDate,
    required String toDate,
    required String type,
    required String userId,
  });
}