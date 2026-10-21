
import '../entities/add_schedule_request.dart';

abstract class AddScheduleRepository {
  Future<AddScheduleResult> submit(
    AddScheduleRequest request,
  );
}
