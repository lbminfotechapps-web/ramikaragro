import 'package:solufine/features/auth/domain/entity/login_entity.dart';
import 'package:solufine/features/dealer/data/models/DealerListModel.dart';

abstract class DealerListRepository {
  Future<List<DealerListModel>> getDealers(
    String user_id,
    String lattitude,
    String logitude,
    String limit,
    String searchKey,
  );


   Future<Map<String, dynamic>> addDealerLocation(
    Map<String, dynamic> jsonData,
  );

}