import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:solufine/core/utility/image_compression.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StateBloc extends Bloc<StatesEvent, StatsState> {
  final FarmerregistrationRepository repositoryProvider;

  StateBloc({required this.repositoryProvider}) : super(StatsState()) {
    on<StateListEvent>(_onStateListGet);
    on<DistrictEvent>(_onDistrictGet);
    on<FarmerDropEvent>(_onGetFarmerDropData);
    on<FarmerSubmitDetailsEvent>(_onAddFarmerDetails);
    on<UpdateFarmerSubmitDetailsEvent>(_onUpdateFarmerDetails);
  }

  Future<void> _onStateListGet(
    StateListEvent event,
    Emitter<StatsState> emit,
  ) async {
    print('================================');
    print('STATE API CALLED');
    print('USER ID: ${event.userId}');
    print('================================');

    emit(state.copyWith(status: StatesStatus.initial));

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

        emit(state.copyWith(status: StatesStatus.failed, statentity: []));

        return;
      }

      emit(state.copyWith(status: StatesStatus.sucess, statentity: response));

      print('================================');
      print('BLOC STATUS: SUCCESS');
      print('BLOC STATE COUNT: ${state.statentity.length}');
      print('================================');
    } catch (e, stackTrace) {
      print('STATE BLOC ERROR: $e');
      print(stackTrace);

      emit(state.copyWith(status: StatesStatus.failed, statentity: []));
    }
  }

  Future<void> _onDistrictGet(
    DistrictEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StatesStatus.loading,
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
          status: StatesStatus.sucess,
          districtList: districts,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: StatesStatus.failed, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _onGetFarmerDropData(
    FarmerDropEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.loading, errorMessage: null));

    try {
      final response = await repositoryProvider.getFarmerDropData();

      emit(
        state.copyWith(
          status: StatesStatus.sucess,
          farmerDetailsEntity: response,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: StatesStatus.failed, errorMessage: e.toString()),
      );
    }
  }

  // Future<void> _onAddFarmerDetails(
  //   FarmerSubmitDetailsEvent event,
  //   Emitter<StatsState> emit,
  // ) async {
  //   emit(state.copyWith(status: StatesStatus.loading, errorMessage: null));

  //   try {
  //     // ============================================
  //     // FARMER IMAGE -> COMPRESS -> BASE64
  //     // ============================================
  //     String? farmerImageBase64;

  //     if (event.image.isNotEmpty) {
  //       final originalFile = File(event.image);

  //       if (await originalFile.exists()) {
  //         debugPrint('Farmer original image: ${event.image}');

  //         final farmerImageFile = await ImageCompression.compressImage(
  //           originalFile,
  //           maxWidth: 450,
  //           maxHeight: 450,
  //           quality: 45,
  //         );

  //         if (farmerImageFile == null) {
  //           throw Exception('Unable to compress farmer image');
  //         }

  //         // Read compressed image
  //         final imageBytes = await farmerImageFile.readAsBytes();

  //         // Convert to Base64
  //         farmerImageBase64 = base64Encode(imageBytes);

  //         debugPrint(
  //           'Farmer image Base64 length: '
  //           '${farmerImageBase64.length}',
  //         );
  //       } else {
  //         debugPrint('Farmer image file not found: ${event.image}');
  //       }
  //     } else {
  //       debugPrint('Farmer image: NOT SELECTED');
  //     }

  //     // ============================================
  //     // REQUEST DATA
  //     // ============================================
  //     final jsonData = <String, dynamic>{
  //       'fld_farmer_name': event.fldFarmerName,
  //       'fld_address': event.fldAddress,
  //       'user_id': event.userId,
  //       'fld_category_id': event.fldCategoryId,
  //       'state': event.state,
  //       'fld_demo_type_id': event.fldDemoTypeId,
  //       'district': event.district,
  //       'taluka': event.taluka,

  //       'status_of_farmer': event.statusOfFarmer,
  //       'campaign_radio': event.campaignRadio,

  //       'fld_mobile_no': event.fldMobileNo,
  //       'fld_mobile_no2': event.fldMobileNo2,
  //       'fld_total_acre': event.fldTotalAcre,
  //       'fld_email_id': event.fldEmailId,
  //       'fld_tractor_mode': event.fldTractorMode,
  //       'fld_village': event.fldVillage,

  //       'selectedProductId': event.selectedProductId,
  //       'selectedCropId': event.selectedCropId,
  //       'selectedAcers': event.selectedAcers,
  //       'selectedSowingDates': event.selectedSowingDates,
  //       'selectedIrrigationId': event.selectedIrrigationId,

  //       'selectedCattleId': event.selectedCattleId,
  //       'selectedCattleCount': event.selectedCattleCount,

  //       'latitude': event.latitude,
  //       'longitude': event.longitude,
  //       'networkLatitude': event.networkLatitude,
  //       'networkLongitude': event.networkLongitude,
  //       'gpsLatitude': event.gpsLatitude,
  //       'gpsLongitude': event.gpsLongitude,
  //       'differenceByAndroid': event.differenceByAndroid,

  //       'contactPersonName': event.contactPersonName,
  //       'meetingLocation': event.meetingLocation,
  //       'marketNearby': event.marketNearby,
  //       'aadhaarNo': event.aadhaarNo,
  //       'remark': event.remark,
  //       'geoAddress': event.geoAddress,
  //       'strNetworkInfo': event.strNetworkInfo,
  //       'currentProductUsed': event.currentProductUsed,
  //       'strBatteryInfo': event.strBatteryInfo,
  //       'activityId': event.activityId,
  //     };

  //     // ============================================
  //     // ADD BASE64 IMAGE
  //     // ============================================
  //     if (farmerImageBase64 != null && farmerImageBase64.isNotEmpty) {
  //       jsonData['selfie_capture_image'] = farmerImageBase64;

  //       debugPrint(
  //         'image: BASE64 IMAGE '
  //         '($farmerImageBase64 characters)',
  //       );
  //     } else {
  //       debugPrint('image: NOT SENT');
  //     }

  //     // ============================================
  //     // PRINT REQUEST DATA
  //     // ============================================
  //     jsonData.forEach((key, value) {
  //       if (key == 'selfie_capture_image') {
  //         final String image = value?.toString() ?? '';

  //         debugPrint(
  //           '$key: BASE64 IMAGE '
  //           '($image characters)',
  //         );
  //       } else {
  //         debugPrint('$key: $value');
  //       }
  //     });

  //     debugPrint('====================================');

  //     // ============================================
  //     // CALL API
  //     // ============================================
  //     final response = await repositoryProvider.saveFarmerDetails(jsonData);

  //     debugPrint('Farmer details response: $response');

  //     // ============================================
  //     // DEBUG
  //     // ============================================
  //     print('========== FARMER REQUEST ==========');

  //     print(
  //       'selectedSowingDates: '
  //       '${event.selectedSowingDates}',
  //     );

  //     print(
  //       'marketNearby: '
  //       '${event.marketNearby}',
  //     );

  //     print(
  //       'status_of_farmer: '
  //       '${event.statusOfFarmer}',
  //     );

  //     print(
  //       'selectedAcers: '
  //       '${event.selectedAcers}',
  //     );

  //     print(
  //       'selectedIrrigationId: '
  //       '${event.selectedIrrigationId}',
  //     );

  //     print(
  //       'selectedProductId: '
  //       '${event.selectedProductId}',
  //     );

  //     print(
  //       'activityId: '
  //       '${event.activityId}',
  //     );

  //     print(
  //       'campaign_radio: '
  //       '${event.campaignRadio}',
  //     );

  //     print(
  //       'currentProductUsed: '
  //       '${event.currentProductUsed}',
  //     );

  //     print(
  //       'state: '
  //       '${event.state}',
  //     );

  //     print(
  //       'district: '
  //       '${event.district}',
  //     );

  //     print(
  //       'taluka: '
  //       '${event.taluka}',
  //     );

  //     print(
  //       'fld_farmer_name: '
  //       '${event.fldFarmerName}',
  //     );

  //     print(
  //       'fld_mobile_no: '
  //       '${event.fldMobileNo}',
  //     );

  //     print(
  //       'image: '
  //       '${farmerImageBase64}',
  //     );

  //     print('====================================');

  //     // ============================================
  //     // SUCCESS
  //     // ============================================
  //     if (response['status'] == true) {
  //       emit(
  //         state.copyWith(
  //           status: StatesStatus.farmerRegiSuccess,
  //           errorMessage: response['message'],
  //         ),
  //       );
  //     } else {
  //       emit(
  //         state.copyWith(
  //           status: StatesStatus.failed,
  //           errorMessage: response['message'],
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     debugPrint('Farmer details error: $error');

  //     emit(
  //       state.copyWith(
  //         status: StatesStatus.failed,
  //         errorMessage: error.toString(),
  //       ),
  //     );
  //   }
  // }



   Future<void> _onAddFarmerDetails(
  FarmerSubmitDetailsEvent event,
  Emitter<StatsState> emit,
) async {
  emit(
    state.copyWith(
      status: StatesStatus.loading,
      errorMessage: null,
    ),
  );

  try {
 

    File? farmerImageFile;

    debugPrint('==========================================');
    debugPrint('FARMER IMAGE CHECK');
    debugPrint('EVENT IMAGE PATH: ${event.image}');
    debugPrint('==========================================');

    if (event.image.trim().isNotEmpty) {
      final originalFile = File(
        event.image.trim(),
      );

      final bool exists =
          await originalFile.exists();

      debugPrint(
        'ORIGINAL IMAGE EXISTS: $exists',
      );

      if (exists) {
        debugPrint(
          'ORIGINAL IMAGE PATH: ${originalFile.path}',
        );

        debugPrint(
          'ORIGINAL IMAGE SIZE: '
          '${await originalFile.length()} bytes',
        );

        // ========================================================
        // COMPRESS IMAGE
        // ========================================================

        final compressedFile =
            await ImageCompression.compressImage(
          originalFile,
          maxWidth: 450,
          maxHeight: 450,
          quality: 45,
        );

        // ========================================================
        // Use compressed image if compression succeeds.
        // Otherwise use original image.
        // ========================================================

        if (compressedFile != null &&
            await compressedFile.exists()) {
          farmerImageFile =
              compressedFile;

          debugPrint(
            ' USING COMPRESSED IMAGE',
          );

          debugPrint(
            'COMPRESSED PATH: '
            '${farmerImageFile.path}',
          );

          debugPrint(
            'COMPRESSED SIZE: '
            '${await farmerImageFile.length()} bytes',
          );
        } else {
          farmerImageFile =
              originalFile;

          debugPrint(
            ' COMPRESSION FAILED - '
            'USING ORIGINAL IMAGE',
          );

          debugPrint(
            'IMAGE PATH: '
            '${farmerImageFile.path}',
          );
        }
      } else {
        debugPrint(
          ' FARMER IMAGE FILE DOES NOT EXIST',
        );
      }
    } else {
      debugPrint(
        ' FARMER IMAGE NOT SELECTED',
      );
    }

    // ============================================================
    // 2. NORMAL REQUEST DATA
    // ============================================================
    //
    // IMPORTANT:
    // selfie_capture_image is NOT added here.
    //
    // It will be added by Datasource as MultipartFile.
    //
    // ============================================================

    final jsonData =
        <String, dynamic>{
      'fld_farmer_name':
          event.fldFarmerName,

      'fld_address':
          event.fldAddress,

      'user_id':
          event.userId,

      'fld_category_id':
          event.fldCategoryId,

      'state':
          event.state,

      'fld_demo_type_id':
          event.fldDemoTypeId,

      'district':
          event.district,

      'taluka':
          event.taluka,

      'status_of_farmer':
          event.statusOfFarmer,

      'campaign_radio':
          event.campaignRadio,

      'fld_mobile_no':
          event.fldMobileNo,

      'fld_mobile_no2':
          event.fldMobileNo2,

      'fld_total_acre':
          event.fldTotalAcre,

      'fld_email_id':
          event.fldEmailId,

      'fld_tractor_mode':
          event.fldTractorMode,

      'fld_village':
          event.fldVillage,

      'selectedProductId':
          event.selectedProductId,

      'selectedCropId':
          event.selectedCropId,

      'selectedAcers':
          event.selectedAcers,

      'selectedSowingDates':
          event.selectedSowingDates,

      'selectedIrrigationId':
          event.selectedIrrigationId,

      'selectedCattleId':
          event.selectedCattleId,

      'selectedCattleCount':
          event.selectedCattleCount,

      'latitude':
          event.latitude,

      'longitude':
          event.longitude,

      'networkLatitude':
          event.networkLatitude,

      'networkLongitude':
          event.networkLongitude,

      'gpsLatitude':
          event.gpsLatitude,

      'gpsLongitude':
          event.gpsLongitude,

      'differenceByAndroid':
          event.differenceByAndroid,

      'contactPersonName':
          event.contactPersonName,

      'meetingLocation':
          event.meetingLocation,

      'marketNearby':
          event.marketNearby,

      'aadhaarNo':
          event.aadhaarNo,

      'remark':
          event.remark,

      'geoAddress':
          event.geoAddress,

      'strNetworkInfo':
          event.strNetworkInfo,

      'currentProductUsed':
          event.currentProductUsed,

      'strBatteryInfo':
          event.strBatteryInfo,

      'activityId':
          event.activityId,
    };

    // ============================================================
    // 3. PRINT NORMAL FORM DATA
    // ============================================================

    debugPrint('');
    debugPrint(
      '==========================================',
    );
    debugPrint(
      'FARMER NORMAL REQUEST DATA',
    );
    debugPrint(
      '==========================================',
    );

    jsonData.forEach(
      (key, value) {
        debugPrint(
          '$key: $value',
        );
      },
    );

    // ============================================================
    // 4. PRINT IMAGE INFORMATION
    // ============================================================

    debugPrint(
      '==========================================',
    );
    debugPrint(
      'IMAGE TO REPOSITORY',
    );
    debugPrint(
      '==========================================',
    );

    if (farmerImageFile != null) {
      debugPrint(
        ' IMAGE AVAILABLE',
      );

      debugPrint(
        'PATH: ${farmerImageFile.path}',
      );

      debugPrint(
        'EXISTS: '
        '${await farmerImageFile.exists()}',
      );

      debugPrint(
        'SIZE: '
        '${await farmerImageFile.length()} bytes',
      );
    } else {
      debugPrint(
        ' IMAGE FILE IS NULL',
      );
    }

    debugPrint(
      '==========================================',
    );

  
    final response =
        await repositoryProvider
            .saveFarmerDetails(
      jsonData,
      farmerImageFile,
    );

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'FARMER DETAILS RESPONSE: $response',
    );

    debugPrint(
      '==========================================',
    );

    // ============================================================
    // 6. HANDLE RESPONSE
    // ============================================================

    if (response['status'] == true) {
      emit(
        state.copyWith(
          status:
              StatesStatus
                  .farmerRegiSuccess,
          errorMessage:
              response['message'],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status:
              StatesStatus.failed,
          errorMessage:
              response['message'],
        ),
      );
    }
  } catch (error, stackTrace) {
    debugPrint(
      '==========================================',
    );

    debugPrint(
      ' FARMER DETAILS ERROR',
    );

    debugPrint(
      'ERROR: $error',
    );

    debugPrint(
      'STACK TRACE: $stackTrace',
    );

    debugPrint(
      '==========================================',
    );

    emit(
      state.copyWith(
        status:
            StatesStatus.failed,
        errorMessage:
            error.toString(),
      ),
    );
  }
}




  FutureOr<void> _onUpdateFarmerDetails(
    UpdateFarmerSubmitDetailsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.loading, errorMessage: null));

    try {
      // ============================================
      // UPDATE FARMER REQUEST DATA
      // ============================================
      final Map<String, dynamic> formdata = {
        'farmerID': event.farmerId,
        'farmer_name': event.fldFarmerName,
        'address': event.fldAddress,
        'user_id': event.userId,
        'category_id': event.fldCategoryId,
        'state': event.state,
        'fld_demo_type_id': event.fldDemoTypeId,
        'district': event.district,
        'taluka': event.taluka,
        'status_of_farmer': event.statusOfFarmer,
        'campaign_radio': event.campaignRadio,
        'fld_tractor_mode': event.fldTractorMode,
        'mobile_no': event.fldMobileNo,
        'mobile_no2': event.fldMobileNo2,
        'fld_total_acre': event.fldTotalAcre,
        'email_id': event.fldEmailId,
        'village': event.fldVillage,
        'selectedProductId': event.selectedProductId,
        'currentProductUsed': event.currentProductUsed,
        'selectedCropId': event.selectedCropId,
        'selectedAcers': event.selectedAcers,
        'selectedSowingDates': event.selectedSowingDates,
        'selectedIrrigationId': event.selectedIrrigationId,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'networkLatitude': event.networkLatitude,
        'networkLongitude': event.networkLongitude,
        'gpsLatitude': event.gpsLatitude,
        'gpsLongitude': event.gpsLongitude,
        'differenceByAndroid': event.differenceByAndroid,

        'contactPersonName': event.contactPersonName,
        'meetingLocation': event.meetingLocation,
        'marketNearby': event.marketNearby,
        'aadhaarNo': event.aadhaarNo,
        'remark': event.remark,

        'activityId': event.activityId,
      };

      // ============================================
      // DEBUG
      // ============================================
      print('========== UPDATE FARMER REQUEST ==========');

      formdata.forEach((key, value) {
        print('$key : $value');
      });

      print('===========================================');

      final response = await repositoryProvider.updateFarmerDetails(formdata);

      print('Update farmer response: $response');

      if (response['status'] == "success") {
        emit(
          state.copyWith(
            status: StatesStatus.farmerUpdateSuccess,
            errorMessage: response['message'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: StatesStatus.failed,
            errorMessage: response['message'],
          ),
        );
      }
    } catch (error) {
      print('Update farmer error: $error');

      emit(
        state.copyWith(
          status: StatesStatus.failed,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
