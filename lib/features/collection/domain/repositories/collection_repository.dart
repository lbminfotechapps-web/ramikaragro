import 'dart:io';

import 'package:solufine/features/collection/domain/entities/collection_type_entity.dart';

import '../../data/models/bank_model.dart';
import '../../data/models/dealer_model.dart';
import '../entities/submit_payment_response.dart';

abstract class CollectionRepository {
  // ============================================================
  // SUBMIT
  // ============================================================

  Future<SubmitPaymentResponse> submitPaymentDetails({
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
    required String collectionTypeData,
  });

  // ============================================================
  // DEALER SEARCH
  // ============================================================

  Future<List<DealerModel>> searchDealers({
    required String userId,
    required String searchText,
  });

  // ============================================================
  // BANK
  // ============================================================

  Future<List<BankModel>> getBankDetails({
    required String dealerId,
    required String userId,
  });

  Future<CollectionTypeResponseEntity> getCollectionType();
}
