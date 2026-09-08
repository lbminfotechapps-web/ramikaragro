import 'package:equatable/equatable.dart';

abstract class TopTenDealerEvent extends Equatable {
  const TopTenDealerEvent();

  @override
  List<Object?> get props => [];
}

class GetTopTenDealerEvent extends TopTenDealerEvent {
  final int days;

  const GetTopTenDealerEvent({
    required this.days,
  });

  @override
  List<Object?> get props => [days];
}

class RefreshTopTenDealerEvent extends TopTenDealerEvent {
  const RefreshTopTenDealerEvent();
}