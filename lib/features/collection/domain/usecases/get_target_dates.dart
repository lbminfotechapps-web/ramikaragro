import '../entities/target_date_entity.dart';
import '../repositories/dealer_target_repository.dart';

class GetTargetDates {
  final DealerTargetRepository repository;

  GetTargetDates({
    required this.repository,
  });

  Future<List<TargetDateEntity>> call() {
    return repository.getTargetDates();
  }
}