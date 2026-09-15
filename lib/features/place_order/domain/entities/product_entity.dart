import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String image;
  final String categoryId;
  final String unit;
  final String price;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    required this.unit,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        categoryId,
        unit,
        price,
      ];
}