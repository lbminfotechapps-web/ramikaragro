import 'dart:io';

import '../entities/submit_payment_response.dart';
import '../repositories/collection_repository.dart';

class SubmitPaymentDetails {
  final CollectionRepository repository;

  SubmitPaymentDetails({
    required this.repository,
  });

  Future<SubmitPaymentResponse> call({
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
    return repository.submitPaymentDetails(
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
}