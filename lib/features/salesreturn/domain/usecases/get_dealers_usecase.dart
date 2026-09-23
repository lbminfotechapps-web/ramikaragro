import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';

import '../entities/dealer_entity.dart';

class GetDealersUseCase {
  final SalesReturnRepository repository;

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