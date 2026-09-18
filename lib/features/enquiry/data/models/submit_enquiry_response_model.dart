import '../../domain/entities/submit_enquiry_entity.dart';

class SubmitEnquiryResponseModel extends SubmitEnquiryEntity {
  const SubmitEnquiryResponseModel({
    required super.status,
    required super.message,
  });

  factory SubmitEnquiryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubmitEnquiryResponseModel(
      status: json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true' ||
          json['status']?.toString() == '1',
      message: json['message']?.toString() ?? '',
    );
  }
}