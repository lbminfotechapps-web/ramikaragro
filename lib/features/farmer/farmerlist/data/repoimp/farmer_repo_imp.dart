import 'package:demo/features/farmer/farmerlist/data/datasource/farmerlist_datasource.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';

class FarmerListRepositoryImpl implements FarmerListRepository {
  final FarmerListDataSource farmerListDatasource;

  FarmerListRepositoryImpl(this.farmerListDatasource);

  @override
  Future<List<FarmerlistModel>> getFarmers(
    int userId,
    String lattitude,
    String logitude,
    int limit,
    String searchKey,
  ) async {
    try {
      final response = await farmerListDatasource.fetchFarmerList(
        userId,
        lattitude,
        logitude,
        limit,
        searchKey,
      );

      for (final farmer in response) {
        print(
          'Farmer ID: ${farmer.farmerId} | '
          'Name: ${farmer.farmerName}',
        );
      }

      return response;
    } catch (e, stackTrace) {
      throw Exception('Failed to fetch farmer list: $e');
    }
  }
}
