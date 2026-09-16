import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CollectionEvent
    extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// SEARCH DEALER
// ============================================================

class SearchDealerEvent
    extends CollectionEvent {
  final String userId;
  final String searchText;

  const SearchDealerEvent({
    required this.userId,
    required this.searchText,
  });

  @override
  List<Object?> get props => [
        userId,
        searchText,
      ];
}

// ============================================================
// BANK DETAILS
// ============================================================

class GetBankDetailsEvent
    extends CollectionEvent {
  final String dealerId;
  final String userId;

  const GetBankDetailsEvent({
    required this.dealerId,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        dealerId,
        userId,
      ];
}

// ============================================================
// SUBMIT PAYMENT
// ============================================================

class SubmitPaymentEvent
    extends CollectionEvent {
  final String dealerId;
  final String paymentMode;
  final String amount;
  final String rtgsNo;
  final String neftNo;
  final String chequeDate;
  final String chequeNumber;
  final String bankName;
  final String depositBankName;
  final String depositBranchName;
  final String remark;
  final String transaction;
  final String userId;
  final List<File> images;

  const SubmitPaymentEvent({
    required this.dealerId,
    required this.paymentMode,
    required this.amount,
    required this.rtgsNo,
    required this.neftNo,
    required this.chequeDate,
    required this.chequeNumber,
    required this.bankName,
    required this.depositBankName,
    required this.depositBranchName,
    required this.remark,
    required this.transaction,
    required this.userId,
    required this.images,
  });

  @override
  List<Object?> get props => [
        dealerId,
        paymentMode,
        amount,
        rtgsNo,
        neftNo,
        chequeDate,
        chequeNumber,
        bankName,
        depositBankName,
        depositBranchName,
        remark,
        transaction,
        userId,
        images,
      ];
}