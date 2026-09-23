import 'package:equatable/equatable.dart';

class DealerEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String address;

  const DealerEntity({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        address,
      ];
}