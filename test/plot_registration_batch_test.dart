import 'package:solufine/features/plot_registration/data/models/plot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/plot_registration/domain/entities/plot_entities.dart';
import 'package:solufine/features/plot_registration/domain/repositories/plot_repository.dart';
import 'package:solufine/features/plot_registration/domain/usecases/plot_usecases.dart';
import 'package:solufine/features/plot_registration/presentation/bloc/plot_bloc.dart';

class _Repository implements PlotRepository {
  final requests = <PlotSubmission>[];
  @override
  Future<List<CropOption>> getCrops() async => [];
  @override
  Future<List<FarmerOption>> searchFarmers(String name) async => [];
  @override
  Future<PlotSubmitResult> submitPlots(PlotSubmission submission) async {
    requests.add(submission);
    return const PlotSubmitResult(
      status: true,
      message: 'Saved',
      result: 'Saved',
      plotIds: [1],
      rawResponse: {},
    );
  }
}

Future<void> _completeDraft(PlotBloc bloc, String name) async {
  final id = bloc.state.plots.last.localId;
  final ready = bloc.stream.firstWhere((s) => s.plots.last.sowingDate != null);
  bloc.add(UpdatePlotNameEvent(id, name));
  bloc.add(UpdatePlotAcresEvent(id, '2.5'));
  bloc.add(
    UpdatePlotFarmerEvent(id, const FarmerOption(id: '7', name: 'Farmer')),
  );
  bloc.add(UpdatePlotCropEvent(id, const CropOption(id: '9', name: 'Crop')));
  bloc.add(UpdatePlotDateEvent(id, DateTime(2026, 10, 19)));
  await ready;
}

