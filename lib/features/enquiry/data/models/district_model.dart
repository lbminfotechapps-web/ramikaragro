import '../../domain/entities/district_entity.dart';
import 'taluka_model.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.name,
    required super.talukas,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> talukaJson =
        json['taluka'] as List<dynamic>? ?? [];
    return DistrictModel(
      id: json['fld_dist_id']?.toString() ?? '',
      name: json['fld_dist_name']?.toString() ?? '',
      talukas: talukaJson
          .whereType<Map<String, dynamic>>()
          .map(TalukaModel.fromJson)
          .toList(),
    );
  }
}