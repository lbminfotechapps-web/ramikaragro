import 'package:demo/features/reports/data/datasources/organization_remote_data_source.dart';
import 'package:demo/features/reports/data/repositories/organization_repository_impl.dart';
import 'package:demo/features/reports/domain/repositories/organization_repository.dart';
import 'package:demo/features/reports/domain/usecases/get_organization_details.dart';
import 'package:demo/features/reports/presentation/bloc/organization_bloc.dart';
import 'package:dio/dio.dart';

class OrganizationDI {

  static Dio createDio() {
    return Dio(
      BaseOptions(
        connectTimeout:
            const Duration(seconds: 30),

        receiveTimeout:
            const Duration(seconds: 30),

        sendTimeout:
            const Duration(seconds: 30),
      ),
    );
  }

  static OrganizationRemoteDataSource
      createRemoteDataSource() {

    final dio = createDio();

    return OrganizationRemoteDataSourceImpl(
      dio: dio,
    );
  }

  static OrganizationRepository
      createRepository() {

    final remoteDataSource =
        createRemoteDataSource();

    return OrganizationRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  }

  static GetOrganizationDetails
      createUseCase() {

    final repository =
        createRepository();

    return GetOrganizationDetails(
      repository: repository,
    );
  }

  static OrganizationBloc
      createBloc() {

    final useCase =
        createUseCase();

    return OrganizationBloc(
      getOrganizationDetails: useCase,
    );
  }
}