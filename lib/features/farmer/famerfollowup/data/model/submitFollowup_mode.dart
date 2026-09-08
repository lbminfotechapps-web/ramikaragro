class SubmitFollowupModel {
  final String status;

  SubmitFollowupModel({required this.status});

  factory SubmitFollowupModel.fromJson(Map<String, dynamic> json) {
    return SubmitFollowupModel(status: json['status'].toString());
  }
}
