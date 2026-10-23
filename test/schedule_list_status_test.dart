import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/schedule_list_model.dart';

void main() {
  test('schedules with no status remain safe and incomplete', () {
    const schedule = ScheduleListModel(
      scheduleId: '9',
      plotRegistrationId: '9',
      scheduleDate: '22-10-2026',
      employeeName: '',
      farmerName: '',
      cropId: '',
      cropName: '',
      plotName: '',
      status: null,
      details: [],
    );
    expect(schedule.status == '1', isFalse);
  });

  test('schedule status supports string and numeric API values', () {
    for (final value in ['1', 1, ' 1 ']) {
      expect(ScheduleListModel.fromJson({'fld_status': value}).status, '1');
    }
    for (final value in ['0', 0, null, '']) {
      expect(ScheduleListModel.fromJson({'fld_status': value}).status, '0');
    }
    expect(ScheduleListModel.fromJson({}).status, '0');
  });
}
