import '../../domain/entities/godown_entity.dart';

class GodownModel extends GodownEntity {
  const GodownModel({
    required super.id,
    required super.name,
  });

  factory GodownModel.fromJson(Map<String, dynamic> json) {
    return GodownModel(
      id: _getValue(
        json,
        [
          'godown_id',
          'godownId',
          'id',
          'fld_godown_id',
        ],
      ),
      name: _getValue(
        json,
        [
          'godown_name',
          'godownName',
          'name',
          'fld_godown_name',
        ],
      ),
    );
  }

  static String _getValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (json[key] != null) {
        return json[key].toString();
      }
    }

    return '';
  }
}