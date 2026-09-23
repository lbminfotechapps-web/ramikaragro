class ProductResponseEntity {
  final List<ProductEntityy> products;
  final bool status;
  final String message;

  const ProductResponseEntity({
    required this.products,
    required this.status,
    required this.message,
  });
}

class ProductEntityy {
  final String productId;
  final String productName;
  final String productPath;
  final String productContents;
  final String productDosage;

  const ProductEntityy({
    required this.productId,
    required this.productName,
    required this.productPath,
    required this.productContents,
    required this.productDosage,
  });
}
