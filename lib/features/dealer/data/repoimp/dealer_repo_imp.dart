
import 'package:demo/features/dealer/data/datasource/dealer_datasource.dart';
import 'package:demo/features/dealer/data/models/DealerListModel.dart';
import 'package:demo/features/dealer/domain/repository/dealer_repo.dart';

class DealerListRepositoryImpl implements DealerListRepository {
  final DealerListDataSource dealerListDatasource;

  DealerListRepositoryImpl(this.dealerListDatasource);

  @override
  Future<List<DealerListModel>> getDealers(
    String userId,
    String lattitude,
    String logitude,
    String searchKey,
    String type
  ) async {
    try {
      print('');
      print('========================================');
      print('DEALER REPOSITORY START');
      print('========================================');

      print('userId: $userId');
      print('latitude: $lattitude');
      print('longitude: $logitude');
      print('searchKey: $searchKey');
      print('type: $type');

      final response = await dealerListDatasource.fetchDealerList(
        userId,
        lattitude,
        logitude,
        searchKey,
        type,
      );

      print('');
      print('========================================');
      print('DEALER REPOSITORY RESPONSE');
      print('========================================');

      print('Dealer count: ${response.length}');
      print('Dealers: $response');

      for (final dealer in response) {
        print(
          'Dealer ID: ${dealer.outletId} | '
          'Name: ${dealer.outletName}',
        );
      }

      return response;
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('DEALER REPOSITORY ERROR');
      print('========================================');

      print('ERROR: $e');
      print('STACK: $stackTrace');

      throw Exception('Failed to fetch dealer list: $e');
    }
  }
}