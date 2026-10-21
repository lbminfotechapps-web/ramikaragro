
import '../../domain/entities/add_schedule_request.dart';

class AddScheduleModel {
  static Map<String, dynamic> encode(
    AddScheduleRequest request,
  ) {
    return request.toJson();
  }

  static AddScheduleResult parse(
    Map<String, dynamic> json,
  ) {
    final value = json['status'];

    final success = value == true ||
        value == 1 ||
        value.toString().toLowerCase() == 'true' ||
        value.toString() == '1';

    return AddScheduleResult(
      status: success,
      message: json['message']?.toString() ??
          (success
              ? 'Schedule submitted successfully'
              : 'Unable to submit schedule'),
      rawResponse: json,
    );
  }
}
