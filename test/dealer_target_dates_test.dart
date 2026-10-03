import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/collection/data/datasources/dealer_target_remote_datasource.dart';
import 'package:solufine/features/collection/data/repositories/dealer_target_repository_impl.dart';
import 'package:solufine/features/collection/domain/usecases/get_target_dates.dart';

void main() {
  test('target dates forwards the user ID into the POST form', () async {
    final client = DioClient();
    RequestOptions? request;
    final interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        request = options;
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'status': true, 'result': []},
          ),
        );
      },
    );
    client.client.interceptors.add(interceptor);
    addTearDown(() => client.client.interceptors.remove(interceptor));
    final useCase = GetTargetDates(
      repository: DealerTargetRepositoryImpl(
        remoteDataSource: DealerTargetRemoteDataSourceImpl(dioClient: client),
      ),
    );

    expect(await useCase(userId: '42'), isEmpty);
    expect(request!.method, 'POST');
    expect(request!.path, ApiClient.getTargetDates);
    expect(Map.fromEntries((request!.data as FormData).fields), {
      'userId': '42',
    });
  });
}
