import '../../domain/entities/dispatch_order_detail_entity.dart';

class DispatchOrderDetailModel extends DispatchOrderDetailEntity {
  const DispatchOrderDetailModel({
    required super.detailsId,
    required super.orderId,
    required super.productName,
    required super.productQty,
    required super.actualDispatchQty,
    required super.remainingDispatchQty,
    required super.remark,
    required super.packing,
  });

  factory DispatchOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return DispatchOrderDetailModel(
      detailsId: json['fld_details_id']?.toString() ?? '',
      orderId: json['fld_order_id']?.toString() ?? '',
      productName: json['fld_product_name']?.toString() ?? '',
      productQty: json['fld_product_qty']?.toString() ?? '',
      actualDispatchQty: json['fld_actual_dispatch_qty']?.toString() ?? '',
      remainingDispatchQty:
          json['fld_remaining_dispatch_qty']?.toString() ?? '',
      remark: json['fld_remark']?.toString() ?? '',
      packing: json['fld_packing']?.toString() ?? '',
    );
  }

}
