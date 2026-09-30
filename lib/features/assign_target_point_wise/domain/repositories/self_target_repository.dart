import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';

import '../entities/target_group_entity.dart';

abstract class SelfTargetRepository {
  Future<List<TargetGroupEntity>> getSelfTarget();

  Future<String> submitSelfTarget({
    required String userId,
    required String month,
    // required String groupId,
    required String points,
  });

  // Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
  //   required String userId,
  //   required String targetId,
  // });
}
