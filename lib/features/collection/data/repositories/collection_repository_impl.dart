import 'dart:io';

import 'package:demo/features/collection/data/models/bank_model.dart';
import 'package:demo/features/collection/data/models/dealer_model.dart';

import '../../domain/entities/submit_payment_response.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_datasource.dart';

class CollectionRepositoryImpl
    implements CollectionRepository {
  final CollectionRemoteDataSource remoteDataSource;

  CollectionRepositoryImpl({
    required this.remoteDataSource,
  });

  // ============================================================
  // SUBMIT
  // ============================================================

  @override
  Future<SubmitPaymentResponse>
      submitPaymentDetails({
    required String dealerId,
    required String paymentMode,
    required String amount,
    required String rtgsNo,
    required String neftNo,
    required String chequeDate,
    required String chequeNumber,
    required String bankName,
    required String depositBankName,
    required String depositBranchName,
    required String remark,
    required String transaction,
    required String userId,
    required List<File> images,
  }) {
    return remoteDataSource.submitPaymentDetails(
      dealerId: dealerId,
      paymentMode: paymentMode,
      amount: amount,
      rtgsNo: rtgsNo,
      neftNo: neftNo,
      chequeDate: chequeDate,
      chequeNumber: chequeNumber,
      bankName: bankName,
      depositBankName: depositBankName,
      depositBranchName: depositBranchName,
      remark: remark,
      transaction: transaction,
      userId: userId,
      images: images,
    );
  }

  // ============================================================
  // DEALER SEARCH
  // ============================================================

  @override
  Future<List<DealerModel>> searchDealers({
    required String userId,
    required String searchText,
  }) {
    return remoteDataSource.searchDealers(
      userId: userId,
      searchText: searchText,
    );
  }

  // ============================================================
  // BANK
  // ============================================================

  @override
  Future<List<BankModel>> getBankDetails({
    required String dealerId,
    required String userId,
  }) {
    return remoteDataSource.getBankDetails(
      dealerId: dealerId,
      userId: userId,
    );
  }
}