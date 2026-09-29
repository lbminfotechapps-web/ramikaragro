import 'package:equatable/equatable.dart';

class DealerEntity extends Equatable {
  final String outletId;
  final String outletName;
  final String outletMobile;

  const DealerEntity({
    required this.outletId,
    required this.outletName,
    required this.outletMobile,
  });

  @override
  List<Object?> get props => [outletId, outletName, outletMobile];
}
