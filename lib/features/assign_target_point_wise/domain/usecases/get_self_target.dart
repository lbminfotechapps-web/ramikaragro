import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';

import '../entities/target_group_entity.dart';

import '../repositories/self_target_repository.dart';

class GetSelfTarget {
  final SelfTargetRepository repository;

  GetSelfTarget({required this.repository});

  Future<List<TargetGroupEntity>> call() {
    return repository.getSelfTarget();
  }

  Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
    required String userId,
    required String targetId,
  }) {
    return repository.getGroupWiseAchivPoint(
      userId: userId,
      targetId: targetId,
    );
  }
}
