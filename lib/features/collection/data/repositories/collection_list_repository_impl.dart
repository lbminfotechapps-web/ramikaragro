import '../../domain/entities/collection_list.dart';
import '../../domain/repositories/collection_list_repository.dart';
import '../datasources/collection_list_remote_data_source.dart';

class CollectionListRepositoryImpl
    implements CollectionListRepository {
  final CollectionListRemoteDataSource
      remoteDataSource;

  CollectionListRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<List<CollectionList>>
      getCollectionList({
    required String userId,
    required String strMonth,
    required String strStatus,
    required int startLimit,
    required int pageSize,
  }) {
    return remoteDataSource
        .getCollectionList(
      userId: userId,
      strMonth: strMonth,
      strStatus: strStatus,
      startLimit: startLimit,
      pageSize: pageSize,
    );
  }
}