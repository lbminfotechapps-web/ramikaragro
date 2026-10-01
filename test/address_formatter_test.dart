import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/utility/address_formatter.dart';

void main() {
  test('removes repeated geocoder fields from the reported address', () {
    expect(
      formatAddressParts([
        '892/71',
        '892/71, Kanifnath Nagar, Wadala Parisar, Pathardi, Nashik, Maharashtra 422009, India',
        'Pathardi',
        'Nashik',
        'Maharashtra',
        '422009',
        'India',
      ]),
      '892/71, Kanifnath Nagar, Wadala Parisar, Pathardi, Nashik, Maharashtra 422009, India',
    );
  });

  test('ignores case and whitespace without removing distinct place names', () {
    expect(
      formatAddressParts([' Nashik ', 'nashik', '', 'Ahmednagar', 'Nagar']),
      'Nashik, Ahmednagar, Nagar',
    );
  });

  test('handles empty geocoder fields', () {
    expect(formatAddressParts(['', '  ', ',']), '');
  });
}
