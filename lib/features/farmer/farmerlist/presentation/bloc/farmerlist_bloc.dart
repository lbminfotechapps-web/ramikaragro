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
    print('');
    print('========================================');
    print('BLOC EVENT RECEIVED');
    print('========================================');

    print('User ID     : ${event.user_id}');
    print('Latitude    : ${event.currentLat}');
    print('Longitude   : ${event.currentLong}');
    print('Limit       : ${event.limit}');
    print('Search Key  : ${event.searchKey}');

    emit(state.copyWith(status: FarmerlistStatus.loading));

    print('BLOC STATUS: LOADING');

    try {
      final farmers = await repository.getFarmers(
        event.user_id,
        event.currentLat,
        event.currentLong,
        event.limit,
        event.searchKey,
      );

      print('');
      print('========================================');
      print('BLOC RESPONSE');
      print('========================================');

      print('Farmers received: ${farmers.length}');

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
      print('');
      print('========================================');
      print('BLOC ERROR');
      print('========================================');

      print('ERROR: $e');
      print('STACK: $stackTrace');

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
