import '../../domain/entities/state_entity.dart';

class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    required super.name,
  });

  factory StateModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const StateModel(
        id: '',
        name: '',
      );
    }

    final id = _readValue(
      json,
      [
        'id',
        'state_id',
        'stateId',
        'fld_id',
        'fld_state_id',
        'value',
      ],
    );

    final name = _readValue(
      json,
      [
        'name',
        'state_name',
        'stateName',
        'fld_name',
        'fld_state_name',
        'label',
        'text',
      ],
    );

    return StateModel(
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