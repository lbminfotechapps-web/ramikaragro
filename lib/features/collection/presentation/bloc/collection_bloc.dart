import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_bank_details.dart';
import '../../domain/usecases/search_dealers.dart';
import '../../domain/usecases/submit_payment_details.dart';
import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc
    extends Bloc<
        CollectionEvent,
        CollectionState> {
  final SubmitPaymentDetails
      submitPaymentDetails;

  final SearchDealers searchDealers;

  final GetBankDetails getBankDetails;

  CollectionBloc({
    required this.submitPaymentDetails,
    required this.searchDealers,
    required this.getBankDetails,
  }) : super(
          const CollectionState(),
        ) {
    on<SearchDealerEvent>(
      _onSearchDealer,
    );

    on<GetBankDetailsEvent>(
      _onGetBankDetails,
    );

    on<SubmitPaymentEvent>(
      _onSubmitPayment,
    );
  }

  // ============================================================
  // SEARCH DEALER
  // ============================================================

  Future<void> _onSearchDealer(
    SearchDealerEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        dealerLoading: true,
        clearMessage: true,
      ),
    );

    try {
      print(
        'COLLECTION BLOC: SEARCH DEALER',
      );

      final dealers =
          await searchDealers(
        userId: event.userId,
        searchText: event.searchText,
      );

      emit(
        state.copyWith(
          dealerLoading: false,
          dealers: dealers,
        ),
      );
    } catch (e) {
      print(
        'SEARCH DEALER ERROR: $e',
      );

      emit(
        state.copyWith(
          dealerLoading: false,
          dealers: const [],
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET BANK DETAILS
  // ============================================================

  Future<void> _onGetBankDetails(
    GetBankDetailsEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        bankLoading: true,
        banks: const [],
        clearMessage: true,
      ),
    );

    try {
      print(
        'COLLECTION BLOC: GET BANK',
      );

      final banks =
          await getBankDetails(
        dealerId: event.dealerId,
        userId: event.userId,
      );

      emit(
        state.copyWith(
          bankLoading: false,
          banks: banks,
        ),
      );
    } catch (e) {
      print(
        'GET BANK ERROR: $e',
      );

      emit(
        state.copyWith(
          bankLoading: false,
          banks: const [],
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _onSubmitPayment(
    SubmitPaymentEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            CollectionStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      print(
        '======================================',
      );
      print('COLLECTION BLOC SUBMIT');
      print(
        'DEALER ID: ${event.dealerId}',
      );
      print(
        'PAYMENT MODE: ${event.paymentMode}',
      );
      print(
        'AMOUNT: ${event.amount}',
      );
      print(
        'USER ID: ${event.userId}',
      );
      print(
        'IMAGE COUNT: ${event.images.length}',
      );
      print(
        '======================================',
      );

      final response =
          await submitPaymentDetails(
        dealerId: event.dealerId,
        paymentMode:
            event.paymentMode,
        amount: event.amount,
        rtgsNo: event.rtgsNo,
        neftNo: event.neftNo,
        chequeDate:
            event.chequeDate,
        chequeNumber:
            event.chequeNumber,
        bankName: event.bankName,
        depositBankName:
            event.depositBankName,
        depositBranchName:
            event.depositBranchName,
        remark: event.remark,
        transaction:
            event.transaction,
        userId: event.userId,
        images: event.images,
      );

      emit(
        state.copyWith(
          status:
              CollectionStatus.success,
          message: response.message,
        ),
      );
    } catch (e) {
      print(
        'COLLECTION BLOC ERROR: $e',
      );

      emit(
        state.copyWith(
          status:
              CollectionStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}