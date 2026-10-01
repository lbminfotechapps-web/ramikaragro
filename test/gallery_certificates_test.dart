import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/gallery/data/datasource/gallery_datasource.dart';
import 'package:solufine/features/gallery/data/repoimp/gallerydatasourceImp.dart';
import 'package:solufine/features/gallery/domain/usecases/GetGalleryDetails.dart';
import 'package:solufine/features/gallery/presentation/boc/gallery_bloc.dart';
import 'package:solufine/features/gallery/presentation/boc/gallery_event.dart';
import 'package:solufine/features/gallery/presentation/boc/gallery_state.dart';

void main() {
  final records =
      [
            ('1', 'VIDEO', 'https://www.youtube.com/watch?v=I8GpAR3vBeU&t=14s'),
            ('2', 'GALLERY', '1788777030.jpg'),
            ('3', 'VIDEO', 'https://youtu.be/ecnYwjNTkvs'),
            ('4', 'CERTIFICATES', '1788777131.jpg'),
            ('5', 'VIDEO', 'youtube.com/watch?v=vyfv97moSrw'),
            ('6', 'GALLERY', '1790061702.jpg'),
            ('7', 'CERTIFICATES', '1790770490.pdf'),
          ]
          .map(
            (record) => {
              'fld_gallery_id': record.$1,
              'fld_gallery_type': record.$2,
              'fld_gallery_path': record.$3,
              'fld_gallery_title': '',
              'fld_gallery_description': '',
              'fld_crop_id': '0',
            },
          )
          .toList();

  late GalleryDatasource source;
  late GalleryBloc bloc;
  late Interceptor interceptor;
  late Map<String, dynamic> responseBody;
  late List<String> requestedTypes;

  setUp(() {
    responseBody = {'status': true, 'message': '', 'result': records};
    requestedTypes = [];
    final client = DioClient();
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        requestedTypes.add(
          Map.fromEntries((options.data as FormData).fields)['type']!,
        );
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: jsonEncode(responseBody),
          ),
        );
      },
    );
    client.client.interceptors.add(interceptor);
    source = GalleryDatasource(dioClient: client);
    bloc = GalleryBloc(
      getGalleryDetails: GetGalleryDetails(
        repository: GalleryDatasourceImpl(source),
      ),
    );
  });

  tearDown(() async {
    await bloc.close();
    DioClient().client.interceptors.remove(interceptor);
  });

  for (final nested in [false, true]) {
    for (final tab in [
      ('gallery', ['2', '6']),
      ('video', ['1', '3', '5']),
      ('CERTIFICATES', ['4', '7']),
    ]) {
      test(
        '${tab.$1} filters ${nested ? 'nested' : 'flat'} response',
        () async {
          if (nested) {
            responseBody['result'] = [
              {'gallary_details': records},
            ];
          }
          final result = await source.getGalleryData(type: tab.$1);
          expect(result.map((item) => item.galleryId), tab.$2);
          expect(requestedTypes, [tab.$1]);
        },
      );
    }
  }

  for (final refresh in [false, true]) {
    test(
      'certificates ${refresh ? 'refresh' : 'load'} completes with JPG and PDF',
      () async {
        final completed = bloc.stream
            .firstWhere(
              (state) =>
                  state.status == GalleryStatus.success ||
                  state.status == GalleryStatus.failure,
            )
            .timeout(const Duration(seconds: 5));
        bloc.add(
          refresh
              ? const RefreshGalleryEvent(type: 'CERTIFICATES')
              : const GetGalleryEvent(type: 'CERTIFICATES'),
        );
        final state = await completed;
        expect(state.status, GalleryStatus.success);
        expect(state.currentType, 'CERTIFICATES');
        expect(state.certificateList.map((item) => item.galleryPath), [
          '1788777131.jpg',
          '1790770490.pdf',
        ]);
        expect(state.galleryList, isEmpty);
        expect(state.videoList, isEmpty);
      },
    );
  }

  test('empty certificate response exits loading', () async {
    responseBody['result'] = [];
    final completed = bloc.stream
        .firstWhere((state) => state.status == GalleryStatus.success)
        .timeout(const Duration(seconds: 5));
    bloc.add(const GetGalleryEvent(type: 'CERTIFICATES'));
    expect((await completed).certificateList, isEmpty);
  });

  test('certificate API failure exits loading with its error', () async {
    responseBody = {'status': false, 'message': 'Unavailable'};
    final completed = bloc.stream
        .firstWhere((state) => state.status == GalleryStatus.failure)
        .timeout(const Duration(seconds: 5));
    bloc.add(const GetGalleryEvent(type: 'CERTIFICATES'));
    expect((await completed).errorMessage, contains('Unavailable'));
  });
}
