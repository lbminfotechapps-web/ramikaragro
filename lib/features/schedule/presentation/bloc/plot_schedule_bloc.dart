import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/plot_schedule_entity.dart';
import '../../domain/repositories/plot_schedule_repository.dart';
import '../../domain/usecases/get_plot_schedule_history.dart';

abstract class PlotScheduleEvent {
  const PlotScheduleEvent();
}

class LoadPlotScheduleHistory extends PlotScheduleEvent {
  final PlotScheduleQuery query;
  const LoadPlotScheduleHistory(this.query);
}

class LoadMorePlotScheduleHistory extends PlotScheduleEvent {
  const LoadMorePlotScheduleHistory();
}

enum PlotScheduleStatus { initial, loading, success, failure }

class PlotScheduleState {
  final PlotScheduleStatus status;
  final List<PlotScheduleEntity> schedules;
  final String error;
  final bool? _isLoadingMore;
  bool get isLoadingMore => _isLoadingMore ?? false;
  final bool? _hasMore;
  bool get hasMore => _hasMore ?? true;
  final String? _loadMoreError;
  String get loadMoreError => _loadMoreError ?? '';
  const PlotScheduleState({
    this.status = PlotScheduleStatus.initial,
    this.schedules = const [],
    this.error = '',
    bool isLoadingMore = false,
    bool hasMore = true,
    String loadMoreError = '',
  }) : _isLoadingMore = isLoadingMore,
       _hasMore = hasMore,
       _loadMoreError = loadMoreError;
}

class PlotScheduleBloc extends Bloc<PlotScheduleEvent, PlotScheduleState> {
  final GetPlotScheduleHistory getHistory;
  PlotScheduleQuery? _query;
  int _generation = 0;
  static const int _pageSize = 15;
  int _nextOffset = 0;

  PlotScheduleBloc(this.getHistory) : super(const PlotScheduleState()) {
    on<LoadPlotScheduleHistory>((event, emit) async {
      final generation = ++_generation;
      _query = event.query;
      _nextOffset = 0;
      emit(const PlotScheduleState(status: PlotScheduleStatus.loading));
      try {
        final result = await getHistory(_pageQuery(0));
        if (generation != _generation) return;
        _nextOffset = _pageSize;
        emit(
          PlotScheduleState(
            status: PlotScheduleStatus.success,
            schedules: result,
            hasMore: result.length >= _pageSize,
          ),
        );
      } catch (error) {
        if (generation != _generation) return;
        emit(
          PlotScheduleState(
            status: PlotScheduleStatus.failure,
            error: error.toString(),
          ),
        );
      }
    });
    on<LoadMorePlotScheduleHistory>((event, emit) async {
      if (_query == null ||
          state.status != PlotScheduleStatus.success ||
          state.isLoadingMore ||
          !state.hasMore)
        return;
      final generation = _generation;
      final existing = state.schedules;
      emit(
        PlotScheduleState(
          status: PlotScheduleStatus.success,
          schedules: existing,
          isLoadingMore: true,
        ),
      );
      try {
        final result = await getHistory(_pageQuery(_nextOffset));
        if (generation != _generation) return;
        _nextOffset += _pageSize;
        final ids = existing.map((schedule) => schedule.id).toSet();
        final added = result.where((schedule) => ids.add(schedule.id)).toList();
        emit(
          PlotScheduleState(
            status: PlotScheduleStatus.success,
            schedules: [...existing, ...added],
            hasMore: result.length >= _pageSize && added.isNotEmpty,
          ),
        );
      } catch (error) {
        if (generation != _generation) return;
        emit(
          PlotScheduleState(
            status: PlotScheduleStatus.success,
            schedules: existing,
            loadMoreError: error.toString(),
          ),
        );
      }
    });
  }
  PlotScheduleQuery _pageQuery(int offset) {
    final query = _query!;
    return PlotScheduleQuery(
      farmerId: query.farmerId,
      plotId: query.plotId,
      cropId: query.cropId,
      fromDate: query.fromDate,
      toDate: query.toDate,
      startLimit: offset,
      status: query.status,
    );
  }
}
