import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';

import '../entities/target_date_entity.dart';

abstract class SalesTargetRepository {
  Future<List<SalesTargetDateEntity>> getTargetDates();

  Future<SalesTargetEntity?> getSalesWiseTarget({
    required String userId,
    required String targetId,
  });


  Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
    required String userId,
    required String targetId,
  });
}