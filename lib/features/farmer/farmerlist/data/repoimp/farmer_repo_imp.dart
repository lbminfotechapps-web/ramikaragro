import 'package:demo/features/farmer/farmerlist/data/datasource/farmerlist_datasource.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';

class FarmerListRepositoryImpl implements FarmerListRepository {
  final FarmerListDataSource farmerListDatasource;

  FarmerListRepositoryImpl(this.farmerListDatasource);

  @override
  Future<List<FarmerlistModel>> getFarmers(
    int userId,String lattitude, String logitude,int limit,String searchKey,
  ) async {
    try {
      print('');
      print('========================================');
      print('REPOSITORY START');
      print('========================================');

      print('userId: $userId');
      print('latitude: $lattitude');
      print('longitude: $logitude');
      print('limit: $limit');
      print('searchKey: $searchKey');

      final response = await farmerListDatasource.fetchFarmerList(
        userId,
        lattitude,
        logitude,
        limit,
        searchKey,
      );

      print('');
      print('========================================');
      print('REPOSITORY RESPONSE');
      print('========================================');

      print('Farmer count: ${response.length}');
      print('Farmers: $response');

      for (final farmer in response) {
        print(
          'Farmer ID: ${farmer.farmerId} | '
          'Name: ${farmer.farmerName}',
        );
      }

      return response;
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('REPOSITORY ERROR');
      print('========================================');

      print('ERROR: $e');
      print('STACK: $stackTrace');

      throw Exception('Failed to fetch farmer list: $e');
    }
  }
}
