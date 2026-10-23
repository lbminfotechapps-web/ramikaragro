
import '../../domain/entities/plot_schedule_entity.dart';
import '../../domain/repositories/plot_schedule_repository.dart';
import '../datasources/plot_schedule_remote_datasource.dart';

class PlotScheduleRepositoryImpl
    implements PlotScheduleRepository {

  final PlotScheduleRemoteDataSource remote;

  const PlotScheduleRepositoryImpl(this.remote);

  @override
  Future<List<PlotScheduleEntity>> getHistory(
    PlotScheduleQuery query,
  ) {
    return remote.fetch(query);
  }
}
