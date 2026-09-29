import '../entities/collection_target_entity.dart';
import '../repositories/dealer_target_repository.dart';

class GetCollectionWiseTarget {
  final DealerTargetRepository repository;

  GetCollectionWiseTarget({
    required this.repository,
  });

  Future<CollectionTargetEntity?> call({
    required String userId,
    required String targetId,
    required String outletId,
    required String collectionTypeId,
  }) {
    return repository.getCollectionWiseTarget(
      userId: userId,
      targetId: targetId,
      outletId: outletId,
      collectionTypeId: collectionTypeId,
    );
  }
}