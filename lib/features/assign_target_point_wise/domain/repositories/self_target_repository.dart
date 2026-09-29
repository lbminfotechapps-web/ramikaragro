import '../entities/target_group_entity.dart';

abstract class SelfTargetRepository {
  Future<List<TargetGroupEntity>> getSelfTarget();

  Future<String> submitSelfTarget({
    required String userId,
    required String month,
   // required String groupId,
    required String points,
  });
}