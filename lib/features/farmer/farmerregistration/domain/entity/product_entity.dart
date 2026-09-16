import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String fldProductId;
  final String fldProductName;

  const ProductEntity({
    required this.fldProductId,
    required this.fldProductName,
  });

  @override
  List<Object?> get props => [
        fldProductId,
        fldProductName,
      ];
}