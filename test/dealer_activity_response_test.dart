import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/marketing/other_activity_near_dealer/data/datasources/dealer_activity_remote_data_source.dart';

void main() {
  const response = {
    'status': true,
    'result': 'success-556',
    'message': 'Record Submited successfully',
  };
  test('preserves server message for decoded and text JSON responses', () {
    for (final data in [
      response,
      jsonEncode(response),
      '  ${jsonEncode(response)}  ',
    ]) {
      expect(
        DealerActivityRemoteDataSourceImpl.parseResponse(data),
        response['message'],
      );
    }
  });
  test('server failure cannot be treated as success', () {
    expect(
      () => DealerActivityRemoteDataSourceImpl.parseResponse(
        jsonEncode({'status': false, 'message': 'Submission rejected'}),
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Submission rejected'),
        ),
      ),
    );
  });
  test('rejects empty, HTML and non-object responses', () {
    for (final data in ['', '<html>Server error</html>', '[]', null]) {
      expect(
        () => DealerActivityRemoteDataSourceImpl.parseResponse(data),
        throwsFormatException,
      );
    }
  });
}
