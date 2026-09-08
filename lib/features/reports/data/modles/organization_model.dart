import '../../domain/entities/organization.dart';

class OrganizationModel extends Organization {
  const OrganizationModel({
    required super.organizationName,
    required super.organizationAddress,
    required super.organizationEmail,
    required super.organizationContact,
    required super.organizationLat,
    required super.organizationLang,
    required super.organizationHome,
    required super.organizationAboutUs,
    required super.organizationContactUs,
    required super.organizationUserGuideLine,
  });

  factory OrganizationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizationModel(
      organizationName:
          json['organizationName']?.toString() ?? '',

      organizationAddress:
          json['organizationAddress']?.toString() ?? '',

      organizationEmail:
          json['organizationEmail']?.toString() ?? '',

      organizationContact:
          json['organizationContact']?.toString() ?? '',

      organizationLat:
          json['organizationLat']?.toString() ?? '',

      organizationLang:
          json['organizationLang']?.toString() ?? '',

      organizationHome:
          json['organizationHome']?.toString() ?? '',

      organizationAboutUs:
          json['organizationAboutUs']?.toString() ?? '',

      organizationContactUs:
          json['organizationContactUs']?.toString() ?? '',

      organizationUserGuideLine:
          json['organizationUserGuideLine']?.toString() ?? '',
    );
  }
}