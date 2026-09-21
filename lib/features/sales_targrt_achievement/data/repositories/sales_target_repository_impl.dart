
import 'package:solufine/features/sales_targrt_achievement/data/datasources/sales_target_remote_datasource.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/entities/sales_target_entity.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/entities/target_date_entity.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/repositories/sales_target_repository.dart';

class SalesTargetRepositoryImpl
    implements SalesTargetRepository {
  final SalesTargetRemoteDataSource remoteDataSource;

  SalesTargetRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SalesTargetDateEntity>> getTargetDates() {
    return remoteDataSource.getTargetDates();
  }

  @override
  Future<SalesTargetEntity?>
      getSalesWiseTarget({
    required String userId,
    required String targetId,
  }) {
    return remoteDataSource.getSalesWiseTarget(
      userId: userId,
      targetId: targetId,
    );
  }
}


