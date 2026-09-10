import 'package:equatable/equatable.dart';

abstract class CropScheduleEvent extends Equatable {
  const CropScheduleEvent();

  @override
  List<Object?> get props => [];
}

///
/// Initial API call
///
class GetCropSchedulesEvent extends CropScheduleEvent {
  const GetCropSchedulesEvent();

  @override
  List<Object?> get props => [];
}

///
/// Pull-to-refresh
///
class RefreshCropSchedulesEvent extends CropScheduleEvent {
  const RefreshCropSchedulesEvent();

  @override
  List<Object?> get props => [];
}