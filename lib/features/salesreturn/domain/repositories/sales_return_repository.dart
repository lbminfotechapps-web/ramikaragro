import '../entities/category_entity.dart';
import '../entities/dealer_entity.dart';
import '../entities/godown_entity.dart';
import '../entities/product_entity.dart';

abstract class SalesReturnRepository {
  // =========================================================
  // DEALER
  // =========================================================

  Future<List<DealerEntity>> getDealers({
    required int userId,
    required String searchText,
  });

  // =========================================================
  // GODOWN
  // =========================================================

  Future<List<GodownEntity>> getGodowns({
    required int userId,
  });

  // =========================================================
  // CATEGORY
  // =========================================================

  Future<List<CategoryEntity>> getCategories();

  // =========================================================
  // PRODUCTS
  // =========================================================

  Future<List<ProductEntity>> getProducts({
    required String categoryId,
    required String searchText,
  });

  // =========================================================
  // UPLOAD SIGNATURE
  // =========================================================

  Future<String> uploadSignature({
    required String signaturePath,
  });

  // =========================================================
  // SUBMIT ORDER
  // =========================================================

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