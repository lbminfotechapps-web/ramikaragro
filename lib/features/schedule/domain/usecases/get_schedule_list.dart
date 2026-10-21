import '../entities/schedule_list_entity.dart';
import '../repositories/schedule_list_repository.dart';

class GetScheduleList {
  final ScheduleListRepository repository;

  const GetScheduleList(this.repository);

  Future<List<ScheduleListEntity>> call(ScheduleListFilter filter) {
    if (filter.empId.trim().isEmpty || filter.empId.trim() == '0') {
      throw Exception('Please login again.');
    }

    final from = DateTime(
      filter.fromDate.year,
      filter.fromDate.month,
      filter.fromDate.day,
    );

    final to = DateTime(
      filter.toDate.year,
      filter.toDate.month,
      filter.toDate.day,
    );

    if (from.isAfter(to)) {
      throw Exception('From Date cannot be after To Date.');
    }

    return repository.getSchedules(filter);
  }
}

class SearchScheduleListFarmers {
  final ScheduleListRepository repository;

  const SearchScheduleListFarmers(this.repository);

  Future<List<ScheduleFarmerFilter>> call(String search) {
    if (search.trim().length < 3) {
      return Future.value([]);
    }

    return repository.searchFarmers(search.trim());
  }
}
