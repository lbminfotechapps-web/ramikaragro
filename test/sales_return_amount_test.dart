import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/salesreturn/data/models/product_rate_model.dart';

void main() {
  test('sales return amount includes units per case and the GST-inclusive rate', () {
    final rate = ProductRateModel.fromJson({
      'fld_units_per_case': '12',
      'fld_rate_with_gst': '100',
      'fld_basic_rate': '80',
    });
    expect(rate.amountForCases(3), 3600);
  });
  test('sales return totals combine quantities for different packings', () {
    final first = ProductRateModel.fromJson({
      'fld_units_per_case': '12', 'fld_rate_with_gst': '50.25',
    });
    final second = ProductRateModel.fromJson({
      'fld_units_per_case': '6', 'fld_rate_with_gst': '20',
    });
    expect(first.amountForCases(2) + second.amountForCases(3), 1566);
    expect(first.amountForCases(0), 0);
  });
}