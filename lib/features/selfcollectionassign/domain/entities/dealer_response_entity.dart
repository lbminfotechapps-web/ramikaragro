import 'package:equatable/equatable.dart';

import 'dealer_entity.dart';

class DealerResponseEntity extends Equatable {
  final List<DealerEntity> dealers;
  final bool status;
  final String message;

  const DealerResponseEntity({
    required this.dealers,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [dealers, status, message];
}
