import 'package:demo/features/orderhistory/domain/entities/order_detail_entity.dart';

class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.detailsId,
    required super.orderId,
    required super.packing,
    required super.productAmt,
    required super.productId,
    required super.productName,
    required super.productPath,
    required super.productQty,
    required super.totalCaseQuantity,
    required super.casewiseOrQtyFlag,
    required super.pendingQty,
    required super.dispatchQty,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      detailsId: json['fld_details_id']?.toString() ?? '',
      orderId: json['fld_order_id']?.toString() ?? '',
      packing: json['fld_packing']?.toString() ?? '',
      productAmt: json['fld_product_amt']?.toString() ?? '',
      productId: json['fld_product_id']?.toString() ?? '',
      productName: json['fld_product_name']?.toString() ?? '',
      productPath: json['fld_product_path']?.toString() ?? '',
      productQty: json['fld_product_qty']?.toString() ?? '',
      totalCaseQuantity: json['fld_total_case_quantity']?.toString() ?? '',
      casewiseOrQtyFlag: json['fld_casewise_or_qty_flag']?.toString() ?? '',
      pendingQty: json['fld_pending_qty']?.toString() ?? '',
      dispatchQty: json['dispatch_qty']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_details_id': detailsId,
      'fld_order_id': orderId,
      'fld_packing': packing,
      'fld_product_amt': productAmt,
      'fld_product_id': productId,
      'fld_product_name': productName,
      'fld_product_path': productPath,
      'fld_product_qty': productQty,
      'fld_total_case_quantity': totalCaseQuantity,
      'fld_casewise_or_qty_flag': casewiseOrQtyFlag,
      'fld_pending_qty': pendingQty,
      'dispatch_qty': dispatchQty,
    };
  }
}
