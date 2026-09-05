import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';

abstract class QickAccessRepo {
  Future<PunchStatEntity> getPunchStatus(int userId);
}
