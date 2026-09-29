import '../entities/target_group_entity.dart';

import '../repositories/self_target_repository.dart';

class GetSelfTarget {
  final SelfTargetRepository
      repository;

  GetSelfTarget({
    required this.repository,
  });

  Future<List<TargetGroupEntity>>
      call() {
    return repository
        .getSelfTarget();
  }
}