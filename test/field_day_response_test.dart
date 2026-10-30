import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/marketing/field_day_visit/data/datasources/field_day_data_source.dart';

void main() {
  test('accepts decoded and text JSON with success status variants', () {
    for (final status in [true, 1, '1', ' true ']) {
      final body = {'status': status, 'message': 'Field Day saved'};
      for (final data in [
        body,
        jsonEncode(body),
        '\uFEFF${jsonEncode(body)}',
      ]) {
        expect(FieldDayDataSource.parseResponse(data), 'Field Day saved');
      }
    }
  });

  test('preserves server failure message', () {
    expect(
      () => FieldDayDataSource.parseResponse(
        '{"status":false,"message":"Farmer is required"}',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Farmer is required',
        ),
      ),
    );
  });

  test('rejects empty, HTML and non-object responses', () {
    for (final data in ['', '<html>Server error</html>', '[]', null]) {
      expect(
        () => FieldDayDataSource.parseResponse(data),
        throwsFormatException,
      );
    }
  });
}
