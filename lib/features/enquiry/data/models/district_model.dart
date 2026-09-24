import '../../domain/entities/district_entity.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.name,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: _getString(json, [
        'fld_id',
        'id',
        'district_id',
        'districtId',
        'dist_id',
        'distId',
        'fld_district_id',
        'fld_dist_id',
      ]),
      name: _getString(json, [
        'fld_name',
        'name',
        'district_name',
        'districtName',
        'dist_name',
        'distName',
        'fld_district_name',
        'fld_dist_name',
      ]),
    );
  }

  static String _getString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }
}