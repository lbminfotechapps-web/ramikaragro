import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductListingEvent extends ProductEvent {
  final String searchText;

  const ProductListingEvent(this.searchText);

  @override
  List<Object?> get props => [searchText];
}
