
import '../../domain/entities/location_entities.dart';

// ==========================================
// STATE MODEL
// ==========================================

class StateModel {
  final String id;
  final String name;

  const StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StateModel(
      id: '${json['fld_state_id'] ?? ''}',
      name: '${json['fld_name'] ?? ''}',
    );
  }

  StateEntity toEntity() {
    return StateEntity(
      id: id,
      name: name,
    );
  }
}

// ==========================================
// TALUKA MODEL
// ==========================================

class TalukaModel {
  final String id;
  final String districtId;
  final String name;

  const TalukaModel({
    required this.id,
    required this.districtId,
    required this.name,
  });

  factory TalukaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TalukaModel(
      id: '${json['fld_taluka_id'] ?? ''}',
      districtId: '${json['fld_disc_id'] ?? ''}',
      name: '${json['fld_name'] ?? ''}',
    );
  }

  TalukaEntity toEntity() {
    return TalukaEntity(
      id: id,
      districtId: districtId,
      name: name,
    );
  }
}

// ==========================================
// DISTRICT MODEL
// ==========================================

class DistrictModel {
  final String id;
  final String name;
  final List<TalukaModel> talukas;

  const DistrictModel({
    required this.id,
    required this.name,
    required this.talukas,
  });

  factory DistrictModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTalukas = json['taluka'];

    return DistrictModel(
      id: '${json['fld_dist_id'] ?? ''}',
      name: '${json['fld_dist_name'] ?? ''}',
      talukas: rawTalukas is List
          ? rawTalukas
              .whereType<Map>()
              .map(
                (item) => TalukaModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .where(
                (item) => item.id.isNotEmpty &&
                    item.id != '0',
              )
              .toList()
          : [],
    );
  }

  DistrictEntity toEntity() {
    return DistrictEntity(
      id: id,
      name: name,
      talukas: talukas
          .map((item) => item.toEntity())
          .toList(),
    );
  }
}
