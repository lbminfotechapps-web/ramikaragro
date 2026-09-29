import '../entities/dealer_response_entity.dart';

abstract class DealerRepository {
  Future<DealerResponseEntity> getDealerList({required int userId});
}
