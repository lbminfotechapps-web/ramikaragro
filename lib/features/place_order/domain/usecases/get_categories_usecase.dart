import '../entities/category_entity.dart';
import '../repositories/place_order_repository.dart';

class GetCategoriesUseCase {
  final PlaceOrderRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}