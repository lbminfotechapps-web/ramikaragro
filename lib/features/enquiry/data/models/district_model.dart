import '../../domain/entities/district_entity.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.name,
  });

  factory DistrictModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const DistrictModel(
        id: '',
        name: '',
      );
    }

    final id = _readValue(
      json,
      [
        'id',
        'district_id',
        'districtId',
        'fld_id',
        'fld_district_id',
        'value',
      ],
    );

    final name = _readValue(
      json,
      [
        'name',
        'district_name',
        'districtName',
        'fld_name',
        'fld_district_name',
        'label',
        'text',
      ],
    );

    return DistrictModel(
      id: id,
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