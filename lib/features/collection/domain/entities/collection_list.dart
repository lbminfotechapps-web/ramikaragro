class CollectionList {
  final String id;
  final String userId;
  final String dealerId;

  final String paymentMode;
  final String paymentAmount;

  final String rtgsNo;
  final String neftNo;

  final String chequeNo;
  final String chequeDate;

  final String bankName;
  final String depositBankName;
  final String branchName;

  final String status;
  final String remark;

  final String outletName;

  final String? reason;

  final String paymentDate;
  final String? chequePassingDate;

  const CollectionList({
    required this.id,
    required this.userId,
    required this.dealerId,
    required this.paymentMode,
    required this.paymentAmount,
    required this.rtgsNo,
    required this.neftNo,
    required this.chequeNo,
    required this.chequeDate,
    required this.bankName,
    required this.depositBankName,
    required this.branchName,
    required this.status,
    required this.remark,
    required this.outletName,
    required this.reason,
    required this.paymentDate,
    required this.chequePassingDate,
  });
}