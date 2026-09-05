import 'package:equatable/equatable.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';

enum QuickAccessStatus { initial, loading, success, failure }

class QuickAccessState extends Equatable {
  final QuickAccessStatus quickAccessStatus;
  final PunchStatEntity? punchStat;
  final String? errorMessage;

  const QuickAccessState({
    this.quickAccessStatus = QuickAccessStatus.initial,
    this.punchStat,
    this.errorMessage,
  });

  QuickAccessState copyWith({
    QuickAccessStatus? quickAccessStatus,
    PunchStatEntity? punchStat,
    String? errorMessage,
  }) {
    return QuickAccessState(
      quickAccessStatus: quickAccessStatus ?? this.quickAccessStatus,
      punchStat: punchStat ?? this.punchStat,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [quickAccessStatus, punchStat, errorMessage];
}
