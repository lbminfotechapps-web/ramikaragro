import 'package:equatable/equatable.dart';

// ============================================================================
// DEALER SEARCH RESPONSE ENTITY
// ============================================================================

class DealerSearchResponseEntity extends Equatable {
  final bool status;
  final String message;
  final List<DealerSearchEntity> result;

  const DealerSearchResponseEntity({
    required this.status,
    required this.message,
    required this.result,
  });

  @override
  List<Object?> get props => [
        status,
        message,
        result,
      ];
}

// ============================================================================
// DEALER ENTITY
// ============================================================================

class DealerSearchEntity extends Equatable {
  final String outletId;
  final String outletName;
  final String outletMobile;
  final String geoAddress;

  const DealerSearchEntity({
    required this.outletId,
    required this.outletName,
    required this.outletMobile,
    required this.geoAddress,
  });

  @override
  List<Object?> get props => [
        outletId,
        outletName,
        outletMobile,
        geoAddress,
      ];
}