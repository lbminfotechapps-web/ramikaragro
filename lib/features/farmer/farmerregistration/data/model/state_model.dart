import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';

class StateModel extends StateEntity {
  StateModel({required super.stateId, required super.stateName});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['fld_state_id']?.toString() ?? '',
      stateName: json['fld_name']?.toString() ?? '',
    );
  }
}
