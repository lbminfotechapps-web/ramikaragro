import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/domain/entities/add_schedule_request.dart';

void main() {
  AddScheduleDetail detail(String remark, {int day = 22}) => AddScheduleDetail(
    productName: 'Product',
    cropId: '141',
    productType: 'Spray',
    productQty: '58',
    unit: 'Ltr',
    waterQty: '120',
    waterUnit: 'Ltr',
    remark: remark,
    scheduleDate: DateTime(2026, 10, day),
  );

  Map<String, dynamic> payload(List<AddScheduleDetail> details) =>
      AddScheduleRequest(
        empId: '4',
        plotId: '9',
        farmerId: '1',
        scheduleDate: DateTime(2026, 10, 22),
        details: details,
      ).toJson();

  test('four products on 28 and three on 29 keep dates in the final JSON', () {
    final firstSection = List.generate(4, (i) => detail('first $i', day: 28));
    final secondSection = List.generate(3, (i) => detail('second $i', day: 29));
    final result = payload([...firstSection, ...secondSection]);
    final products = result['details'] as List;
    expect(products, hasLength(7));
    expect(products.where((p) => p['date'] == '2026-10-28'), hasLength(4));
    expect(products.where((p) => p['date'] == '2026-10-29'), hasLength(3));
    expect(products.take(4).map((p) => p['remark']), [
      'first 0',
      'first 1',
      'first 2',
      'first 3',
    ]);
    expect(products.skip(4).map((p) => p['remark']), [
      'second 0',
      'second 1',
      'second 2',
    ]);
  });

  test('each product keeps its own date and remark in JSON', () {
    final result = payload([
      detail(' Morning ', day: 22),
      detail(' Evening ', day: 25),
    ]);
    final details = result['details'] as List;
    expect(details[0]['date'], '2026-10-22');
    expect(details[0].containsKey('scheduleDate'), isFalse);
    expect(details[0]['remark'], 'Morning');
    expect(details[1]['date'], '2026-10-25');
    expect(details[1]['remark'], 'Evening');
    expect(result['scheduleDate'], '22-10-2026');
  });

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
