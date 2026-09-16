import 'package:demo/features/collection/data/models/bank_model.dart';
import 'package:demo/features/collection/data/models/dealer_model.dart';
import 'package:equatable/equatable.dart';

enum CollectionStatus {
  initial,
  loading,
  success,
  failure,
}

class CollectionState extends Equatable {
  final CollectionStatus status;
  final String? message;

  // ==============================
  // Dealer
  // ==============================
  final List<DealerModel> dealers;
  final bool dealerLoading;
  final String? dealerError;

  // ==============================
  // Bank
  // ==============================
  final List<BankModel> banks;
  final bool bankLoading;

  const CollectionState({
    this.status = CollectionStatus.initial,
    this.message,

    // Dealer
    this.dealers = const [],
    this.dealerLoading = false,
    this.dealerError,

    // Bank
    this.banks = const [],
    this.bankLoading = false,
  });

  CollectionState copyWith({
    CollectionStatus? status,
    String? message,
    bool clearMessage = false,

    // Dealer
    List<DealerModel>? dealers,
    bool? dealerLoading,
    String? dealerError,
    bool clearDealerError = false,

    // Bank
    List<BankModel>? banks,
    bool? bankLoading,
  }) {
    return CollectionState(
      status: status ?? this.status,

      message: clearMessage
          ? null
          : message ?? this.message,

      // Dealer
      dealers: dealers ?? this.dealers,

      dealerLoading:
          dealerLoading ?? this.dealerLoading,

      dealerError: clearDealerError
          ? null
          : dealerError ?? this.dealerError,

      // Bank
      banks: banks ?? this.banks,

      bankLoading:
          bankLoading ?? this.bankLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,

        // Dealer
        dealers,
        dealerLoading,
        dealerError,

        // Bank
        banks,
        bankLoading,
      ];
}