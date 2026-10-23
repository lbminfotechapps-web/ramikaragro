import '../entities/plot_schedule_entity.dart';

class PlotScheduleQuery {
  final String farmerId;
  final String plotId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? cropId;
  final int startLimit;
  final String? status;

  const PlotScheduleQuery({
    required this.farmerId,
    required this.plotId,
    this.fromDate,
    this.toDate,
    this.cropId,
    this.startLimit = 0,
    this.status,
  });
}

abstract class PlotScheduleRepository {
  Future<List<PlotScheduleEntity>> getHistory(PlotScheduleQuery query);
}
