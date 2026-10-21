
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/schedule_list_repository.dart';

enum ScheduleListStatus {
  initial,
  loading,
  success,
  failure,
}

class ScheduleListState {
  final ScheduleListStatus status;
  final List<ScheduleListEntity> schedules;
  final List<ScheduleFarmerFilter> farmers;
  final bool farmerLoading;
  final String errorMessage;

  const ScheduleListState({
    this.status = ScheduleListStatus.initial,
    this.schedules = const [],
    this.farmers = const [],
    this.farmerLoading = false,
    this.errorMessage = '',
  });

  ScheduleListState copyWith({
    ScheduleListStatus? status,
    List<ScheduleListEntity>? schedules,
    List<ScheduleFarmerFilter>? farmers,
    bool? farmerLoading,
    String? errorMessage,
  }) {
    return ScheduleListState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      farmers: farmers ?? this.farmers,
      farmerLoading: farmerLoading ?? this.farmerLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
