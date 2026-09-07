import '../../domain/entities/organization.dart';

abstract class OrganizationState {}

class OrganizationInitial
    extends OrganizationState {}

class OrganizationLoading
    extends OrganizationState {}

class OrganizationLoaded
    extends OrganizationState {

  final Organization organization;

  OrganizationLoaded({
    required this.organization,
  });
}

class OrganizationError
    extends OrganizationState {

  final String message;

  OrganizationError({
    required this.message,
  });
}