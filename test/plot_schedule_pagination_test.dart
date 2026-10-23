import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/plot_schedule_model.dart';
import 'package:solufine/features/schedule/domain/entities/plot_schedule_entity.dart';
import 'package:solufine/features/schedule/domain/repositories/plot_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/get_plot_schedule_history.dart';
import 'package:solufine/features/schedule/presentation/bloc/plot_schedule_bloc.dart';

class FakeRepository implements PlotScheduleRepository {
  final queries = <PlotScheduleQuery>[];
  bool fail = false;
  @override
  Future<List<PlotScheduleEntity>> getHistory(PlotScheduleQuery query) async {
    queries.add(query);
    if (fail) throw Exception('offline');
    final ids = switch (query.startLimit) {
      0 => List.generate(15, (i) => (i + 1).toString()),
      15 => List.generate(15, (i) => (i + 15).toString()),
      _ => <String>[],
    };
    return ids
        .map((id) => PlotScheduleModel.fromJson({'fld_schedule_id': id}))
        .toList();
  }
}

Future<void> send(PlotScheduleBloc bloc, PlotScheduleEvent event) async {
  final done = bloc.stream.firstWhere(
    (s) =>
        (s.status == PlotScheduleStatus.success && !s.isLoadingMore) ||
        s.status == PlotScheduleStatus.failure,
  );
  bloc.add(event);
  await done;
}

void main() {
  test('status filter survives pagination and clears on reset', () async {
    final repository = FakeRepository();
    final bloc = PlotScheduleBloc(GetPlotScheduleHistory(repository));
    addTearDown(bloc.close);
    for (final status in ['1', '0']) {
      await send(
        bloc,
        LoadPlotScheduleHistory(
          PlotScheduleQuery(farmerId: '1', plotId: '12', status: status),
        ),
      );
      await send(bloc, const LoadMorePlotScheduleHistory());
      expect(repository.queries.last.status, status);
      expect(repository.queries.last.startLimit, 15);
    }
    await send(
      bloc,
      const LoadPlotScheduleHistory(
        PlotScheduleQuery(farmerId: '1', plotId: '12'),
      ),
    );
    expect(repository.queries.last.status, isNull);
    expect(repository.queries.last.startLimit, 0);
  });

  test(
    'offset pages append without duplicates, stop, and reset filters',
    () async {
      final repository = FakeRepository();
      final bloc = PlotScheduleBloc(GetPlotScheduleHistory(repository));
      addTearDown(bloc.close);
      await send(
        bloc,
        const LoadPlotScheduleHistory(
          PlotScheduleQuery(farmerId: '1', plotId: '12'),
        ),
      );
      await send(bloc, const LoadMorePlotScheduleHistory());
      expect(
        bloc.state.schedules.map((s) => s.id),
        List.generate(29, (i) => (i + 1).toString()),
      );
      await send(bloc, const LoadMorePlotScheduleHistory());
      expect(repository.queries.map((q) => q.startLimit), [0, 15, 30]);
      expect(bloc.state.hasMore, false);
      await send(
        bloc,
        const LoadPlotScheduleHistory(
          PlotScheduleQuery(farmerId: '1', plotId: '12', cropId: '7'),
        ),
      );
      expect(repository.queries.last.startLimit, 0);
      expect(repository.queries.last.cropId, '7');
      expect(bloc.state.schedules.length, 15);
    },
  );
  test('page failure preserves items and retries the same offset', () async {
    final repository = FakeRepository();
    final bloc = PlotScheduleBloc(GetPlotScheduleHistory(repository));
    addTearDown(bloc.close);
    await send(
      bloc,
      const LoadPlotScheduleHistory(
        PlotScheduleQuery(farmerId: '1', plotId: '12'),
      ),
    );
    repository.fail = true;
    await send(bloc, const LoadMorePlotScheduleHistory());
    expect(bloc.state.schedules.length, 15);
    expect(bloc.state.loadMoreError, isNotEmpty);
    repository.fail = false;
    await send(bloc, const LoadMorePlotScheduleHistory());
    expect(repository.queries.map((q) => q.startLimit), [0, 15, 15]);
    expect(bloc.state.schedules.length, 29);
  });
}
