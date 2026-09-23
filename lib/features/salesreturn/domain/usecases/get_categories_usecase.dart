import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';

import '../entities/category_entity.dart';

class GetCategoriesUseCase {
  final SalesReturnRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}