import '../entities/godown_entity.dart';
import '../repositories/place_order_repository.dart';

class GetGodownsUseCase {
  final PlaceOrderRepository repository;

  GetGodownsUseCase(this.repository);

  Future<List<GodownEntity>> call({
    required int userId,
  }) {
    return repository.getGodowns(
      userId: userId,
    );
  }
}