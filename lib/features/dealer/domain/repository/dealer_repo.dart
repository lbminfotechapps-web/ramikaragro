import 'dart:io';

import 'package:solufine/features/dealer/data/models/dealer_products.dart';
import 'package:solufine/features/dealer/data/models/DealerListModel.dart';

abstract class DealerListRepository {
  Future<List<DealerListModel>> getDealers(
    String user_id,
    String lattitude,
    String logitude,
    String searchKey,
    String type,
    int startLimit,
  );

  Future<List<DealerStockProductModel>> getDealerProduct(String dealerId);

  Future<Map<String, dynamic>> addDealerLocation(Map<String, dynamic> jsonData);

 Future<Map<String, dynamic>> addDealerStock(
  Map<String, dynamic> jsonData,
  File? dealerImage,
  String? digitalSignature,
);
}
