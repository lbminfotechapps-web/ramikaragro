import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/schedule_list_model.dart';

void main() {
  test('product dates and remarks come from details, not the master', () {
    final schedule = ScheduleListModel.fromJson({
      'fld_remark': 'master remark',
      'fld_schedule_date': '29-10-2026',
      'details': [
        {'fld_remark': ' p1 ', 'fld_schedule_date': '2026-10-28'},
        {'fld_remark': 'p2', 'fld_schedule_date': '2026-10-31'},
      ],
    });
    expect(schedule.details[0].remark, 'p1');
    expect(schedule.details[0].scheduleDate, '2026-10-28');
    expect(schedule.details[1].remark, 'p2');
    expect(schedule.details[1].scheduleDate, '2026-10-31');
    expect(ScheduleProductModel.fromJson({}).remark, '');
    expect(
      ScheduleProductModel.fromJson({'fld_schedule_date': null}).scheduleDate,
      '',
    );
  });

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
