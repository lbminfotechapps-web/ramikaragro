import '../entities/field_day_entry.dart';

abstract class FieldDayRepository {
  Future<String> submit(FieldDayEntry entry);
  Future<List<FarmerOption>> searchFarmers(String userId, String search);
}
