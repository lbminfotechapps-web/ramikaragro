import '../entities/target_date_entity.dart';
import '../entities/collection_target_entity.dart';

abstract class DealerTargetRepository {
  Future<List<TargetDateEntity>> getTargetDates({required String userId});

  Future<CollectionTargetEntity?> getCollectionWiseTarget({
    required String userId,
    required String targetId,
    required String outletId,
    required String collectionTypeId,
  });
}