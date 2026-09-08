import '../entities/top_ten_dealer.dart';

abstract class TopTenDealerRepository {
  Future<List<TopTenDealer>> getTopTenDealerVisit({
    required String userId,
    required int days,
  });
}