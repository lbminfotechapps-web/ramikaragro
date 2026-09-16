import 'package:equatable/equatable.dart';

class Dealer extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String address;

  const Dealer({
    required this.id,
    required this.name,
    this.mobile = '',
    this.address = '',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        address,
      ];
}