import 'package:demo/features/scheme/domain/entity/scheme_entity.dart';

abstract class SchemeRepository {
  Future<List<SchemeEntity>> getScheme({
    required String year,
    required String month,
    required String stateId,
  });
}
