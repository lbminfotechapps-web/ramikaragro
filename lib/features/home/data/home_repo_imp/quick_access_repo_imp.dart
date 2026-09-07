import 'package:demo/features/home/data/home_datasource/quick_access_datasource.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/doman/home_repository/qick_access_repo.dart';

class QuickAccessRepoImp implements QickAccessRepo {
  final QuickAccessDatasource quickAccessDatasource;

  QuickAccessRepoImp(this.quickAccessDatasource);

  @override
  Future<PunchStatEntity> getPunchStatus(int userId) {
    return quickAccessDatasource.getPunchStatus(userId);
  }

  @override
  Future<List<VehicleTypeEntity>> getVehicleType(int userId, String lastDate) {
    return quickAccessDatasource.getVehicleType(userId, lastDate);
  }

  @override
  Future<Map<String, dynamic>> savePunchDetails(Map<String, dynamic> jsonData) {
    return quickAccessDatasource.savePunchDetails(jsonData);
  }
}
