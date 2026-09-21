import '../../domain/entities/state_entity.dart';

class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    required super.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: _getString(json, [
        'fld_id',
        'id',
        'state_id',
        'stateId',
        'fld_state_id',
      ]),
      name: _getString(json, [
        'fld_name',
        'name',
        'state_name',
        'stateName',
        'fld_state_name',
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