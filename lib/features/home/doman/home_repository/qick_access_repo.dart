import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/social_media.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';

abstract class QickAccessRepo {
  Future<PunchStatEntity> getPunchStatus(int userId);
  Future<List<VehicleTypeEntity>> getVehicleType(int userId, String lastDate);
  Future<Map<String, dynamic>> savePunchDetails(Map<String, dynamic> jsonData);

}
