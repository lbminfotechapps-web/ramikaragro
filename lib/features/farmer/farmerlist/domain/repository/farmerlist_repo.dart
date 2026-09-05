import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';

abstract class FarmerListRepository {
  Future<List<FarmerlistModel>> getFarmers(
    int userId,
    String lattitude,
    String logitude,
    int limit,
    String searchKey,
  );
}
