import '../entities/submit_enquiry_entity.dart';
import '../repositories/enquiry_repository.dart';

class SubmitEnquiryUseCase {
  final EnquiryRepository repository;

  SubmitEnquiryUseCase(this.repository);

  Future<SubmitEnquiryEntity> call({
    required Map<String, String> params,
  }) {
    return repository.submitEnquiry(
      params: params,
    );
  }
}