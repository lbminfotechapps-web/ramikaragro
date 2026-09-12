import 'dart:async';

import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/add_ramark.dart';
import 'add_dealer_visit_event.dart';
import 'add_dealer_visit_state.dart';

class AddDealerVisitBlock
    extends Bloc<AddDealerRemarkEvent, AddDealerVisitState> {
  // final GetLeaveList getLeaveList;
  final AddRemark addLeave;

  AddDealerVisitBlock(this.addLeave) : super(const AddDealerVisitState()) {
    // on<GetLeaveListEvent>(_onGetLeaveList);
    on<AddDealerRemarkSubmitEvent>(_onAddRemark);
    on<GetPurposeEvent>(_onGetPurpose);
    // on<ClearLeaveMessageEvent>(_onClearMessage);
  }

 
  FutureOr<void> _onAddRemark(AddDealerRemarkSubmitEvent event, Emitter<AddDealerVisitState> emit) 

    async {
    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      

      print("========== ADD LEAVE ==========");

      print("================================");

    
    Map<String, dynamic> formData = {
  "user_id": event.userId,
  "outlet_id": event.outletId,
  "purposeId": event.purposeId,
  "amount": event.amount,
  "followUpDate": event.followUpDate,
  "followUpType": event.followUpType,
  "remark": event.remark,
  "latitude": event.latitude,
  "longitude": event.longitude,
  "networkLatitude": event.networkLatitude,
  "networkLongitude": event.networkLongitude,
  "gpsLatitude": event.gpsLatitude,
  "gpsLongitude": event.gpsLongitude,
  "geoAddress": event.geoAddress,
  "strNetworkInfo": event.strNetworkInfo,
  "strBatteryInfo": event.strBatteryInfo,
  "activityId": event.activityId,
};

final postData=addLeave.call(formData);
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.success,
          successMessage: "",
          clearError: true,
        ),
      );
    } catch (e) {
      String message = "Unable to apply leave";

      if (e is ServerException || e is NetworkException) {
        message = e.toString();
      }

      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: message,
          clearSuccess: true,
        ),
      );
    }

    
  }

  Future<void> _onGetPurpose(GetPurposeEvent event, Emitter<AddDealerVisitState> emit) async {
    emit(state.copyWith(addLeaveStatus: AddDealerVisitStatus.loading));

    try {
      final purpose = await addLeave.getPurpose(event.userId);
      print('bloc response$purpose');
      emit(state.copyWith(addLeaveStatus: AddDealerVisitStatus.success, purpose: purpose));
    } catch (error) {
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

}
