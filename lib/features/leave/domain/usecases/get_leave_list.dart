import '../entities/leave.dart';
import '../repositories/leave_repository.dart';

class GetLeaveList {
  final LeaveRepository repository;

  GetLeaveList(this.repository);

  Future<List<Leave>> call({
    required String userId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getLeaveList(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}