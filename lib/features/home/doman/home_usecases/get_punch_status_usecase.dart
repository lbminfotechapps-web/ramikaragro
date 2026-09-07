import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/doman/home_repository/qick_access_repo.dart';

class GetPunchStatusUsecase {
  final QickAccessRepo qickAccessRepo;

  GetPunchStatusUsecase(this.qickAccessRepo);

  Future<PunchStatEntity> getPunchStatus(int userId) async {
    try {
      return await qickAccessRepo.getPunchStatus(userId);
    } catch (e) {
      throw Exception('Failed to fetch punch status: $e');
    }
  }

  Future<List<VehicleTypeEntity>> getVehicleType(
    int userId,
    String lastDate,
  ) async {
    try {
      return await qickAccessRepo.getVehicleType(userId, lastDate);
    } catch (e) {
      throw Exception('Failed to fetch vehicle types: $e');
    }
  }

  Future<Map<String, dynamic>> savePunchDetails(
    Map<String, dynamic> jsonData,
  ) async {
    try {
      return await qickAccessRepo.savePunchDetails(jsonData);
    } catch (e) {
      throw Exception('Failed to save punch details: $e');
    }
  }
}
