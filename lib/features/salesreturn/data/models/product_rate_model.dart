import '../../domain/entities/product_rate_entity.dart';

class ProductRateModel extends ProductRateEntity {
  const ProductRateModel({
    required super.productDetailsId,
    required super.qty,
    required super.packing,
    required super.unitId,
    required super.unit,
    required super.gstPercentage,
    required super.basicRate,
    required super.rateWithGst,
    required super.mrp,
    required super.unitsPerCase,
    required super.statewiseDetailId,
    required super.fromDate,
    required super.toDate,
    required super.productId,
    required super.productName,
    required super.orderQtyFlag,
  });

  factory ProductRateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductRateModel(
      productDetailsId:
          json['fld_product_details_id']?.toString() ?? '',
      qty: json['fld_qty']?.toString() ?? '',
      packing: json['fld_packing']?.toString() ?? '',
      unitId: json['fld_unit_id']?.toString() ?? '',
      unit: json['fld_unit']?.toString() ?? '',
      gstPercentage:
          json['fld_gst_per']?.toString() ?? '',
      basicRate:
          json['fld_basic_rate']?.toString() ?? '',
      rateWithGst:
          json['fld_rate_with_gst']?.toString() ?? '',
      mrp: json['fld_mrp']?.toString() ?? '',
      unitsPerCase:
          json['fld_units_per_case']?.toString() ?? '',
      statewiseDetailId:
          json['fld_statewise_det_id']?.toString() ?? '',
      fromDate:
          json['fld_from_date']?.toString() ?? '',
      toDate:
          json['fld_to_date']?.toString() ?? '',
      productId:
          json['fld_product_id']?.toString() ?? '',
      productName:
          json['fld_product_name']?.toString() ?? '',
      orderQtyFlag:
          json['fld_order_qty_flag']?.toString() ?? '',
    );
  }
}