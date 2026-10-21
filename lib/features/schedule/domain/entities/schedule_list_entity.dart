class ScheduleProductEntity {
  final String detailId;
  final String scheduleId;
  final String productName;
  final String cropId;
  final String cropName;
  final String productType;
  final String productQty;
  final String unit;
  final String waterQty;
  final String waterUnit;

  const ScheduleProductEntity({
    required this.detailId,
    required this.scheduleId,
    required this.productName,
    required this.cropId,
    required this.cropName,
    required this.productType,
    required this.productQty,
    required this.unit,
    required this.waterQty,
    required this.waterUnit,
  });
}

class ScheduleListEntity {
  final String scheduleId;
  final String plotRegistrationId;
  final String scheduleDate;
  final String employeeName;
  final String farmerName;
  final String cropId;
  final String cropName;
  final String plotName;
  final List<ScheduleProductEntity> details;

  const ScheduleListEntity({
    required this.scheduleId,
    required this.plotRegistrationId,
    required this.scheduleDate,
    required this.employeeName,
    required this.farmerName,
    required this.cropId,
    required this.cropName,
    required this.plotName,
    required this.details,
  });
}

class ScheduleListFilter {
  final String empId;
  final String farmerId;
  final DateTime fromDate;
  final DateTime toDate;

  const ScheduleListFilter({
    required this.empId,
    this.farmerId = '',
    required this.fromDate,
    required this.toDate,
  });

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  Map<String, String> toPostData() => {
    'empId': empId.trim(),
    if (farmerId.trim().isNotEmpty) 'farmerId': farmerId.trim(),
    'fromDate': formatDate(fromDate),
    'toDate': formatDate(toDate),
  };
}
