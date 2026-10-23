import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/domain/entities/add_schedule_request.dart';

void main() {
  AddScheduleDetail detail(String remark) => AddScheduleDetail(
    productName: 'Product',
    cropId: '141',
    productType: 'Spray',
    productQty: '58',
    unit: 'Ltr',
    waterQty: '120',
    waterUnit: 'Ltr',
    remark: remark,
  );

  Map<String, dynamic> payload(List<AddScheduleDetail> details) =>
      AddScheduleRequest(
        empId: '4',
        plotId: '9',
        farmerId: '1',
        scheduleDate: DateTime(2026, 10, 22),
        details: details,
      ).toJson();

  test('retains saved product remarks for submission', () {
    final result = payload([detail('  Apply in morning  ')]);
    expect(result['remark'], 'Apply in morning');
    expect(result['scheduleDate'], '22-10-2026');
    expect(result['details'], hasLength(1));
  });

  test('keeps all product remarks and skips blank remarks', () {
    expect(
      payload([detail('First'), detail('  '), detail('Second')])['remark'],
      'First\nSecond',
    );
  });

  test('empty remarks serialize as empty text instead of null', () {
    expect(payload([detail('')])['remark'], '');
  });
}