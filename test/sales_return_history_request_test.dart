import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/salesreturnhistory/data/datasource/sales_return_history_remote_datasource.dart';
import 'package:solufine/features/salesreturnhistory/data/repoimp/sales_return_history_repository_impl.dart';

void main() {
  test('same-day history request matches working Postman fields', () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'POST');
          expect(options.path, '/getSalesReturnDetails');
          expect(Map.fromEntries((options.data as FormData).fields), {
            'userId': '4',
            'outletId': '',
            'fromDate': '05-10-2026',
            'toDate': '05-10-2026',
            'startLimit': '0',
            'status': '',
          });
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: jsonEncode({'status': true, 'result': []}),
            ),
          );
        },
      ),
    );
    final repository = SalesReturnHistoryRepositoryImpl(
      datasource: SalesReturnHistoryRemoteDatasource(dio: dio),
    );
    await repository.getSalesReturnHistory(
      userId: '4',
      outletId: '',
      fromDate: '05-10-2026',
      toDate: '05-10-2026',
      startLimit: '0',
      status: '',
    );
  });
}
