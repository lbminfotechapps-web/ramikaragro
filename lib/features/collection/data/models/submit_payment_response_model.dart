import '../../domain/entities/submit_payment_response.dart';

class SubmitPaymentResponseModel
    extends SubmitPaymentResponse {
  const SubmitPaymentResponseModel({
    required super.status,
    required super.result,
    required super.message,
  });

  factory SubmitPaymentResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubmitPaymentResponseModel(
      status: json['status'] == true ||
          json['status']
                  ?.toString()
                  .toLowerCase() ==
              'true',
      result: json['result']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}