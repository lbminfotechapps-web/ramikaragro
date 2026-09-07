import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_remote_data_source.dart';

class OrganizationRepositoryImpl
    implements OrganizationRepository {

  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Organization> getOrganizationDetails() async {
    return await remoteDataSource
        .getOrganizationDetails();
  }
}