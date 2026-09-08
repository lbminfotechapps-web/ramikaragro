import '../entities/organization.dart';

abstract class OrganizationRepository {
  Future<Organization> getOrganizationDetails();
}