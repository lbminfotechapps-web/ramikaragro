import 'package:solufine/features/selfcollectionassign/domain/repositories/collection_type_repository.dart';

import '../entities/collection_type_entity.dart';

class GetCollectionType {
  final CollectionTypeRepository repository;

  GetCollectionType(this.repository);

  Future<CollectionTypeResponseEntity> call() async {
    return await repository.getCollectionType();
  }
}
