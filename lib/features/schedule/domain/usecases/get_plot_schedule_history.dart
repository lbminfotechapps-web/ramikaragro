
import '../entities/plot_schedule_entity.dart';
import '../repositories/plot_schedule_repository.dart';

class GetPlotScheduleHistory {
  final PlotScheduleRepository repository;

  const GetPlotScheduleHistory(this.repository);

  Future<List<PlotScheduleEntity>> call(
    PlotScheduleQuery query,
  ) {
    if (query.farmerId.trim().isEmpty ||
        query.plotId.trim().isEmpty) {
      throw ArgumentError(
        'Farmer ID and Plot ID are required',
      );
    }

    if (query.fromDate != null &&
        query.toDate != null &&
        query.fromDate!.isAfter(query.toDate!)) {
      throw ArgumentError(
        'From date cannot be after To date',
      );
    }

    return repository.getHistory(query);
  }
}
