import '../../domain/entities/submit_enquiry_entity.dart';

class SubmitEnquiryResponseModel extends SubmitEnquiryEntity {
  const SubmitEnquiryResponseModel({
    required super.status,
    required super.message,
  });

  factory SubmitEnquiryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic statusValue = json['status'];

    final bool status =
        statusValue == true ||
        statusValue.toString().toLowerCase() == 'true' ||
        statusValue.toString() == '1';

    return SubmitEnquiryResponseModel(
      status: status,
      message: json['message']?.toString() ?? '',
    );
  }
}