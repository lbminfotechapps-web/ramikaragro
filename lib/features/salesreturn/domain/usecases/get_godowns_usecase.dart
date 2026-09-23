import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';

import '../entities/godown_entity.dart';

class GetGodownsUseCase {
  final SalesReturnRepository repository;

  GetGodownsUseCase(this.repository);

  Future<List<GodownEntity>> call({
    required int userId,
  }) {
    return repository.getGodowns(
      userId: userId,
    );
  }
}