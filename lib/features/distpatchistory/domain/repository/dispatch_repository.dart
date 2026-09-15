import 'package:demo/features/distpatchistory/domain/entities/dispatch_list_entity.dart';

abstract class DispatchRepository {
  Future<List<DispatchListEntity>> getDispatchList({
    required int userId,
    required String searchText,
    required String status,
    required String fromDate,
    required String toDate,
    required int startLimit,
  });
}
