import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/plot_schedule_model.dart';

void main() {
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
