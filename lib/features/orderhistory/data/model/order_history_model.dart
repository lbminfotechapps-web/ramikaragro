import 'package:solufine/features/orderhistory/data/model/order_detail_model.dart';
import 'package:solufine/features/orderhistory/domain/entities/order_history_entity.dart';

class OrderHistoryModel extends OrderHistoryEntity {
  const OrderHistoryModel({
    required super.address,
    required super.admName,
    required super.empId,
    required super.grandTotal,
    required super.orderDate,
    required super.orderId,
    required super.orderNo,
    required super.outletName,
    required super.schemeName,
    required super.reportingToId,
    required super.statusReportingEmp,
    required super.status,
    required super.adminStatus,
    required super.reportingStatus,
    required super.totalCaseQty,
    required super.totalQty,
    required super.godownName,
    required super.remark,
    required super.cancelReason,
    required super.orderDetails,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['orderDetails'];

    final List<OrderDetailModel> details = [];

    if (detailsJson is List) {
      for (final item in detailsJson) {
        if (item is Map<String, dynamic>) {
          details.add(OrderDetailModel.fromJson(item));
        } else if (item is Map) {
          details.add(
            OrderDetailModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return OrderHistoryModel(
      address: json['fld_address']?.toString() ?? '',
      admName: json['fld_adm_name']?.toString() ?? '',
      empId: json['fld_emp_id']?.toString() ?? '',
      grandTotal: json['fld_grand_total']?.toString() ?? '',
      orderDate: json['fld_order_date']?.toString() ?? '',
      orderId: json['fld_order_id']?.toString() ?? '',
      orderNo: json['fld_order_no']?.toString() ?? '',
      outletName: json['fld_outlet_name']?.toString() ?? '',
      schemeName: json['fld_scheme_name']?.toString() ?? '',
      reportingToId: json['fld_reporting_to_id']?.toString() ?? '',
      statusReportingEmp: json['fld_status_reporting_emp']?.toString() ?? '',
      status: json['fld_status']?.toString() ?? '',
      adminStatus: json['admin_status']?.toString() ?? '',
      reportingStatus: json['reporting_status']?.toString() ?? '',
      totalCaseQty: json['fld_total_case_qty']?.toString() ?? '',
      totalQty: json['fld_total_qty']?.toString() ?? '',
      godownName: json['fld_godown_name']?.toString() ?? '',
      remark: json['fld_remark']?.toString() ?? '',
      cancelReason: json['fld_cancel_reason']?.toString() ?? '',
      orderDetails: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_address': address,
      'fld_adm_name': admName,
      'fld_emp_id': empId,
      'fld_grand_total': grandTotal,
      'fld_order_date': orderDate,
      'fld_order_id': orderId,
      'fld_order_no': orderNo,
      'fld_outlet_name': outletName,
      'fld_scheme_name': schemeName,
      'fld_reporting_to_id': reportingToId,
      'fld_status_reporting_emp': statusReportingEmp,
      'fld_status': status,
      'admin_status': adminStatus,
      'reporting_status': reportingStatus,
      'fld_total_case_qty': totalCaseQty,
      'fld_total_qty': totalQty,
      'fld_godown_name': godownName,
      'fld_remark': remark,
      'fld_cancel_reason': cancelReason,
      'orderDetails': orderDetails
          .map(
            (item) => OrderDetailModel(
              detailsId: item.detailsId,
              orderId: item.orderId,
              packing: item.packing,
              productAmt: item.productAmt,
              productId: item.productId,
              productName: item.productName,
              productPath: item.productPath,
              productQty: item.productQty,
              totalCaseQuantity: item.totalCaseQuantity,
              casewiseOrQtyFlag: item.casewiseOrQtyFlag,
              pendingQty: item.pendingQty,
              dispatchQty: item.dispatchQty,
            ).toJson(),
          )
          .toList(),
    };
  }
}
