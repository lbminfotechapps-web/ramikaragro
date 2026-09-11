import 'dart:async';
import 'dart:io';

import 'package:demo/core/utility/image_compression.dart';
import 'package:demo/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StateBloc extends Bloc<StatesEvent, StatsState> {
  final FarmerregistrationRepository repositoryProvider;

  StateBloc({required this.repositoryProvider}) : super(StatsState()) {
    on<StateListEvent>(_onStateListGet);
    on<DistrictEvent>(_onDistrictGet);
    on<FarmerDropEvent>(_onGetFarmerDropData);
    on<FarmerSubmitDetailsEvent>(_onAddFarmerDetails);
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

  Future<void> _onAddFarmerDetails(
    FarmerSubmitDetailsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatesStatus.loading, errorMessage: null));

    try {
      File? farmerImageFile;

      // ============================================
      // COMPRESS FARMER IMAGE
      // ============================================
      if (event.image.isNotEmpty) {
        final originalFile = File(event.image);

        if (await originalFile.exists()) {
          farmerImageFile = await ImageCompression.compressImage(
            originalFile,
            maxWidth: 450,
            maxHeight: 450,
            quality: 45,
          );

          if (farmerImageFile == null) {
            throw Exception('Unable to compress farmer image');
          }
        } else {
          print(
            'Farmer image file not found: '
            '${event.image}',
          );
        }
      }

      // ============================================
      // REQUEST DATA
      // ============================================
      final jsonData = <String, dynamic>{
        'selectedSowingDates': event.selectedSowingDates,
        'marketNearby': event.marketNearby,
        'gpsLongitude': event.gpsLongitude,
        'networkLatitude': event.networkLatitude,
        'latitude': event.latitude,
        'status_of_farmer': event.statusOfFarmer,
        'fld_tractor_mode': event.fldTractorMode,
        'remark': event.remark,
        'selectedAcers': event.selectedAcers,
        'selectedCattleCount': event.selectedCattleCount,
        'selectedIrrigationId': event.selectedIrrigationId,
        'selectedProductId': event.selectedProductId,
        'activityId': event.activityId,
        'campaign_radio': event.campaignRadio,
        'currentProductUsed': event.currentProductUsed,
        'selectedCattleId': event.selectedCattleId,
        'fld_category_id': event.fldCategoryId,
        'state': event.state,
        'fld_demo_type_id': event.fldDemoTypeId,
        'fld_village': event.fldVillage,
        'geoAddress': event.geoAddress,
        'strNetworkInfo': event.strNetworkInfo,
        'longitude': event.longitude,
        'gpsLatitude': event.gpsLatitude,
        'fld_total_acre': event.fldTotalAcre,
        'aadhaarNo': event.aadhaarNo,
        'fld_email_id': event.fldEmailId,
        'fld_address': event.fldAddress,
        'fld_mobile_no': event.fldMobileNo,
        'strBatteryInfo': event.strBatteryInfo,
        'differenceByAndroid': event.differenceByAndroid,
        'contactPersonName': event.contactPersonName,
        'user_id': event.userId,
        'fld_farmer_name': event.fldFarmerName,
        'district': event.district,
        'taluka': event.taluka,
        'fld_mobile_no2': event.fldMobileNo2,
        'networkLongitude': event.networkLongitude,
      };

      // ============================================
      // ADD FARMER IMAGE FILE
      // ============================================
      if (farmerImageFile != null) {
        jsonData['image'] = farmerImageFile;
      }

      // ============================================
      // DEBUG
      // ============================================
      print('========== FARMER REQUEST ==========');

      print(
        'selectedSowingDates: '
        '${event.selectedSowingDates}',
      );

      print(
        'marketNearby: '
        '${event.marketNearby}',
      );

      print(
        'status_of_farmer: '
        '${event.statusOfFarmer}',
      );

      print(
        'selectedAcers: '
        '${event.selectedAcers}',
      );

      print(
        'selectedIrrigationId: '
        '${event.selectedIrrigationId}',
      );

      print(
        'selectedProductId: '
        '${event.selectedProductId}',
      );

      print(
        'activityId: '
        '${event.activityId}',
      );

      print(
        'campaign_radio: '
        '${event.campaignRadio}',
      );

      print(
        'currentProductUsed: '
        '${event.currentProductUsed}',
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
        'fld_farmer_name: '
        '${event.fldFarmerName}',
      );

      print(
        'fld_mobile_no: '
        '${event.fldMobileNo}',
      );

      print(
        'image: '
        '${farmerImageFile?.path ?? 'NO FILE'}',
      );

      print('====================================');

      // ============================================
      // CALL API
      // ============================================
      final response = await repositoryProvider.saveFarmerDetails(jsonData);

      print('Farmer details response: $response');

      // ============================================
      // SUCCESS
      // ============================================
      emit(state.copyWith(status: StatesStatus.sucess, errorMessage: null));
    } catch (error) {
      print('Farmer details error: $error');

      // ============================================
      // FAILURE
      // ============================================
      emit(
        state.copyWith(
          status: StatesStatus.failed,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
