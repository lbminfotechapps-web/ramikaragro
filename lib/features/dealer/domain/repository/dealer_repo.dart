import 'package:demo/features/auth/domain/entity/login_entity.dart';
import 'package:demo/features/dealer/data/models/DealerListModel.dart';

abstract class DealerListRepository {
  Future<List<DealerListModel>> getDealers(
    String user_id,
    String lattitude,
    String logitude,
    String limit,
    String searchKey,
  );
}