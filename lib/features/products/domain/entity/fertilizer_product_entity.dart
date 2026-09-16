
class FertilizerProductEntity {
  final String productId;
  final String productName;
  final String productPath;
  final String productContents;
  final String productDosage;
  final String productShortDetails;
  final String productContentHindi;
  final String productContentMarathi;
  final String productNameMarathi;
  final String productNameHindi;
  final String diseasePath;
  final String productNameKannad;
  final String? productContentKannad;

  const FertilizerProductEntity({
    required this.productId,
    required this.productName,
    required this.productPath,
    required this.productContents,
    required this.productDosage,
    required this.productShortDetails,
    required this.productContentHindi,
    required this.productContentMarathi,
    required this.productNameMarathi,
    required this.productNameHindi,
    required this.diseasePath,
    required this.productNameKannad,
    this.productContentKannad,
  });
}

