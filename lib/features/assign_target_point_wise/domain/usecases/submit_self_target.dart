import '../repositories/self_target_repository.dart';

class SubmitSelfTarget {
  final SelfTargetRepository repository;

  SubmitSelfTarget({
    required this.repository,
  });

  Future<String> call({
    required String userId,
    required String month,
   // required String groupId,
    required String points,
  }) {
    return repository.submitSelfTarget(
      userId: userId,
      month: month,
     // groupId: groupId,
      points: points,
    );
  }
}