class ProductRateEntity {
  final String productDetailsId;
  final String qty;
  final String packing;
  final String unitId;
  final String unit;
  final String gstPercentage;
  final String basicRate;
  final String rateWithGst;
  final String mrp;
  final String unitsPerCase;
  final String statewiseDetailId;
  final String fromDate;
  final String toDate;
  final String productId;
  final String productName;
  final String orderQtyFlag;

  const ProductRateEntity({
    required this.productDetailsId,
    required this.qty,
    required this.packing,
    required this.unitId,
    required this.unit,
    required this.gstPercentage,
    required this.basicRate,
    required this.rateWithGst,
    required this.mrp,
    required this.unitsPerCase,
    required this.statewiseDetailId,
    required this.fromDate,
    required this.toDate,
    required this.productId,
    required this.productName,
    required this.orderQtyFlag,
  });

  double get price {
    return double.tryParse(rateWithGst) ?? 0;
  }

  String get displayPacking {
    if (packing.trim().isEmpty) {
      return '-';
    }

    return '$packing $unit';
  }

  String get displayRate {
    return '₹${price.toStringAsFixed(2)}';
  }

  String get displayCase {
    final value = int.tryParse(unitsPerCase);

    if (value == null || value <= 0) {
      return '-';
    }

    return '$value units/case';
  }
}