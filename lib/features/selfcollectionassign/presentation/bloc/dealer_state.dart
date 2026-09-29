import 'package:equatable/equatable.dart';

import '../../domain/entities/dealer_entity.dart';

enum DealerStatus { initial, loading, success, failure }

class DealerState extends Equatable {
  final DealerStatus status;
  final List<DealerEntity> dealers;
  final String message;

  const DealerState({
    this.status = DealerStatus.initial,
    this.dealers = const [],
    this.message = '',
  });

  DealerState copyWith({
    DealerStatus? status,
    List<DealerEntity>? dealers,
    String? message,
  }) {
    return DealerState(
      status: status ?? this.status,
      dealers: dealers ?? this.dealers,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, dealers, message];
}
