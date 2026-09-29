import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/selfcollectionassign/data/datasource/monthly_collection_remote_datasource.dart';

void main() {
  final targets = [
    {'fld_outlet_id': '42', 'fld_collection_type_id': '3', 'target': 1200.0},
  ];

  for (final asText in [true, false]) {
    test('posts fields and parses ${asText ? 'text' : 'map'} response', () async {
      final dio = Dio();
      addTearDown(dio.close);
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        expect(options.method, 'POST');
        expect(options.path, '/add_monthly_collection');
        final fields = Map.fromEntries((options.data as FormData).fields);
        expect(fields.keys, unorderedEquals(['user_id', 'month_year', 'targets']));
        expect(fields['user_id'], '7');
        expect(fields['month_year'], '10-2026');
        expect(jsonDecode(fields['targets']!), targets);
        final body = {
          'result': [],
          'status': true,
          'message': 'Record Submit Success',
        };
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: asText ? jsonEncode(body) : body,
        ));
      }));
      expect(await MonthlyCollectionRemoteDataSource(dio: dio).submit(
        userId: 7, monthYear: '10-2026', targets: targets,
      ), 'Record Submit Success');
    });
  }

  for (final body in [
    '{"status":false,"message":"Rejected"}',
    '<html>Unavailable</html>',
  ]) {
    test('rejects unsuccessful or malformed response: $body', () async {
      final dio = Dio();
      addTearDown(dio.close);
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options, statusCode: 200, data: body,
        ));
      }));
      await expectLater(MonthlyCollectionRemoteDataSource(dio: dio).submit(
        userId: 7, monthYear: '10-2026', targets: targets,
      ), throwsA(isA<Exception>().having(
        (e) => e.toString(), 'message',
        contains(body.startsWith('{') ? 'Rejected' : 'Invalid response'),
      )));
    });
  }
}
