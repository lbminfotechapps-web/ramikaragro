import 'order_detail_entity.dart';

class OrderHistoryEntity {
  final String address;
  final String admName;
  final String empId;
  final String grandTotal;
  final String orderDate;
  final String orderId;
  final String orderNo;
  final String outletName;
  final String schemeName;
  final String reportingToId;
  final String statusReportingEmp;
  final String status;
  final String adminStatus;
  final String reportingStatus;
  final String totalCaseQty;
  final String totalQty;
  final String godownName;
  final String remark;
  final String cancelReason;
  final List<OrderDetailEntity> orderDetails;

  const OrderHistoryEntity({
    required this.address,
    required this.admName,
    required this.empId,
    required this.grandTotal,
    required this.orderDate,
    required this.orderId,
    required this.orderNo,
    required this.outletName,
    required this.schemeName,
    required this.reportingToId,
    required this.statusReportingEmp,
    required this.status,
    required this.adminStatus,
    required this.reportingStatus,
    required this.totalCaseQty,
    required this.totalQty,
    required this.godownName,
    required this.remark,
    required this.cancelReason,
    required this.orderDetails,
  });

  OrderHistoryEntity copyWith({
    String? address,
    String? admName,
    String? empId,
    String? grandTotal,
    String? orderDate,
    String? orderId,
    String? orderNo,
    String? outletName,
    String? schemeName,
    String? reportingToId,
    String? statusReportingEmp,
    String? status,
    String? adminStatus,
    String? reportingStatus,
    String? totalCaseQty,
    String? totalQty,
    String? godownName,
    String? remark,
    String? cancelReason,
    List<OrderDetailEntity>? orderDetails,
  }) {
    return OrderHistoryEntity(
      address: address ?? this.address,
      admName: admName ?? this.admName,
      empId: empId ?? this.empId,
      grandTotal: grandTotal ?? this.grandTotal,
      orderDate: orderDate ?? this.orderDate,
      orderId: orderId ?? this.orderId,
      orderNo: orderNo ?? this.orderNo,
      outletName: outletName ?? this.outletName,
      schemeName: schemeName ?? this.schemeName,
      reportingToId: reportingToId ?? this.reportingToId,
      statusReportingEmp: statusReportingEmp ?? this.statusReportingEmp,
      status: status ?? this.status,
      adminStatus: adminStatus ?? this.adminStatus,
      reportingStatus: reportingStatus ?? this.reportingStatus,
      totalCaseQty: totalCaseQty ?? this.totalCaseQty,
      totalQty: totalQty ?? this.totalQty,
      godownName: godownName ?? this.godownName,
      remark: remark ?? this.remark,
      cancelReason: cancelReason ?? this.cancelReason,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }
}
