
import '../../domain/entities/schedule_list_entity.dart';

abstract class ScheduleListEvent {
  const ScheduleListEvent();
}

class LoadScheduleList extends ScheduleListEvent {
  final ScheduleListFilter filter;

  const LoadScheduleList(this.filter);
}

class SearchScheduleFarmers extends ScheduleListEvent {
  final String search;

  const SearchScheduleFarmers(this.search);
}

class ClearScheduleFarmerResults extends ScheduleListEvent {
  const ClearScheduleFarmerResults();
}

class ResetScheduleList extends ScheduleListEvent {
  const ResetScheduleList();
}
