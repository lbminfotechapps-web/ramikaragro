import 'package:solufine/features/scheme/domain/entity/scheme_entity.dart';
import 'package:solufine/features/scheme/domain/repository/schemerepository.dart';

class GetSchemeUseCase {
  final SchemeRepository repository;

  GetSchemeUseCase({required this.repository});

  Future<List<SchemeEntity>> call({
    required String year,
    required String month,
    required String stateId,
  }) {
    return repository.getScheme(year: year, month: month, stateId: stateId);
  }
}
