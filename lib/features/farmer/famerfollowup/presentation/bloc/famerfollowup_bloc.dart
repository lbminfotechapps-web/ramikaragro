import 'package:demo/features/farmer/famerfollowup/domain/repository/famerfollowup_repository.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_event.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamerfollowupBloc extends Bloc<FamerfollowupEvent, FamerfollowupState> {
  final FamerfollowupRepository repository;

  FamerfollowupBloc({required this.repository})
    : super(FamerfollowupInitial()) {
    on<SubmitFollowupEvent>(_submitFollowup);
  }

  Future<void> _submitFollowup(
    SubmitFollowupEvent event,
    Emitter<FamerfollowupState> emit,
  ) async {
    emit(FamerfollowupLoading());

    try {
      final response = await repository.submitFollowup(
        farmerId: event.farmerId,
        userId: event.userId,
        followUpDate: event.followUpDate,
        followUpType: event.followUpType,
        remark: event.remark,
        latitude: event.latitude,
        longitude: event.longitude,
        networkLatitude: event.networkLatitude,
        networkLongitude: event.networkLongitude,
        gpsLatitude: event.gpsLatitude,
        gpsLongitude: event.gpsLongitude,
        geoAddress: event.geoAddress,
        networkInfo: event.networkInfo,
        batteryInfo: event.batteryInfo,
        differenceByAndroid: event.differenceByAndroid,
        statusOfFarmer: event.statusOfFarmer,
        activityId: event.activityId,
        imagePath: event.imagePath,
      );

      if (response.status) {
        emit(FamerfollowupSuccess(message: response.message));
      } else {
        emit(FamerfollowupFailure(message: response.message));
      }
    } catch (e) {
      emit(FamerfollowupFailure(message: e.toString()));
    }
  }
}
