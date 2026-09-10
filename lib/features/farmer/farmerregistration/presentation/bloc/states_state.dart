import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:equatable/equatable.dart';

enum StatesStatus { initial, loading, failed, sucess }

class StatsState extends Equatable {
  final StatesStatus status;
  final List<StateEntity> statentity;

  const StatsState({
    this.status = StatesStatus.initial,
    this.statentity = const [],
  });

  StatsState copyWith({StatesStatus? status, List<StateEntity>? statentity}) {
    return StatsState(
      status: status ?? this.status,
      statentity: statentity ?? this.statentity,
    );
  }

  @override
  List<Object?> get props => [status, statentity];
}
