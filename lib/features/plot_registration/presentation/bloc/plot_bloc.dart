import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/plot_entities.dart';
import '../../domain/usecases/plot_usecases.dart';

abstract class PlotEvent {
  const PlotEvent();
}

class LoadPlotCrops extends PlotEvent {
  const LoadPlotCrops();
}

class SearchFarmersEvent extends PlotEvent {
  final String query;
  const SearchFarmersEvent(this.query);
}

class AddPlotEvent extends PlotEvent {
  final String? plotName;
  const AddPlotEvent({this.plotName});
}

class RemovePlotEvent extends PlotEvent {
  final String id;
  const RemovePlotEvent(this.id);
}

class UpdatePlotNameEvent extends PlotEvent {
  final String id;
  final String name;
  const UpdatePlotNameEvent(this.id, this.name);
}

class UpdatePlotFarmerEvent extends PlotEvent {
  final String id;
  final FarmerOption farmer;
  const UpdatePlotFarmerEvent(this.id, this.farmer);
}

class UpdatePlotCropEvent extends PlotEvent {
  final String id;
  final CropOption crop;
  const UpdatePlotCropEvent(this.id, this.crop);
}

class UpdatePlotDateEvent extends PlotEvent {
  final String id;
  final DateTime date;
  const UpdatePlotDateEvent(this.id, this.date);
}

class SubmitPlotsEvent extends PlotEvent {
  final String empId;
  const SubmitPlotsEvent(this.empId);
}

class SetRegistrationFarmer extends PlotEvent {
  final FarmerOption farmer;
  const SetRegistrationFarmer(this.farmer);
}

class ResetPlotEvent extends PlotEvent {
  const ResetPlotEvent();
}

enum PlotSubmitStatus { initial, submitting, success, failure }

class PlotState {
  final List<PlotEntry> plots;
  final List<FarmerOption> farmers;
  final List<CropOption> crops;
  final bool loadingFarmers;
  final bool loadingCrops;
  final String farmerError;
  final String cropError;
  final PlotSubmitStatus submitStatus;
  final String message;
  final PlotSubmitResult? submitResult;

  const PlotState({
    this.plots = const [],
    this.farmers = const [],
    this.crops = const [],
    this.loadingFarmers = false,
    this.loadingCrops = false,
    this.farmerError = '',
    this.cropError = '',
    this.submitStatus = PlotSubmitStatus.initial,
    this.message = '',
    this.submitResult,
  });

  PlotState copyWith({
    List<PlotEntry>? plots,
    List<FarmerOption>? farmers,
    List<CropOption>? crops,
    bool? loadingFarmers,
    bool? loadingCrops,
    String? farmerError,
    String? cropError,
    PlotSubmitStatus? submitStatus,
    String? message,
    PlotSubmitResult? submitResult,
    bool clearResult = false,
  }) => PlotState(
    plots: plots ?? this.plots,
    farmers: farmers ?? this.farmers,
    crops: crops ?? this.crops,
    loadingFarmers: loadingFarmers ?? this.loadingFarmers,
    loadingCrops: loadingCrops ?? this.loadingCrops,
    farmerError: farmerError ?? this.farmerError,
    cropError: cropError ?? this.cropError,
    submitStatus: submitStatus ?? this.submitStatus,
    message: message ?? this.message,
    submitResult: clearResult ? null : submitResult ?? this.submitResult,
  );
}

class PlotBloc extends Bloc<PlotEvent, PlotState> {
  final SearchPlotFarmers searchFarmers;
  final GetPlotCrops getCrops;
  final SubmitPlotRegistration submitPlotRegistration;
  FarmerOption? _registrationFarmer;
  PlotEntry _newDraft() =>
      PlotEntry(localId: 'plot_${++_nextId}', farmer: _registrationFarmer);
  int _nextId = 0;
  int _searchVersion = 0;
  bool _submitInProgress = false;