void main() {
  test('acreage must be positive and finite and survives plot changes', () {
    const plot = PlotEntry(localId: 'area');
    for (final value in ['', '0', '-1', 'NaN', 'Infinity', 'abc']) {
      expect(plot.copyWith(acres: value).hasValidAcres, isFalse);
    }
    final updated = plot.copyWith(acres: '2.5').copyWith(plotName: 'Field');
    expect(updated.hasValidAcres, isTrue);
    expect(updated.acres, '2.5');
    expect(plot.copyWith(acres: '2.5').isBlank, isFalse);
  });
  test('schedule farmer is retained for plots, submission and reset', () async {
    final repository = _Repository();
    final bloc = PlotBloc(
      searchFarmers: SearchPlotFarmers(repository),
      getCrops: GetPlotCrops(repository),
      submitPlotRegistration: SubmitPlotRegistration(repository),
    );
    addTearDown(bloc.close);
    const selected = FarmerOption(id: '42', name: 'Schedule farmer');
    final bound = bloc.stream.firstWhere(
      (s) => s.plots.isNotEmpty && s.plots.last.farmer?.id == '42',
    );
    bloc.add(const SetRegistrationFarmer(selected));
    await bound;
    expect(bloc.state.plots.last.isBlank, isTrue);
    await _completeDraft(bloc, 'First plot');
    expect(bloc.state.plots.last.farmer?.id, '42');
    final added = bloc.stream.firstWhere((s) => s.plots.length == 2);
    bloc.add(const AddPlotEvent());
    await added;
    expect(bloc.state.plots.last.farmer?.name, 'Schedule farmer');
    expect(bloc.state.plots.last.isBlank, isTrue);
    final saved = bloc.stream.firstWhere(
      (s) => s.submitStatus == PlotSubmitStatus.success,
    );
    bloc.add(const SubmitPlotsEvent('4'));
    await saved;
    expect(repository.requests.single.plots, hasLength(1));
    expect(repository.requests.single.plots.single.farmer?.id, '42');
    expect(
      (PlotModel.toJson(repository.requests.single)['plots'] as List)
          .single['acres'],
      '2.5',
    );
    final reset = bloc.stream.firstWhere(
      (s) => s.submitStatus == PlotSubmitStatus.initial,
    );
    bloc.add(const ResetPlotEvent());
    await reset;
    expect(bloc.state.plots.single.farmer?.id, '42');
    expect(bloc.state.plots.single.isBlank, isTrue);
  });

  test('add rejects a selected crop with missing API ID', () async {
    final repository = _Repository();
    final bloc = PlotBloc(
      searchFarmers: SearchPlotFarmers(repository),
      getCrops: GetPlotCrops(repository),
      submitPlotRegistration: SubmitPlotRegistration(repository),
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.plots.isNotEmpty);
    final id = bloc.state.plots.last.localId;
    final ready = bloc.stream.firstWhere(
      (s) => s.plots.last.sowingDate != null,
    );
    bloc.add(
      UpdatePlotFarmerEvent(id, const FarmerOption(id: '7', name: 'Farmer')),
    );
    bloc.add(UpdatePlotCropEvent(id, const CropOption(id: '', name: 'Crop')));
    bloc.add(UpdatePlotDateEvent(id, DateTime(2026, 10, 19)));
    await ready;
    final rejected = bloc.stream.firstWhere(
      (s) => s.submitStatus == PlotSubmitStatus.failure,
    );
    bloc.add(const AddPlotEvent(plotName: 'Visible name'));
    await rejected;
    expect(repository.requests, isEmpty);
  });

  test('JSON preview safely displays incomplete retained entries', () {
    const empty = PlotEntry(localId: 'old');
    expect(PlotModel.previewJson(empty), {
      'plotName': '',
      'acres': '',
      'scheduleDate': null,
      'cropId': null,
      'farmerId': null,
    });
    final complete = empty.copyWith(
      plotName: 'Field',
      acres: '2.5',
      farmer: const FarmerOption(id: '7', name: 'Farmer'),
      crop: const CropOption(id: '9', name: 'Crop'),
      sowingDate: DateTime(2026, 10, 19),
    );
    expect(
      PlotModel.previewJson(complete),
      (PlotModel.toJson(PlotSubmission(empId: '4', plots: [complete]))['plots']
              as List)
          .single,
    );
  });

  test('incomplete added entries never reach the submission API', () async {
    final repository = _Repository();
    final submit = SubmitPlotRegistration(repository);
    expect(
      () => submit(
        const PlotSubmission(
          empId: '4',
          plots: [PlotEntry(localId: 'old')],
        ),
      ),
      throwsException,
    );
    expect(repository.requests, isEmpty);
  });

  test(
    'add clears draft and submit sends added plots once without empty draft',
    () async {
      final repository = _Repository();
      final bloc = PlotBloc(
        searchFarmers: SearchPlotFarmers(repository),
        getCrops: GetPlotCrops(repository),
        submitPlotRegistration: SubmitPlotRegistration(repository),
      );
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s.plots.isNotEmpty);
      await _completeDraft(bloc, 'First');
      var added = bloc.stream.firstWhere((s) => s.plots.length == 2);
      bloc.add(const AddPlotEvent());
      await added;
      expect(bloc.state.plots.last.plotName, isEmpty);
      expect(bloc.state.plots.last.farmer, isNull);
      expect(bloc.state.plots.last.crop, isNull);
      expect(bloc.state.plots.last.sowingDate, isNull);
      await _completeDraft(bloc, 'Second');
      added = bloc.stream.firstWhere((s) => s.plots.length == 3);
      bloc.add(const AddPlotEvent());
      await added;
      final submitted = bloc.stream.firstWhere(
        (s) => s.submitStatus == PlotSubmitStatus.success,
      );
      bloc.add(const SubmitPlotsEvent('4'));
      await submitted;
      expect(repository.requests, hasLength(1));
      expect(repository.requests.single.plots.map((p) => p.plotName), [
        'First',
        'Second',
      ]);
    },
  );

  test('incomplete draft cannot be added or submitted', () async {
    final repository = _Repository();
    final bloc = PlotBloc(
      searchFarmers: SearchPlotFarmers(repository),
      getCrops: GetPlotCrops(repository),
      submitPlotRegistration: SubmitPlotRegistration(repository),
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.plots.isNotEmpty);
    final rejectedAdd = bloc.stream.firstWhere(
      (s) => s.submitStatus == PlotSubmitStatus.failure,
    );
    bloc.add(const AddPlotEvent());
    await rejectedAdd;
    expect(bloc.state.plots, hasLength(1));
    final rejectedSubmit = bloc.stream.firstWhere(
      (s) => s.submitStatus == PlotSubmitStatus.failure,
    );
    bloc.add(const SubmitPlotsEvent('4'));
    await rejectedSubmit;
    expect(repository.requests, isEmpty);
  });
}
