import 'package:demo/features/farmer/farmerregistration/domain/entity/taluka_entity.dart';

class DistrictEntity
{
  final String fld_dist_id;
  final String fld_dist_name;
  final List<TalukaEntity> talukas;

  DistrictEntity(this.fld_dist_name, this.fld_dist_id, this.talukas);
}