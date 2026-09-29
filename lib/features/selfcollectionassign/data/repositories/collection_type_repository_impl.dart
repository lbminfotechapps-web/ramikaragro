import 'package:solufine/features/selfcollectionassign/domain/repositories/collection_type_repository.dart';

import '../../domain/entities/collection_type_entity.dart';
import '../datasource/collection_type_remote_datasource.dart';

class CollectionTypeRepositoryImpl implements CollectionTypeRepository {
  final CollectionTypeRemoteDataSource remoteDataSource;

  CollectionTypeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CollectionTypeResponseEntity> getCollectionType() async {
    try {
      return await remoteDataSource.getCollectionType();
    } catch (e) {
      rethrow;
    }
  }
}
