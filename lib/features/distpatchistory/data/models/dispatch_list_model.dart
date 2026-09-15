import '../../domain/entities/dispatch_list_entity.dart';
import 'dispatch_order_detail_model.dart';

class DispatchListModel extends DispatchListEntity {
  const DispatchListModel({
    required super.dispatchOrderId,
    required super.orderId,
    required super.orderNo,
    required super.lrNo,
    required super.transportationName,
    required super.orderDate,
    required super.totalQty,
    required super.totalDispatchQty,
    required super.remainingDispatchQty,
    required super.outletName,
    required super.schemeName,
    required super.status,
    required super.dispatchDetails,
  });

  factory DispatchListModel.fromJson(Map<String, dynamic> json) {
    final details = <DispatchOrderDetailModel>[];

    final detailsJson = json['dispatchDetails'];

    if (detailsJson is List) {
      for (final item in detailsJson) {
        if (item is Map) {
          details.add(
            DispatchOrderDetailModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return DispatchListModel(
      dispatchOrderId: json['fld_dispatch_order_id']?.toString() ?? '',
      orderId: json['fld_order_id']?.toString() ?? '',
      orderNo: json['fld_order_no']?.toString() ?? '',
      lrNo: json['fld_lr_no']?.toString() ?? '',
      transportationName: json['fld_transportation_name']?.toString() ?? '',
      orderDate: json['fld_order_date']?.toString() ?? '',
      totalQty: json['fld_total_qty']?.toString() ?? '',
      totalDispatchQty: json['fld_total_dispatch_qty']?.toString() ?? '',
      remainingDispatchQty:
          json['fld_remaining_dispatch_qty']?.toString() ?? '',
      outletName: json['fld_outlet_name']?.toString() ?? '',
      schemeName: json['fld_scheme_name']?.toString() ?? '',
      status: json['fld_status']?.toString() ?? '',
      dispatchDetails: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_dispatch_order_id': dispatchOrderId,
      'fld_order_id': orderId,
      'fld_order_no': orderNo,
      'fld_lr_no': lrNo,
      'fld_transportation_name': transportationName,
      'fld_order_date': orderDate,
      'fld_total_qty': totalQty,
      'fld_total_dispatch_qty': totalDispatchQty,
      'fld_remaining_dispatch_qty': remainingDispatchQty,
      'fld_outlet_name': outletName,
      'fld_scheme_name': schemeName,
      'fld_status': status,

      'dispatchDetails': dispatchDetails.map((item) {
        return {
          'fld_details_id': item.detailsId,
          'fld_order_id': item.orderId,
          'fld_product_name': item.productName,
          'fld_product_qty': item.productQty,
          'fld_actual_dispatch_qty': item.actualDispatchQty,
          'fld_remaining_dispatch_qty': item.remainingDispatchQty,
          'fld_remark': item.remark,
          'fld_packing': item.packing,
        };
      }).toList(),
    };
  }
}
