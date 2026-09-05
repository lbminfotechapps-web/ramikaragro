abstract class FamerfollowupState {}

class FamerfollowupInitial extends FamerfollowupState {}

class FamerfollowupLoading extends FamerfollowupState {}

class FamerfollowupSuccess extends FamerfollowupState {
  final String message;

  FamerfollowupSuccess({required this.message});
}

class FamerfollowupFailure extends FamerfollowupState {
  final String message;

  FamerfollowupFailure({required this.message});
}
