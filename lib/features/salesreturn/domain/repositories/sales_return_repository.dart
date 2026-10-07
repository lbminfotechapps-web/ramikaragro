import '../entities/category_entity.dart';
import '../entities/dealer_entity.dart';
import '../entities/godown_entity.dart';
import '../entities/product_entity.dart';

abstract class SalesReturnRepository {


  Future<List<DealerEntity>> getDealers({
    required int userId,
    required String searchText,
  });


  Future<List<GodownEntity>> getGodowns({
    required int userId,
  });


  Future<List<CategoryEntity>> getCategories();


  Future<List<ProductEntity>> getProducts({
    required String categoryId,
    required String searchText,
  });


  Future<String> uploadSignature({
    required String signaturePath,
  });



  Future<void> submitOrder({
    required int userId,
    required DealerEntity dealer,
    required GodownEntity godown,
    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,
    required String signatureFileName,
  });
}