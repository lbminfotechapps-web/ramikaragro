import 'package:demo/features/distpatchistory/domain/repository/dispatch_repository.dart';

import '../entities/dispatch_list_entity.dart';

class GetDispatchListUseCase {
  final DispatchRepository repository;

  GetDispatchListUseCase(this.repository);

  Future<List<DispatchListEntity>> call({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    return await repository.getDispatchList(
      userId: userId,
      searchText: searchText,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
    );
  }
}
