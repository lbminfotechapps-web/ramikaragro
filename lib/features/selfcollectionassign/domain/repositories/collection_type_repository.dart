import '../entities/collection_type_entity.dart';

abstract class CollectionTypeRepository {
  Future<CollectionTypeResponseEntity> getCollectionType();
}
