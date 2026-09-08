import '../entities/top_ten_dealer.dart';
import '../repositories/top_ten_dealer_repository.dart';

class GetTopTenDealer {
  final TopTenDealerRepository repository;

  GetTopTenDealer(this.repository);

  Future<List<TopTenDealer>> call({
    required String userId,
    required int days,
  }) {
    return repository.getTopTenDealerVisit(
      userId: userId,
      days: days,
    );
  }
}