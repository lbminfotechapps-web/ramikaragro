class SubmitFollowupModel {
  final bool status;
  final String message;

  SubmitFollowupModel({required this.status, required this.message});

  factory SubmitFollowupModel.fromJson(Map<String, dynamic> json) {
    return SubmitFollowupModel(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}
