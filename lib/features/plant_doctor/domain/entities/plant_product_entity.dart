import 'package:equatable/equatable.dart';

class PlantProductEntity extends Equatable {
  final String productId;
  final String productName;
  final String micronutrientName;
  final String usage;

  const PlantProductEntity({
    required this.productId,
    required this.productName,
    required this.micronutrientName,
    this.usage = '',
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        micronutrientName,
        usage,
      ];
}