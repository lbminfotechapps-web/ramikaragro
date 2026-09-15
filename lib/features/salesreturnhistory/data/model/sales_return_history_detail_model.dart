import 'package:demo/features/salesreturnhistory/domain/entities/sales_return_history_detail_entity.dart';

class SalesReturnHistoryDetailModel extends SalesReturnHistoryDetailEntity {
  const SalesReturnHistoryDetailModel({
    required super.fldSalesReturnDetId,
    required super.fldSalesReturnId,
    required super.fldProductName,
    required super.fldProductQty,
    required super.fldQtyInPkt,
    required super.fldUnit,
  });

  factory SalesReturnHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnHistoryDetailModel(
      fldSalesReturnDetId: json['fld_sales_return_det_id']?.toString() ?? '',
      fldSalesReturnId: json['fld_sales_return_id']?.toString() ?? '',
      fldProductName: json['fld_product_name']?.toString() ?? '',
      fldProductQty: json['fld_product_qty']?.toString() ?? '',
      fldQtyInPkt: json['fld_qty_in_pkt']?.toString() ?? '',
      fldUnit: json['fld_unit']?.toString() ?? '',
    );
  }
}
