import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';

abstract class HomeVisitState {
  const HomeVisitState();
}

class HomeVisitInitial extends HomeVisitState {
  const HomeVisitInitial();
}

class HomeVisitLoading extends HomeVisitState {
  const HomeVisitLoading();
}

class HomeVisitLoaded extends HomeVisitState {
  final HomeVisitEntity data;

  const HomeVisitLoaded({required this.data});
}

class HomeVisitError extends HomeVisitState {
  final String message;

  const HomeVisitError({required this.message});
}
