import 'package:solufine/features/distpatchistory/data/datasource/dispatch_remote_datasource.dart';
import 'package:solufine/features/distpatchistory/domain/entities/dispatch_list_entity.dart';
import 'package:solufine/features/distpatchistory/domain/repository/dispatch_repository.dart';

class DispatchRepositoryImpl implements DispatchRepository {
  final DispatchRemoteDataSource remoteDataSource;

  DispatchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DispatchListEntity>> getDispatchList({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    return await remoteDataSource.getDispatchList(
      userId: userId,
      searchText: searchText,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      startLimit: startLimit,
    );
  }
}
