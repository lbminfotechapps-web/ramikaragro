class DealerStockProductModel {
  final String productDetailsId;
  final String qty;
  final String packing;
  final String unitId;
  final String unit;
  final String rateWithGst;
  final String unitsPerCase;
  final String statewiseDetId;
  final String productId;
  final String productName;
  final String orderQtyFlag;

  const DealerStockProductModel({
    required this.productDetailsId,
    required this.qty,
    required this.packing,
    required this.unitId,
    required this.unit,
    required this.rateWithGst,
    required this.unitsPerCase,
    required this.statewiseDetId,
    required this.productId,
    required this.productName,
    required this.orderQtyFlag,
  });

  factory DealerStockProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerStockProductModel(
      productDetailsId:
          json['fld_product_details_id']?.toString() ?? '',
      qty:
          json['fld_qty']?.toString() ?? '',
      packing:
          json['fld_packing']?.toString() ?? '',
      unitId:
          json['fld_unit_id']?.toString() ?? '',
      unit:
          json['fld_unit']?.toString() ?? '',
      rateWithGst:
          json['fld_rate_with_gst']?.toString() ?? '',
      unitsPerCase:
          json['fld_units_per_case']?.toString() ?? '',
      statewiseDetId:
          json['fld_statewise_det_id']?.toString() ?? '',
      productId:
          json['fld_product_id']?.toString() ?? '',
      productName:
          json['fld_product_name']?.toString() ?? '',
      orderQtyFlag:
          json['fld_order_qty_flag']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_product_details_id': productDetailsId,
      'fld_qty': qty,
      'fld_packing': packing,
      'fld_unit_id': unitId,
      'fld_unit': unit,
      'fld_rate_with_gst': rateWithGst,
      'fld_units_per_case': unitsPerCase,
      'fld_statewise_det_id': statewiseDetId,
      'fld_product_id': productId,
      'fld_product_name': productName,
      'fld_order_qty_flag': orderQtyFlag,
    };
  }
}