class DispatchOrderDetailEntity {
  final String detailsId;
  final String orderId;
  final String productName;
  final String productQty;
  final String actualDispatchQty;
  final String remainingDispatchQty;
  final String remark;
  final String packing;

  const DispatchOrderDetailEntity({
    required this.detailsId,
    required this.orderId,
    required this.productName,
    required this.productQty,
    required this.actualDispatchQty,
    required this.remainingDispatchQty,
    required this.remark,
    required this.packing,
  });

  Map<String, dynamic> toJson() {
    return {
      'fld_details_id': detailsId,
      'fld_order_id': orderId,
      'fld_product_name': productName,
      'fld_product_qty': productQty,
      'fld_actual_dispatch_qty': actualDispatchQty,
      'fld_remaining_dispatch_qty': remainingDispatchQty,
      'fld_remark': remark,
      'fld_packing': packing,
    };
  }
}
