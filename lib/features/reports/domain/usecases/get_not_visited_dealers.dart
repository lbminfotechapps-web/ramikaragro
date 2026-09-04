import '../entities/not_visited_dealer.dart';
import '../repositories/dealer_repository.dart';
class GetNotVisitedDealers {
  final DealerRepository repository;

  GetNotVisitedDealers(this.repository);

  Future<List<NotVisitedDealer>> call({
    required int days,
    required int startLimit,
  }) {
    return repository.getNotVisitedDealers(
      days: days,
      startLimit: startLimit,
    );
  }
}