import '../entities/dealer_entity.dart';
import '../repositories/place_order_repository.dart';

class GetDealersUseCase {
  final PlaceOrderRepository repository;

  GetDealersUseCase(this.repository);

  Future<List<DealerEntity>> call({
    required int userId,
    required String searchText,
  }) {
    return repository.getDealers(
      userId: userId,
      searchText: searchText,
    );
  }
}