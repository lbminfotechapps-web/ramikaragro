import '../../domain/entities/schedule_list_entity.dart';

class ScheduleProductModel extends ScheduleProductEntity {
  const ScheduleProductModel({
    required super.detailId,
    required super.scheduleId,
    required super.productName,
    required super.cropId,
    required super.cropName,
    required super.productType,
    required super.productQty,
    required super.unit,
    required super.waterQty,
    required super.waterUnit,
  });

  factory ScheduleProductModel.fromJson(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString().trim() ?? '';

    return ScheduleProductModel(
      detailId: read('fld_schedule_det_id'),
      scheduleId: read('fld_schedule_id'),
      productName: read('fld_product_name'),
      cropId: read('fld_crop_id'),
      cropName: read('fld_crop_name'),
      productType: read('fld_product_type'),
      productQty: read('fld_product_qty'),
      unit: read('fld_unit'),
      waterQty: read('fld_water_qty'),
      waterUnit: read('fld_water_unit'),
    );
  }
}

class ScheduleListModel extends ScheduleListEntity {
  const ScheduleListModel({
    super.farmerId,
    required super.scheduleId,
    required super.plotRegistrationId,
    required super.scheduleDate,
    required super.employeeName,
    required super.farmerName,
    required super.cropId,
    required super.cropName,
    required super.plotName,
    super.remark,
    super.status,
    required super.details,
  });

  factory ScheduleListModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackFarmerId = '',
  }) {
    String read(String key) => json[key]?.toString().trim() ?? '';

    final rawDetails = json['details'];
    final details = <ScheduleProductEntity>[];

    if (rawDetails is List) {
      for (final value in rawDetails) {
        if (value is Map) {
          details.add(
            ScheduleProductModel.fromJson(Map<String, dynamic>.from(value)),
          );
        }
      }
    }

    return ScheduleListModel(
      farmerId: read('fld_farmer_id').isNotEmpty
          ? read('fld_farmer_id')
          : read('farmerId').isNotEmpty
          ? read('farmerId')
          : fallbackFarmerId.trim(),
      scheduleId: read('fld_schedule_id'),
      plotRegistrationId: read('fld_plot_registration_id'),
      scheduleDate: read('fld_schedule_date'),
      employeeName: read('fld_adm_name'),
      farmerName: read('fld_farmer_name'),
      cropId: read('fld_crop_id'),
      cropName: read('fld_crop_name'),
      plotName: read('fld_plot_name'),
      remark: read('fld_remark'),
      status: read('fld_status') == '1' ? '1' : '0',
      details: List.unmodifiable(details),
    );
  }
}
