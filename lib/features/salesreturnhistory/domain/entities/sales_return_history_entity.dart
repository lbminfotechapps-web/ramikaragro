import 'sales_return_history_detail_entity.dart';

class SalesReturnHistoryEntity {
  final String fldSalesReturnId;
  final String fldSalesReturnDate;
  final String totQtyKg;
  final String fldTotalQty;
  final String fldSalesReturnNo;
  final String fldRemark;
  final String fldCancelReason;
  final String fldStatus;
  final String? fldOutletName;
  final String fldUnitName;
  final String fldDeliveryWithinDate;
  final String fldGodownName;

  final List<SalesReturnHistoryDetailEntity> salesReturnDetails;

  const SalesReturnHistoryEntity({
    required this.fldSalesReturnId,
    required this.fldSalesReturnDate,
    required this.totQtyKg,
    required this.fldTotalQty,
    required this.fldSalesReturnNo,
    required this.fldRemark,
    required this.fldCancelReason,
    required this.fldStatus,
    this.fldOutletName,
    required this.fldUnitName,
    required this.fldDeliveryWithinDate,
    required this.fldGodownName,
    required this.salesReturnDetails,
  });
}
