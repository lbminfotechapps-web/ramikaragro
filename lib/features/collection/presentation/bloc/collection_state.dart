import 'package:solufine/features/collection/data/models/bank_model.dart';
import 'package:solufine/features/collection/data/models/dealer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:solufine/features/collection/domain/entities/collection_type_entity.dart';

enum CollectionStatus { initial, loading, success, failure,getCollectionSuccess }

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
  final List<CollectionTypeEntity> collectionTypes;

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
    this.collectionTypes = const [],
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
    List<CollectionTypeEntity>? collectionTypes,
    // Bank
    List<BankModel>? banks,
    bool? bankLoading,
  }) {
    return CollectionState(
      status: status ?? this.status,

      message: clearMessage ? null : message ?? this.message,

      // Dealer
      dealers: dealers ?? this.dealers,

      dealerLoading: dealerLoading ?? this.dealerLoading,

      dealerError: clearDealerError ? null : dealerError ?? this.dealerError,

      // Bank
      banks: banks ?? this.banks,

      bankLoading: bankLoading ?? this.bankLoading,
      collectionTypes: collectionTypes ?? this.collectionTypes,
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
    collectionTypes,
  ];
}
