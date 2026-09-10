import '../../domain/entities/collection_list.dart';

class CollectionListModel extends CollectionList {
  const CollectionListModel({
    required super.id,
    required super.userId,
    required super.dealerId,
    required super.paymentMode,
    required super.paymentAmount,
    required super.rtgsNo,
    required super.neftNo,
    required super.chequeNo,
    required super.chequeDate,
    required super.bankName,
    required super.depositBankName,
    required super.branchName,
    required super.status,
    required super.remark,
    required super.outletName,
    required super.reason,
    required super.paymentDate,
    required super.chequePassingDate,
  });

  factory CollectionListModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CollectionListModel(
      id: json['fld_pc_id']?.toString() ?? '',
      userId: json['fld_pc_user_id']?.toString() ?? '',
      dealerId: json['fld_pc_dealer_id']?.toString() ?? '',
      paymentMode: json['fld_pc_payment_mode']?.toString() ?? '',
      paymentAmount: json['fld_pc_payment_amount']?.toString() ?? '',
      rtgsNo: json['fld_pc_rtgs_no']?.toString() ?? '',
      neftNo: json['fld_pc_neft_no']?.toString() ?? '',
      chequeNo: json['fld_pc_cheque_no']?.toString() ?? '',
      chequeDate: json['fld_pc_cheque_date']?.toString() ?? '',
      bankName: json['fld_pc_bank_name']?.toString() ?? '',
      depositBankName:
          json['fld_pc_deposit_bank_name']?.toString() ?? '',
      branchName:
          json['fld_pc_branch_name']?.toString() ?? '',
      status:
          json['fld_status']?.toString() ?? '',
      remark:
          json['fld_remark']?.toString() ?? '',
      outletName:
          json['fld_outlet_name']?.toString() ?? '',
      reason:
          json['reason']?.toString(),
      paymentDate:
          json['fld_pc_payment_date']?.toString() ?? '',
      chequePassingDate:
          json['fld_cheque_passing_date']?.toString(),
    );
  }
}