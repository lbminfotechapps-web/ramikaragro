import 'package:equatable/equatable.dart';

abstract class DealerEvent extends Equatable {
  const DealerEvent();

  @override
  List<Object?> get props => [];
}

class GetDealerListEvent extends DealerEvent {
  final int userId;

  const GetDealerListEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshDealerListEvent extends DealerEvent {
  final int userId;

  const RefreshDealerListEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
