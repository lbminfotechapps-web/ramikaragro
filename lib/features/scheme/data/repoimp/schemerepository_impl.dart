import 'package:demo/features/scheme/data/datatsource/scheme_datasource.dart';
import 'package:demo/features/scheme/domain/entity/scheme_entity.dart';
import 'package:demo/features/scheme/domain/repository/schemerepository.dart';

class SchemeRepositoryImpl implements SchemeRepository {
  final SchemeRemoteDataSource remoteDataSource;

  SchemeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SchemeEntity>> getScheme({
    required String year,
    required String month,
    required String stateId,
  }) async {
    return await remoteDataSource.getScheme(
      year: year,
      month: month,
      stateId: stateId,
    );
  }
}
