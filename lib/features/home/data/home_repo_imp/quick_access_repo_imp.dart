import 'package:demo/features/home/data/home_datasource/quick_access_datasource.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_repository/qick_access_repo.dart';

class QuickAccessRepoImp implements QickAccessRepo {
  final QuickAccessDatasource quickAccessDatasource;

  QuickAccessRepoImp(this.quickAccessDatasource);

  @override
  Future<PunchStatEntity> getPunchStatus(int userId) {
    return quickAccessDatasource.getPunchStatus(userId);
  }
}
