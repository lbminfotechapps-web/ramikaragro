import 'package:demo/features/salesreturnhistory/domain/repositries/sales_return_history_repository.dart';

import '../entities/dealer_name_entity.dart';

class SearchSalesReturnDealerUseCase {
  final SalesReturnHistoryRepository repository;

  SearchSalesReturnDealerUseCase({required this.repository});

  Future<List<DealerNameEntity>> call({
    required String userId,
    required String searchText,
  }) {
    return repository.searchDealer(userId: userId, searchText: searchText);
  }
}
