import '../entities/dealer_response_entity.dart';
import '../repositories/dealer_repository.dart';

class GetDealerList {
  final DealerRepository repository;

  GetDealerList(this.repository);

  Future<DealerResponseEntity> call({required int userId}) async {
    return await repository.getDealerList(userId: userId);
  }
}
