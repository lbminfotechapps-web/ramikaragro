

import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/repositories/sales_target_repository.dart';


class GeSalesWiseTarget {
  final SalesTargetRepository repository;

  GeSalesWiseTarget({
    required this.repository,
  });

  Future<SalesTargetEntity?> call({
    required String userId,
    required String targetId,
  }) {
    return repository.getSalesWiseTarget(
      userId: userId,
      targetId: targetId,
    );
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