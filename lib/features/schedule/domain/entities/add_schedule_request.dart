
class AddScheduleDetail {
  final String productName;
  final String cropId;
  final String productType;
  final String productQty;
  final String unit;
  final String waterQty;
  final String waterUnit;

  const AddScheduleDetail({
    required this.productName,
    required this.cropId,
    required this.productType,
    required this.productQty,
    required this.unit,
    required this.waterQty,
    required this.waterUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'productName': productName.trim(),
      'cropId': cropId.trim(),
      'productType': productType.trim(),
      'productQty': productQty.trim(),
      'unit': unit.trim(),
      'waterQty': waterQty.trim(),
      'waterUnit': waterUnit.trim(),
    };
  }
}

class AddScheduleRequest {
  final String empId;
  final String plotId;
  final String farmerId;
  final DateTime scheduleDate;
  final List<AddScheduleDetail> details;

  const AddScheduleRequest({
    required this.empId,
    required this.plotId,
    required this.farmerId,
    required this.scheduleDate,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    final day = scheduleDate.day.toString().padLeft(2, '0');
    final month = scheduleDate.month.toString().padLeft(2, '0');

    return {
      'empId': empId.trim(),
      'plotId': plotId.trim(),
      'farmerId': farmerId.trim(),
      'scheduleDate': '$day-$month-${scheduleDate.year}',
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class AddScheduleResult {
  final bool status;
  final String message;
  final Map<String, dynamic> rawResponse;

  const AddScheduleResult({
    required this.status,
    required this.message,
    required this.rawResponse,
  });
}
