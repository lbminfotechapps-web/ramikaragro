import 'dart:async';
import 'dart:io';

import 'package:demo/core/utility/image_compression.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_state.dart';
import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/add_ramark.dart';
import 'add_dealer_visit_event.dart';


class AddDealerVisitBlock
    extends Bloc<AddDealerRemarkEvent, AddDealerVisitState> {
  final AddRemark addLeave;
  final FarmerregistrationRepository repositoryProvider;

  AddDealerVisitBlock(this.addLeave, this.repositoryProvider)
    : super(const AddDealerVisitState()) {
    // on<GetLeaveListEvent>(_onGetLeaveList);
    on<AddDealerRemarkSubmitEvent>(_onAddRemark);
    on<GetPurposeEvent>(_onGetPurpose);
    on<GetFollowupEvent>(_onGetFollowup);
    on<AddDealerFollowUpEvent>(_onAddDealerFollowUp);

    on<StateListEvent>(_onStateListGet);
    on<DistrictEvent>(_onDistrictGet);

    on<UpdateDealerEvent>(_onUpdateDealer);
    // on<ClearLeaveMessageEvent>(_onClearMessage);
  }

  FutureOr<void> _onAddRemark(
    AddDealerRemarkSubmitEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
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

      final postData = addLeave.call(formData);
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

  Future<void> _onGetPurpose(
    GetPurposeEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
    emit(state.copyWith(addLeaveStatus: AddDealerVisitStatus.loading));

    try {
      final purpose = await addLeave.getPurpose(event.userId);
      print('bloc response$purpose');
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.success,
          purpose: purpose,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }




   Future<void> _onGetFollowup(
  GetFollowupEvent event,
  Emitter<AddDealerVisitState> emit,
) async {
  emit(
    state.copyWith(
      addLeaveStatus: AddDealerVisitStatus.loading,
    ),
  );

  try {
    final followupList = await addLeave.getFollowupList(
      event.outlet_id,
    );

    print('Followup List: $followupList');
    print('Followup List Size: ${followupList.length}');

    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.success,
        followupList: followupList,
      ),
    );
  } catch (error) {
    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }
}
  Future<void> _onStateListGet(
    StateListEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
    print('================================');
    print('STATE API CALLED');
    print('USER ID: ${event.userId}');
    print('================================');

    emit(state.copyWith(addLeaveStatus: AddDealerVisitStatus.loading));

    try {
      final response = await repositoryProvider.getStates(event.userId);

      print('REPOSITORY RESPONSE LENGTH: ${response.length}');

      for (final item in response) {
        print(
          'REPOSITORY ITEM -> ID: ${item.stateId} | NAME: ${item.stateName}',
        );
      }

      if (response.isEmpty) {
        print('STATE RESPONSE EMPTY');

        emit(
          state.copyWith(
            addLeaveStatus: AddDealerVisitStatus.failure,
            statentity: [],
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.success,
          statentity: response,
        ),
      );

      print('================================');
      print('BLOC STATUS: SUCCESS');
      // print('BLOC STATE COUNT: ${state.statentity.length}');
      print('================================');
    } catch (e, stackTrace) {
      print('STATE BLOC ERROR: $e');
      print(stackTrace);

      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          statentity: [],
        ),
      );
    }
  }

  Future<void> _onDistrictGet(
    DistrictEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.loading,
        errorMessage: null,
        districtList: [],
      ),
    );

    try {
      final districts = await repositoryProvider.getDistrict(
        event.userId,
        event.stateId,
      );

      print('bloc response $districts');

      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.success,
          districtList: districts,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddDealerFollowUp(
    AddDealerFollowUpEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      File? selfieImageFile;

      // ============================================
      // COMPRESS SELFIE IMAGE
      // ============================================
      if (event.selfieCaptureImage.isNotEmpty) {
        final originalFile = File(event.selfieCaptureImage);

        if (await originalFile.exists()) {
          selfieImageFile = await ImageCompression.compressImage(
            originalFile,
            maxWidth: 450,
            maxHeight: 450,
            quality: 45,
          );

          if (selfieImageFile == null) {
            throw Exception('Unable to compress selfie image');
          }
        } else {
          print(
            'Selfie image file not found: '
            '${event.selfieCaptureImage}',
          );
        }
      }

      // ============================================
      // REQUEST DATA
      // ============================================
      final jsonData = <String, dynamic>{
        'user_id': event.userId,
        'type': event.type,
        'outlet_name': event.outletName,
        'contact_person': event.contactPerson,
        'gst_no': event.gstNo,
        'mobile_no': event.mobileNo,
        'mobile_no2': event.mobileNo2,
        'email_id': event.emailId,
        'address': event.address,

        'state': event.state,
        'district': event.district,
        'taluka': event.taluka,

        'remark': event.remark,
        'city': event.city,

        'latitude': event.latitude,
        'longitude': event.longitude,
        'networkLatitude': event.networkLatitude,
        'networkLongitude': event.networkLongitude,
        'gpsLatitude': event.gpsLatitude,
        'gpsLongitude': event.gpsLongitude,

        'geoAddress': event.geoAddress,
        'differenceByAndroid': event.differenceByAndroid,

        'mobile_info': event.mobileInfo,
        'mobile_imei': event.mobileImei,

        'followUpDate': event.followUpDate,
        'followUpType': event.followUpType,

        'strNetworkInfo': event.strNetworkInfo,
        'strBatteryInfo': event.strBatteryInfo,

        'registrationType': event.registrationType,
        'flag': event.flag,
        'dealerCode': event.dealerCode,
        'activityId': event.activityId,
      };

      // ============================================
      // ADD SELFIE IMAGE FILE
      // ============================================
      if (selfieImageFile != null) {
        jsonData['selfie_capture_image'] = selfieImageFile;
      }

      // ============================================
      // DEBUG
      // ============================================
      print('========== DEALER FOLLOW UP REQUEST ==========');

      print(
        'user_id: '
        '${event.userId}',
      );

      print(
        'type: '
        '${event.type}',
      );

      print(
        'outlet_name: '
        '${event.outletName}',
      );

      print(
        'contact_person: '
        '${event.contactPerson}',
      );

      print(
        'gst_no: '
        '${event.gstNo}',
      );

      print(
        'mobile_no: '
        '${event.mobileNo}',
      );

      print(
        'mobile_no2: '
        '${event.mobileNo2}',
      );

      print(
        'email_id: '
        '${event.emailId}',
      );

      print(
        'address: '
        '${event.address}',
      );

      print(
        'state: '
        '${event.state}',
      );

      print(
        'district: '
        '${event.district}',
      );

      print(
        'taluka: '
        '${event.taluka}',
      );

      print(
        'remark: '
        '${event.remark}',
      );

      print(
        'city: '
        '${event.city}',
      );

      print(
        'latitude: '
        '${event.latitude}',
      );

      print(
        'longitude: '
        '${event.longitude}',
      );

      print(
        'networkLatitude: '
        '${event.networkLatitude}',
      );

      print(
        'networkLongitude: '
        '${event.networkLongitude}',
      );

      print(
        'gpsLatitude: '
        '${event.gpsLatitude}',
      );

      print(
        'gpsLongitude: '
        '${event.gpsLongitude}',
      );

      print(
        'geoAddress: '
        '${event.geoAddress}',
      );

      print(
        'differenceByAndroid: '
        '${event.differenceByAndroid}',
      );

      print(
        'mobile_info: '
        '${event.mobileInfo}',
      );

      print(
        'mobile_imei: '
        '${event.mobileImei}',
      );

      print(
        'followUpDate: '
        '${event.followUpDate}',
      );

      print(
        'followUpType: '
        '${event.followUpType}',
      );

      print(
        'strNetworkInfo: '
        '${event.strNetworkInfo}',
      );

      print(
        'strBatteryInfo: '
        '${event.strBatteryInfo}',
      );

      print(
        'registrationType: '
        '${event.registrationType}',
      );

      print(
        'flag: '
        '${event.flag}',
      );

      print(
        'dealerCode: '
        '${event.dealerCode}',
      );

      print(
        'activityId: '
        '${event.activityId}',
      );

      print(
        'selfie_capture_image: '
        '${selfieImageFile?.path ?? 'NO FILE'}',
      );

      print('==============================================');

      // ============================================
      // CALL API
      // ============================================
      final response = await addLeave.addDealerFollowUp(jsonData);

      print('Dealer follow up response: $response');

      // ============================================
      // SUCCESS
      // ============================================
      final responseStatus = response['status']?.toString().toLowerCase();

      if (responseStatus == 'success' ||
          responseStatus == 'true' ||
          responseStatus == '1') {
        emit(
          state.copyWith(
            addLeaveStatus: AddDealerVisitStatus.dealerAddedSuccess,
            errorMessage: response['message']?.toString(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            addLeaveStatus: AddDealerVisitStatus.failure,
            errorMessage:
                response['message']?.toString() ??
                'Unable to add dealer follow up',
          ),
        );
      }
    } catch (error) {
      print('Dealer follow up error: $error');

      // ============================================
      // FAILURE
      // ============================================
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onUpdateDealer(
    UpdateDealerEvent event,
    Emitter<AddDealerVisitState> emit,
  ) async {
    emit(
      state.copyWith(
        addLeaveStatus: AddDealerVisitStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // ============================================
      // REQUEST DATA
      // ============================================
      final jsonData = <String, dynamic>{
        'outlet_id': event.outletId,

        'user_id': event.userId,
        'type': event.type,
        'outlet_name': event.outletName,
        'contact_person': event.contactPerson,
        'gst_no': event.gstNo,
        'mobile_no': event.mobileNo,
        'mobile_no2': event.mobileNo2,
        'email_id': event.emailId,
        'address': event.address,

        'state': event.state,
        'district': event.district,
        'taluka': event.taluka,

        'remark': event.remark,
        'city': event.city,

        // ============================================
        // KOTLIN UPDATE DOES NOT SEND LOCATION
        // ============================================
        'latitude': '',
        'longitude': '',

        'dealerCode': event.dealerCode,
        'activityId': event.activityId,
        'followUpType': event.followUpType,
        'registrationType': event.registrationType,
      };

      // ============================================
      // DEBUG
      // ============================================
      print('========== UPDATE DEALER REQUEST ==========');

      print(
        'outlet_id: '
        '${event.outletId}',
      );

      print(
        'user_id: '
        '${event.userId}',
      );

      print(
        'type: '
        '${event.type}',
      );

      print(
        'outlet_name: '
        '${event.outletName}',
      );

      print(
        'contact_person: '
        '${event.contactPerson}',
      );

      print(
        'gst_no: '
        '${event.gstNo}',
      );

      print(
        'mobile_no: '
        '${event.mobileNo}',
      );

      print(
        'mobile_no2: '
        '${event.mobileNo2}',
      );

      print(
        'email_id: '
        '${event.emailId}',
      );

      print(
        'address: '
        '${event.address}',
      );

      print(
        'state: '
        '${event.state}',
      );

      print(
        'district: '
        '${event.district}',
      );

      print(
        'taluka: '
        '${event.taluka}',
      );

      print(
        'remark: '
        '${event.remark}',
      );

      print(
        'city: '
        '${event.city}',
      );

      print('latitude: ');

      print('longitude: ');

      print(
        'dealerCode: '
        '${event.dealerCode}',
      );

      print(
        'activityId: '
        '${event.activityId}',
      );

      print(
        'followUpType: '
        '${event.followUpType}',
      );

      print(
        'registrationType: '
        '${event.registrationType}',
      );

      print('===========================================');

      // ============================================
      // CALL UPDATE API
      // ============================================
      final response = await addLeave.updateDealerFollowUp(jsonData);

      print('Update dealer response: $response');

      // ============================================
      // SUCCESS
      // ============================================
      final responseStatus = response['status'];

      if (responseStatus == true) {
        emit(
          state.copyWith(
            addLeaveStatus: AddDealerVisitStatus.dealerUpdateSucess,
            errorMessage: response['message']?.toString(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            addLeaveStatus: AddDealerVisitStatus.failure,
            errorMessage:
                response['message']?.toString() ?? 'Unable to update dealer',
          ),
        );
      }
    } catch (error) {
      print('Update dealer error: $error');

      // ============================================
      // FAILURE
      // ============================================
      emit(
        state.copyWith(
          addLeaveStatus: AddDealerVisitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
