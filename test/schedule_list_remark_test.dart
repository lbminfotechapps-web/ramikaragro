import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/schedule_list_model.dart';

void main() {
  test('schedule remarks handle null, missing, and populated API values', () {
    expect(ScheduleListModel.fromJson({}).remark, '');
    expect(ScheduleListModel.fromJson({'fld_remark': null}).remark, '');
    expect(
      ScheduleListModel.fromJson({'fld_remark': ' testing schedule '}).remark,
      'testing schedule',
    );
  });

  test('null remarks on existing schedules are safe to display', () {
    const schedule = ScheduleListModel(
      scheduleId: '9',
      plotRegistrationId: '9',
      scheduleDate: '22-10-2026',
      employeeName: '',
      farmerName: '',
      cropId: '141',
      cropName: '',
      plotName: '',
      remark: null,
      details: [],
    );
    expect(schedule.remark?.trim() ?? '', isEmpty);
  });
}