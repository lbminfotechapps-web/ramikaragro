import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/quickchartreport/data/repositories/gallery_remotedata_source_Impl.dart';

void main() {
  final body = {
    'status': true,
    'message': 'Success',
    'result': [
      {
        'gallery_id': '1',
        'title': 'Quick chart',
        'date': '07-10-2026',
        'data': [
          {'language_id': '1', 'language': 'English', 'file': 'chart.pdf'},
        ],
      },
    ],
  };
  for (final asText in [true, false]) {
    test(
      'parses quick reference from ${asText ? "JSON text" : "map"}',
      () async {
        final client = DioClient();
        final interceptor = InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/get_quick_refrence_chart');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: asText ? jsonEncode(body) : body,
              ),
            );
          },
        );
        client.client.interceptors.add(interceptor);
        addTearDown(() => client.client.interceptors.remove(interceptor));
        final response = await GalleryRemoteDataSourceImpl(
          dioClient: client,
        ).getGallery();
        expect(response.status, isTrue);
        expect(response.result.single.title, 'Quick chart');
        expect(response.result.single.data.single.file, 'chart.pdf');
      },
    );
  }
}
