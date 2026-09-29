import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dealer_list.dart';
import 'dealer_event.dart';
import 'dealer_state.dart';

class DealerBloc extends Bloc<DealerEvent, DealerState> {
  final GetDealerList getDealerList;

  DealerBloc({required this.getDealerList}) : super(const DealerState()) {
    on<GetDealerListEvent>(_onGetDealerList);
    on<RefreshDealerListEvent>(_onRefreshDealerList);
  }

  Future<void> _onGetDealerList(
    GetDealerListEvent event,
    Emitter<DealerState> emit,
  ) async {
    emit(state.copyWith(status: DealerStatus.loading, message: ''));

    try {
      final response = await getDealerList(userId: event.userId);

      if (response.status) {
        emit(
          state.copyWith(
            status: DealerStatus.success,
            dealers: response.dealers,
            message: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DealerStatus.failure,
            dealers: const [],
            message: response.message,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: DealerStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onRefreshDealerList(
    RefreshDealerListEvent event,
    Emitter<DealerState> emit,
  ) async {
    try {
      final response = await getDealerList(userId: event.userId);

      if (response.status) {
        emit(
          state.copyWith(
            status: DealerStatus.success,
            dealers: response.dealers,
            message: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DealerStatus.failure,
            message: response.message,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: DealerStatus.failure, message: e.toString()));
    }
  }
}
