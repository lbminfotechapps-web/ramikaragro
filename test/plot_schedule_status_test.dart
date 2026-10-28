import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/plot_schedule_model.dart';

void main() {
  test('plot products use their own remarks instead of master remark', () {
    final schedule = PlotScheduleModel.fromJson({
      'fld_remark': 'Master remark',
      'details': [
        {'fld_product_name': 'Reliable Fruit', 'fld_remark': 'Product 1'},
        {'fld_product_name': 'Mealynil', 'fld_remark': 'Product 2'},
        {'fld_product_name': 'No remark', 'fld_remark': null},
      ],
    });
    expect(schedule.products.map((p) => p.remark), [
      'Product 1',
      'Product 2',
      '',
    ]);
    expect(PlotScheduleProductModel.fromJson({}).remark, '');
  });
  test('plot history maps completed and incomplete API statuses', () {
    for (final status in ['1', 1, ' 1 ']) {
      expect(PlotScheduleModel.fromJson({'fld_status': status}).status, '1');
    }
    for (final status in ['0', 0, null, '']) {
      expect(PlotScheduleModel.fromJson({'fld_status': status}).status, '0');
    }
    expect(PlotScheduleModel.fromJson({}).status, '0');
  });
}
