import 'package:solufine/features/farmer/farmerlist/data/datasource/farmerlist_datasource.dart';
import 'package:solufine/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:solufine/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';

class FarmerListRepositoryImpl implements FarmerListRepository {
  final FarmerListDataSource farmerListDatasource;

  FarmerListRepositoryImpl(this.farmerListDatasource);

  @override
  Future<List<FarmerlistModel>> getFarmers(
    int userId,

    int limit,
    String searchKey,
  ) async {
    try {
      final response = await farmerListDatasource.fetchFarmerList(
        userId,

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
