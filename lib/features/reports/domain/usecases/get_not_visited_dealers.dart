
import '../entities/not_visited_dealer.dart';
import '../repositories/not_visited_dealer_repository.dart';

class GetNotVisitedDealers {
  final NotVisitedDealerRepository repository;

  GetNotVisitedDealers({
    required this.repository,
  });

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

