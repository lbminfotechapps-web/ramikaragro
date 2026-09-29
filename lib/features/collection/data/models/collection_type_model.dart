import '../../domain/entities/collection_type_entity.dart';

class CollectionTypeResponseModel
    extends CollectionTypeResponseEntity {
  const CollectionTypeResponseModel({
    required super.status,
    required super.result,
    required super.message,
  });

  factory CollectionTypeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CollectionTypeResponseModel(
      status: json['status'] == true,
      result: (json['result'] as List<dynamic>? ?? [])
          .map(
            (item) => CollectionTypeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result
          .map(
            (item) => {
              'fld_collection_type':
                  item.collectionType,
              'fld_collection_type_id':
                  item.collectionTypeId,
            },
          )
          .toList(),
      'message': message,
    };
  }
}

class CollectionTypeModel
    extends CollectionTypeEntity {
  const CollectionTypeModel({
    required super.collectionType,
    required super.collectionTypeId,
  });

  factory CollectionTypeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CollectionTypeModel(
      collectionType:
          json['fld_collection_type']?.toString() ?? '',
      collectionTypeId:
          json['fld_collection_type_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_collection_type': collectionType,
      'fld_collection_type_id':
          collectionTypeId,
    };
  }
}