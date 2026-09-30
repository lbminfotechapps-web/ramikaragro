import 'package:solufine/features/assign_target_point_wise/data/models/target_group_model.dart';

import '../../domain/entities/target_group_entity.dart';
import '../../domain/repositories/self_target_repository.dart';
import '../datasources/self_target_remote_datasource.dart';

class SelfTargetRepositoryImpl implements SelfTargetRepository {
  final SelfTargetRemoteDataSource remoteDataSource;

  SelfTargetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TargetGroupEntity>> getSelfTarget() {
    return remoteDataSource.getSelfTarget();
  }

  @override
  Future<String> submitSelfTarget({
    required String userId,
    required String month,
    // required String groupId,
    required String points,
  }) {
    return remoteDataSource.submitSelfTarget(
      userId: userId,
      month: month,
      //   groupId: groupId,
      points: points,
    );
  }

  @override
  Future<List<TargetGroupModel>> getGroupWiseAchivPoint({
    required String userId,
    required String targetId,
  }) {
    return remoteDataSource.getGroupWiseAchivPoint(
      userId: userId,
      targetId: targetId,
    );
  }
}
