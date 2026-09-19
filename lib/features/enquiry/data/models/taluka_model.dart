import '../../domain/entities/taluka_entity.dart';

class TalukaModel extends TalukaEntity {
  const TalukaModel({
    required super.talukaId,
    required super.name,
  });

  factory TalukaModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const TalukaModel(
        talukaId: '',
        name: '',
      );
    }

    final id = _readValue(
      json,
      [
        'talukaId',
        'taluka_id',
        'id',
        'fld_id',
        'fld_taluka_id',
        'value',
      ],
    );

    final name = _readValue(
      json,
      [
        'name',
        'taluka_name',
        'talukaName',
        'fld_name',
        'fld_taluka_name',
        'label',
        'text',
      ],
    );

    return TalukaModel(
      talukaId: id,
      name: name,
    );
  }

  static String _readValue(
    Map json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        final value = json[key].toString().trim();

        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return '';
  }
}