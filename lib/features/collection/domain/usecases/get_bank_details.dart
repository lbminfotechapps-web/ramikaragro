import '../../data/models/bank_model.dart';
import '../repositories/collection_repository.dart';

class GetBankDetails {
  final CollectionRepository repository;

  GetBankDetails({
    required this.repository,
  });

  Future<List<BankModel>> call({
    required String dealerId,
    required String userId,
  }) {
    return repository.getBankDetails(
      dealerId: dealerId,
      userId: userId,
    );
  }
}