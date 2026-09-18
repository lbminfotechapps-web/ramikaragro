import '../entities/state_entity.dart';
import '../repositories/enquiry_repository.dart';

class GetStatesUseCase {
  final EnquiryRepository repository;

  GetStatesUseCase(this.repository);

  Future<List<StateEntity>> call({
    required String userId,
  }) {
    return repository.getStates(
      userId: userId,
    );
  }
}