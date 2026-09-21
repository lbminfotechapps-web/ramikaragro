import 'package:solufine/features/distpatchistory/domain/entities/dispatch_order_detail_entity.dart';

abstract class DispatchListEntity {
  final String dispatchOrderId;
  final String orderId;
  final String orderNo;
  final String lrNo;
  final String transportationName;
  final String orderDate;
  final String totalQty;
  final String totalDispatchQty;
  final String remainingDispatchQty;
  final String outletName;
  final String schemeName;
  final String status;
  final List<DispatchOrderDetailEntity> dispatchDetails;

  const DispatchListEntity({
    required this.dispatchOrderId,
    required this.orderId,
    required this.orderNo,
    required this.lrNo,
    required this.transportationName,
    required this.orderDate,
    required this.totalQty,
    required this.totalDispatchQty,
    required this.remainingDispatchQty,
    required this.outletName,
    required this.schemeName,
    required this.status,
    required this.dispatchDetails,
  });
}
