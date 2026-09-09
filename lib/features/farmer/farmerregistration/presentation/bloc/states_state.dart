import 'package:equatable/equatable.dart';

enum StatesStatus { initial, loading, failed, sucess }

class StatsState extends Equatable {
  final StatesStatus status;


  const StatsState({
    this.status = StatesStatus.initial,
 
  });

  StatsState copyWith({StatesStatus? status, StatesStatus? status1}) {
    return StatsState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
