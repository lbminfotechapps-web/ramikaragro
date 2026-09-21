import 'package:solufine/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:solufine/features/farmer/farmerlist/data/model/farmerlist_model.dart';

abstract class FarmerListRepository {
  Future<List<FarmerlistModel>> getFarmers(
    int userId,

    int limit,
    String searchKey,
  );
}
