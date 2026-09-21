import 'package:solufine/features/salesreturnhistory/domain/entities/sales_return_history_entity.dart';

import 'sales_return_history_detail_model.dart';

class SalesReturnHistoryModel extends SalesReturnHistoryEntity {
  const SalesReturnHistoryModel({
    required super.fldSalesReturnId,
    required super.fldSalesReturnDate,
    required super.totQtyKg,
    required super.fldTotalQty,
    required super.fldSalesReturnNo,
    required super.fldRemark,
    required super.fldCancelReason,
    required super.fldStatus,
    super.fldOutletName,
    required super.fldUnitName,
    required super.fldDeliveryWithinDate,
    required super.fldGodownName,
    required super.salesReturnDetails,
  });

  factory SalesReturnHistoryModel.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['salesReturnDetails'];

    final details = detailsJson is List
        ? detailsJson
              .map(
                (item) => SalesReturnHistoryDetailModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <SalesReturnHistoryDetailModel>[];

    return SalesReturnHistoryModel(
      fldSalesReturnId: json['fld_sales_return_id']?.toString() ?? '',
      fldSalesReturnDate: json['fld_sales_return_date']?.toString() ?? '',
      totQtyKg: json['tot_qty_kg']?.toString() ?? '',
      fldTotalQty: json['fld_total_qty']?.toString() ?? '',
      fldSalesReturnNo: json['fld_sales_return_no']?.toString() ?? '',
      fldRemark: json['fld_remark']?.toString() ?? '',
      fldCancelReason: json['fld_cancel_reason']?.toString() ?? '',
      fldStatus: json['fld_status']?.toString() ?? '',
      fldOutletName: json['fld_outlet_name']?.toString(),
      fldUnitName: json['fld_unit_name']?.toString() ?? '',
      fldDeliveryWithinDate: json['fld_delivery_within_date']?.toString() ?? '',
      fldGodownName: json['fld_godown_name']?.toString() ?? '',
      salesReturnDetails: details,
    );
  }
}
