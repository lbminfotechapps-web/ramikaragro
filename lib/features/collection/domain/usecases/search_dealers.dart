import '../../data/models/dealer_model.dart';
import '../repositories/collection_repository.dart';

class SearchDealers {
  final CollectionRepository repository;

  SearchDealers({
    required this.repository,
  });

  Future<List<DealerModel>> call({
    required String userId,
    required String searchText,
  }) {
    return repository.searchDealers(
      userId: userId,
      searchText: searchText,
    );
  }
}