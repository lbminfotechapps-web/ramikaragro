import '../../domain/entities/collection_target_entity.dart';
import '../../domain/entities/target_date_entity.dart';
import '../../domain/repositories/dealer_target_repository.dart';
import '../datasources/dealer_target_remote_datasource.dart';

class DealerTargetRepositoryImpl
    implements DealerTargetRepository {
  final DealerTargetRemoteDataSource remoteDataSource;

  DealerTargetRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TargetDateEntity>> getTargetDates() {
    return remoteDataSource.getTargetDates();
  }

  @override
  Future<CollectionTargetEntity?>
      getCollectionWiseTarget({
    required String userId,
    required String targetId,
  }) {
    return remoteDataSource.getCollectionWiseTarget(
      userId: userId,
      targetId: targetId,
    );
  }
}