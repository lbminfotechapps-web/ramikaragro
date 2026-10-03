// import '../entities/collection_list.dart';
// import '../repositories/collection_list_repository.dart';

// class GetCollectionList {
//   final CollectionListRepository repository;

//   GetCollectionList(
//     this.repository,
//   );

//   Future<List<CollectionList>> call({
//     required String userId,
//     required String strMonth,
//     required String strStatus,
//     required int startLimit,
//     required int pageSize,
//   }) {
//     return repository.getCollectionList(
//       userId: userId,
//       strMonth: strMonth,
//       strStatus: strStatus,
//       startLimit: startLimit,
//       pageSize: pageSize,
//     );
//   }
// }


import '../entities/collection_list.dart';
import '../repositories/collection_list_repository.dart';

// ============================================================================
// GET COLLECTION LIST USE CASE
// ============================================================================

class GetCollectionList {
  final CollectionListRepository
      repository;

  GetCollectionList(
    this.repository,
  );

  Future<List<CollectionList>> call({
    required String userId,
    required String strMonth,
    required String strStatus,
    required String dealerId,
    required int startLimit,
    required int pageSize,
  }) {
    return repository
        .getCollectionList(
      userId:
          userId,

      strMonth:
          strMonth,

      strStatus:
          strStatus,

      dealerId:
          dealerId,

      startLimit:
          startLimit,

      pageSize:
          pageSize,
    );
  }
}