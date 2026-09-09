
import '../entities/not_visited_dealer.dart';

abstract class NotVisitedDealerRepository {
  Future<List<NotVisitedDealer>> getNotVisitedDealers({
    required int days,
    required int startLimit,
  });
}

