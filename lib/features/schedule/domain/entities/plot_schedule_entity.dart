class PlotScheduleProductEntity {
  final String id;
  final String scheduleId;
  final String name;
  final String cropId;
  final String cropName;
  final String type;
  final String quantity;
  final String unit;
  final String waterQuantity;
  final String waterUnit;
  final String? remark;

  const PlotScheduleProductEntity({
    required this.id,
    required this.scheduleId,
    required this.name,
    required this.cropId,
    required this.cropName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.waterQuantity,
    required this.waterUnit,
    this.remark = '',
  });
}

class PlotScheduleEntity {
  final String id;
  final String plotId;
  final String date;
  final String employee;
  final String farmer;
  final String cropId;
  final String crop;
  final String plot;
  final String? remark;
  final String? status;

  final List<PlotScheduleProductEntity> products;

  const PlotScheduleEntity({
    required this.id,
    required this.plotId,
    required this.date,
    required this.employee,
    required this.farmer,
    required this.cropId,
    required this.crop,
    required this.plot,
    this.remark = '',
    this.status = '0',
    required this.products,
  });
}