  PlotBloc({
    required this.searchFarmers,
    required this.getCrops,
    required this.submitPlotRegistration,
  }) : super(const PlotState()) {
    on<SetRegistrationFarmer>((event, emit) {
      if (_editingLocked) return;
      _registrationFarmer = event.farmer;
      emit(
        state.copyWith(
          plots: state.plots
              .map((plot) => plot.copyWith(farmer: event.farmer))
              .toList(),
        ),
      );
    });
    on<AddPlotEvent>((event, emit) {
      if (_editingLocked) return;
      final plots = state.plots;
      if (plots.isNotEmpty) {
        final last = plots.last.copyWith(plotName: event.plotName);
        if (!last.isComplete) {
          emit(
            state.copyWith(
              submitStatus: PlotSubmitStatus.failure,
              message: 'Complete the current plot before adding another.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            plots: [...plots.take(plots.length - 1), last, _newDraft()],
            submitStatus: PlotSubmitStatus.initial,
            message: '',
          ),
        );
      } else {
        emit(state.copyWith(plots: [_newDraft()]));
      }
    });

    on<RemovePlotEvent>((event, emit) {
      if (_editingLocked) return;
      final remaining = state.plots
          .where((p) => p.localId != event.id)
          .toList();
      if (remaining.isEmpty || !remaining.last.isBlank) {
        remaining.add(_newDraft());
      }
      emit(state.copyWith(plots: remaining));
    });
    on<UpdatePlotNameEvent>(
      (event, emit) =>
          _update(event.id, (p) => p.copyWith(plotName: event.name), emit),
    );
    on<UpdatePlotFarmerEvent>(
      (event, emit) => _update(
        event.id,
        (p) => p.copyWith(farmer: _registrationFarmer ?? event.farmer),
        emit,
      ),
    );
    on<UpdatePlotCropEvent>(
      (event, emit) =>
          _update(event.id, (p) => p.copyWith(crop: event.crop), emit),
    );
    on<UpdatePlotDateEvent>(
      (event, emit) =>
          _update(event.id, (p) => p.copyWith(sowingDate: event.date), emit),
    );
    on<LoadPlotCrops>(_loadCrops);
    on<SearchFarmersEvent>(_searchFarmers);
    on<SubmitPlotsEvent>(_submit);
    on<ResetPlotEvent>((event, emit) {
      if (_submitInProgress) return;
      emit(
        state.copyWith(
          plots: [_newDraft()],
          submitStatus: PlotSubmitStatus.initial,
          message: '',
          clearResult: true,
        ),
      );
    });
    add(const AddPlotEvent());
    add(const LoadPlotCrops());
  }

  bool get _editingLocked =>
      _submitInProgress || state.submitStatus == PlotSubmitStatus.success;

  void _update(
    String id,
    PlotEntry Function(PlotEntry) change,
    Emitter<PlotState> emit,
  ) {
    if (_editingLocked) return;
    emit(
      state.copyWith(
        plots: state.plots.map((p) => p.localId == id ? change(p) : p).toList(),
      ),
    );
  }

  Future<void> _loadCrops(LoadPlotCrops event, Emitter<PlotState> emit) async {
    emit(state.copyWith(loadingCrops: true, cropError: ''));
    try {
      final crops = await getCrops();
      emit(state.copyWith(crops: crops, loadingCrops: false));
    } catch (e) {
      emit(state.copyWith(loadingCrops: false, cropError: e.toString()));
    }
  }

  Future<void> _searchFarmers(
    SearchFarmersEvent event,
    Emitter<PlotState> emit,
  ) async {
    final requestVersion = ++_searchVersion;
    emit(
      state.copyWith(loadingFarmers: true, farmers: const [], farmerError: ''),
    );
    try {
      final farmers = await searchFarmers(event.query);
      if (requestVersion != _searchVersion) return;
      emit(state.copyWith(farmers: farmers, loadingFarmers: false));
    } catch (e) {
      if (requestVersion != _searchVersion) return;
      emit(state.copyWith(loadingFarmers: false, farmerError: e.toString()));
    }
  }

  Future<void> _submit(SubmitPlotsEvent event, Emitter<PlotState> emit) async {
    if (_submitInProgress || state.submitStatus == PlotSubmitStatus.success)
      return;
    _submitInProgress = true;
    final entries = List<PlotEntry>.from(state.plots);
    final plots = entries.where((p) => !p.isBlank).toList();
    emit(
      state.copyWith(
        submitStatus: PlotSubmitStatus.submitting,
        message: '',
        clearResult: true,
      ),
    );
    try {
      final result = await submitPlotRegistration(
        PlotSubmission(empId: event.empId, plots: plots),
      );
      debugPrint('ADD PLOT SUCCESS: ${result.message}, IDs: ${result.plotIds}');
      emit(
        state.copyWith(
          submitStatus: PlotSubmitStatus.success,
          message: result.message,
          submitResult: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: PlotSubmitStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _submitInProgress = false;
    }
  }
}
