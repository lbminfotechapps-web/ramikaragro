import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/place_order/domain/entities/order_amount.dart';

void main() {
  test('case quantity multiplies units per case and unit rate', () {
    expect(calculateCaseAmount(quantity: 3, unitsPerCase: '12', rate: 100), 3600);
  });
  test('different packings contribute their own case sizes to the total', () {
    final total = calculateCaseAmount(quantity: 2, unitsPerCase: '12', rate: 50.25) +
        calculateCaseAmount(quantity: 3, unitsPerCase: '6', rate: 20);
    expect(total, 1566);
  });
  test('zero quantity contributes no amount', () {
    expect(calculateCaseAmount(quantity: 0, unitsPerCase: '12', rate: 100), 0);
  });
}