import '../../domain/entities/state_entity.dart';

class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    required super.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['fld_state_id']?.toString() ?? '',
      name: json['fld_name']?.toString() ?? '',
    );
  }
}