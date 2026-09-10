import '../entities/target_date_entity.dart';
import '../entities/collection_target_entity.dart';

abstract class DealerTargetRepository {
  Future<List<TargetDateEntity>> getTargetDates();

  Future<CollectionTargetEntity?> getCollectionWiseTarget({
    required String userId,
    required String targetId,
  });
}