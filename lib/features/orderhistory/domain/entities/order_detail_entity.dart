class OrderDetailEntity {
  final String detailsId;
  final String orderId;
  final String packing;
  final String productAmt;
  final String productId;
  final String productName;
  final String productPath;
  final String productQty;
  final String totalCaseQuantity;
  final String casewiseOrQtyFlag;
  final String pendingQty;
  final String dispatchQty;

  const OrderDetailEntity({
    required this.detailsId,
    required this.orderId,
    required this.packing,
    required this.productAmt,
    required this.productId,
    required this.productName,
    required this.productPath,
    required this.productQty,
    required this.totalCaseQuantity,
    required this.casewiseOrQtyFlag,
    required this.pendingQty,
    required this.dispatchQty,
  });
}
