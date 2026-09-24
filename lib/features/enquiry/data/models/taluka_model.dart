import '../../domain/entities/taluka_entity.dart';

class TalukaModel extends TalukaEntity {
  const TalukaModel({
    required super.talukaId,
    required super.name,
  });

  factory TalukaModel.fromJson(Map<String, dynamic> json) {
    return TalukaModel(
      talukaId: _getString(json, [
        'talukaId',
        'taluka_id',
        'talukaid',
        'fld_taluka_id',
        'fld_talukaid',
        'id',
        'fld_id',
      ]),
      name: _getString(json, [
        'name',
        'taluka_name',
        'talukaName',
        'fld_taluka_name',
        'fld_talukaname',
        'fld_name',
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