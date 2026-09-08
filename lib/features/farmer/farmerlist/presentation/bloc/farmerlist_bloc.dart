import 'package:demo/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_event.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerListBloc extends Bloc<FarmerlistEvent, FarmerListState> {
  final FarmerListRepository repository;

  FarmerListBloc({required this.repository}) : super(const FarmerListState()) {
    on<FarmerListEvent>(_onLoadFarmers);
  }

  Future<void> _onLoadFarmers(
    FarmerListEvent event,
    Emitter<FarmerListState> emit,
  ) async {
    emit(state.copyWith(status: FarmerlistStatus.loading));

    print('BLOC STATUS: LOADING');

    try {
      final farmers = await repository.getFarmers(
        event.user_id,
        event.currentLat,
        event.currentLong,
        event.startLimit,
        event.searchText,
      );

      for (final farmer in farmers) {
        print(
          'ID: ${farmer.farmerId} | '
          'Name: ${farmer.farmerName}',
        );
      }

      emit(
        state.copyWith(status: FarmerlistStatus.success, farmerList: farmers),
      );

      print('BLOC STATUS: SUCCESS');
    } catch (e, stackTrace) {
      emit(
        state.copyWith(
          status: FarmerlistStatus.failure,
          errorMessage: e.toString(),
        ),
      );

      print('BLOC STATUS: FAILURE');
    }
  }
}
