import 'package:solufine/features/sales_targrt_achievement/domain/repositories/sales_target_repository.dart';

import '../entities/target_date_entity.dart';

class GetTargetDates {
  final SalesTargetRepository repository;

  GetTargetDates({
    required this.repository,
  });

  Future<List<SalesTargetDateEntity>> call() {
    return repository.getTargetDates();
  }
}