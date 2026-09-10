import '../entities/collection_list.dart';

abstract class CollectionListRepository {
  Future<List<CollectionList>>
      getCollectionList({
    required String userId,
    required String strMonth,
    required String strStatus,
    required int startLimit,
    required int pageSize,
  });
}