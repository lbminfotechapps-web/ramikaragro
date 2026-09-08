import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../domain/usecases/get_top_ten_dealer.dart';
import 'top_ten_dealer_event.dart';
import 'top_ten_dealer_state.dart';

class TopTenDealerBloc
    extends Bloc<TopTenDealerEvent, TopTenDealerState> {
  final GetTopTenDealer getTopTenDealer;
  final SecureStorage secureStorage;

  TopTenDealerBloc({
    required this.getTopTenDealer,
    required this.secureStorage,
  }) : super(const TopTenDealerState()) {
    on<GetTopTenDealerEvent>(
      _onGetTopTenDealer,
    );

    on<RefreshTopTenDealerEvent>(
      _onRefresh,
    );
  }

  Future<String?> _getUserId() async {
    final userData =
        await secureStorage.getUserData();

    if (userData == null) {
      return null;
    }

    final userId =
        userData['user_id']?.toString();

    if (userId == null ||
        userId.trim().isEmpty) {
      return null;
    }

    return userId;
  }

  Future<void> _onGetTopTenDealer(
    GetTopTenDealerEvent event,
    Emitter<TopTenDealerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TopTenDealerStatus.loading,
        selectedDays: event.days,
        clearError: true,
      ),
    );

    try {
      final userId = await _getUserId();

      if (userId == null) {
        emit(
          state.copyWith(
            status:
                TopTenDealerStatus.failure,
            errorMessage:
                'User ID not found',
          ),
        );

        return;
      }

      final dealers = await getTopTenDealer(
        userId: userId,
        days: event.days,
      );

      emit(
        state.copyWith(
          status:
              TopTenDealerStatus.success,
          dealers: dealers,
          selectedDays: event.days,
          clearError: true,
        ),
      );
    } catch (e) {
      String message =
          'Something went wrong';

      if (e is ServerException ||
          e is NetworkException) {
        message = e.toString();
      }

      emit(
        state.copyWith(
          status:
              TopTenDealerStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  Future<void> _onRefresh(
    RefreshTopTenDealerEvent event,
    Emitter<TopTenDealerState> emit,
  ) async {
    add(
      GetTopTenDealerEvent(
        days: state.selectedDays,
      ),
    );
  }
}