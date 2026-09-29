import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/selfcollectionassign/data/datasource/dealer_remote_datasource.dart';

void main() {
  final payload = {
    'result': [
      {
        'fld_outlet_id': '3',
        'fld_outlet_name': 'amazon',
        'fld_outletper_mobile': '8223654122',
      },
    ],
    'status': true,
    'message': 'RECORD_FOUND',
  };

  for (final asText in [false, true]) {
    test('parses dealer response as ${asText ? 'text' : 'map'}', () async {
      final dio = Dio();
      addTearDown(() => dio.close());
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        expect(options.data, isA<FormData>());
        expect(Map.fromEntries((options.data as FormData).fields), {
          'user_id': '1',
          'searchText': '',
          'startLimit': '0',
        });
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: asText ? jsonEncode(payload) : payload,
        ));
      }));

      final result = await DealerRemoteDataSourceImpl(dio: dio)
          .getDealerList(userId: 1);

      expect(result.status, isTrue);
      expect(result.message, 'RECORD_FOUND');
      expect(result.dealers.single.outletId, '3');
      expect(result.dealers.single.outletName, 'amazon');
      expect(result.dealers.single.outletMobile, '8223654122');
    });
  }

  test('reports HTML returned with HTTP 200 as an invalid response', () async {
    final dio = Dio();
    addTearDown(() => dio.close());
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: "\n<div style='border'>Server error</div>",
      ));
    }));

    await expectLater(
      DealerRemoteDataSourceImpl(dio: dio).getDealerList(userId: 1),
      throwsA(isA<Exception>().having(
        (error) => error.toString(),
        'message',
        contains('dealer service returned an invalid response'),
      )),
    );
  });

  for (final body in ['{"message":"Access denied"}', 'Server unavailable']) {
    test('handles error body: $body', () async {
      final dio = Dio();
      addTearDown(() => dio.close());
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.reject(DioException(
          requestOptions: options,
          message: 'Request failed',
          response: Response(requestOptions: options, statusCode: 500, data: body),
        ));
      }));

      await expectLater(
        DealerRemoteDataSourceImpl(dio: dio).getDealerList(userId: 1),
        throwsA(isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains(body.startsWith('{') ? 'Access denied' : 'Request failed'),
        )),
      );
    });
  }
}
