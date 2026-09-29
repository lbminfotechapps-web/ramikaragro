import '../../domain/entities/collection_type_entity.dart';

class CollectionTypeResponseModel extends CollectionTypeResponseEntity {
  const CollectionTypeResponseModel({
    required super.status,
    required super.collectionTypes,
    required super.message,
  });

  factory CollectionTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return CollectionTypeResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      collectionTypes: (json['result'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                CollectionTypeModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CollectionTypeModel extends CollectionTypeEntity {
  const CollectionTypeModel({
    required super.collectionType,
    required super.collectionTypeId,
  });

  factory CollectionTypeModel.fromJson(Map<String, dynamic> json) {
    return CollectionTypeModel(
      collectionType: json['fld_collection_type']?.toString() ?? '',
      collectionTypeId: json['fld_collection_type_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_collection_type': collectionType,
      'fld_collection_type_id': collectionTypeId,
    };
  }
}
