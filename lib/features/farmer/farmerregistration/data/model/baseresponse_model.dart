class BaseResponseModel {
  final bool status;
  final bool response;
  final List<dynamic> result;
  final String message;

  BaseResponseModel({
    required this.status,
    required this.response,
    required this.result,
    required this.message,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      status: json['status'] ?? false,
      response: json['response'] ?? false,
      result: json['result'] ?? [],
      message: json['message'] ?? '',
    );
  }
}
