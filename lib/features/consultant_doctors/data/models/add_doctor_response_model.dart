
class AddDoctorResponseModel {
  final bool status;
  final String result;
  final String message;
  final String doctorId;

  const AddDoctorResponseModel({
    required this.status,
    required this.result,
    required this.message,
    required this.doctorId,
  });

  factory AddDoctorResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawStatus = json['status'];

    return AddDoctorResponseModel(
      status: rawStatus == true ||
          rawStatus == 1 ||
          rawStatus.toString().toLowerCase() == 'true',
      result: json['result']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
    );
  }

  bool get isSuccess =>
      status && result.toLowerCase() == 'success';
}
