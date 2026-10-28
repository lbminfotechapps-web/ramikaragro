import '../../domain/entities/plot_schedule_entity.dart';

String _s(Map<String, dynamic> json, String key) {
  return (json[key] ?? '').toString();
}

class PlotScheduleProductModel extends PlotScheduleProductEntity {
  const PlotScheduleProductModel({
    required super.id,
    required super.scheduleId,
    required super.name,
    required super.cropId,
    required super.cropName,
    required super.type,
    required super.quantity,
    required super.unit,
    required super.waterQuantity,
    required super.waterUnit,
    super.remark,
  });

  factory PlotScheduleProductModel.fromJson(Map<String, dynamic> json) {
    return PlotScheduleProductModel(
      id: _s(json, 'fld_schedule_det_id'),
      scheduleId: _s(json, 'fld_schedule_id'),
      name: _s(json, 'fld_product_name'),
      cropId: _s(json, 'fld_crop_id'),
      cropName: _s(json, 'fld_crop_name'),
      type: _s(json, 'fld_product_type'),
      quantity: _s(json, 'fld_product_qty'),
      unit: _s(json, 'fld_unit'),
      waterQuantity: _s(json, 'fld_water_qty'),
      waterUnit: _s(json, 'fld_water_unit'),
      remark: _s(json, 'fld_remark').trim(),
    );
  }
}

class PlotScheduleModel extends PlotScheduleEntity {
  const PlotScheduleModel({
    required super.id,
    required super.plotId,
    required super.date,
    required super.employee,
    required super.farmer,
    required super.cropId,
    required super.crop,
    required super.plot,
    super.remark,
    super.status,
    required super.products,
  });

  factory PlotScheduleModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'];

    final products = details is List
        ? details
              .whereType<Map>()
              .map(
                (item) => PlotScheduleProductModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <PlotScheduleProductModel>[];

    return PlotScheduleModel(
      id: _s(json, 'fld_schedule_id'),
      plotId: _s(json, 'fld_plot_registration_id'),
      date: _s(json, 'fld_schedule_date'),
      employee: _s(json, 'fld_adm_name'),
      farmer: _s(json, 'fld_farmer_name'),
      cropId: _s(json, 'fld_crop_id'),
      crop: _s(json, 'fld_crop_name'),
      plot: _s(json, 'fld_plot_name'),
      remark: _s(json, 'fld_remark').trim(),
      status: _s(json, 'fld_status').trim() == '1' ? '1' : '0',
      products: products,
    );
  }
}
