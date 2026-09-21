import 'package:solufine/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';

import '../entities/target_date_entity.dart';

abstract class SalesTargetRepository {
  Future<List<SalesTargetDateEntity>> getTargetDates();

  Future<SalesTargetEntity?> getSalesWiseTarget({
    required String userId,
    required String targetId,
  });
}