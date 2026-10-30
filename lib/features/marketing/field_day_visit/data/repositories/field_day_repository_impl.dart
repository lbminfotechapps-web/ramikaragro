import '../../domain/entities/field_day_entry.dart';
import '../../domain/repositories/field_day_repository.dart';
import '../datasources/field_day_data_source.dart';

class FieldDayRepositoryImpl implements FieldDayRepository {
  final FieldDayDataSource source;
  const FieldDayRepositoryImpl(this.source);
  @override
  Future<String> submit(FieldDayEntry e) => source.submit(e);
  @override
  Future<List<FarmerOption>> searchFarmers(String userId, String search) =>
      source.searchFarmers(userId, search);
}
