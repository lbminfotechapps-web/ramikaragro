import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:demo/core/utility/image_compression.dart';
import 'package:demo/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAcessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final GetPunchStatusUsecase getPunchStatusUsecase;

  QuickAcessBloc(this.getPunchStatusUsecase) : super(const QuickAccessState()) {
    on<PunchStatEvent>(_onGetPunchStatus);
    on<VehicleTypeEvent>(_onGetVehicleType);
    on<PunchInOutDetailsAddEvent>(_onPunchInOutAddDetails);
  }
  String? punchStatus;
  Future<void> _onGetPunchStatus(
    PunchStatEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(
      state.copyWith(
        quickAccessStatus: QuickAccessStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final punchStat = await getPunchStatusUsecase.getPunchStatus(
        event.userId,
      );
      punchStatus = punchStat.inOutStatus;
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.success,
          punchStat: punchStat,
          punchStatus: punchStat.inOutStatus,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onGetVehicleType(
    VehicleTypeEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(
      state.copyWith(
        quickAccessStatus: QuickAccessStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final vehicles = await getPunchStatusUsecase.getVehicleType(
        event.userId,
        event.lastDate,
      );

      final vehicleList = vehicles
          .where((vehicle) => vehicle.vehicleTypeId != '0')
          .toList();

      final defaultVehicle = vehicleList.cast<VehicleTypeEntity?>().firstWhere(
        (vehicle) => vehicle?.vehicleType.toLowerCase() == 'bike',
        orElse: () => vehicleList.isEmpty ? null : vehicleList.first,
      );

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.success,
          vehicleList: vehicleList,
          selectedVehicle: defaultVehicle,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }


  Future<void> _onPunchInOutAddDetails(
    PunchInOutDetailsAddEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(
      state.copyWith(
        quickAccessStatus: QuickAccessStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // ============================================
      // REQUEST DATA
      // ============================================
      final Map<String, dynamic> jsonData = <String, dynamic>{
        'user_id': event.userId,
        'in_out_status': event.inOutStatus,
        'differenceByAndroid': event.differenceByAndroid,
        'locationHistoryString': event.locationHistoryString,
        'strBatteryInfo': event.batteryInfo,
        'strNetworkInfo': event.networkInfo,
        'pinRemark': event.pinRemark,
        'strStartingClosingKmAmount': event.startingClosingKmAmount,
        'strVehicleTypeId': event.vehicleTypeId,
        'route': event.route,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'networkLatitude': event.networkLatitude,
        'networkLongitude': event.networkLongitude,
        'gpsLatitude': event.gpsLatitude,
        'gpsLongitude': event.gpsLongitude,
        'geoAddress': event.geoAddress,
        'activityId': event.activityId,
      };

      // ============================================
      // ADD STARTING IMAGE AS BASE64
      // ============================================
      if (event.startingKmImage != null && event.startingKmImage!.isNotEmpty) {
        jsonData['startingKmImage'] = event.startingKmImage;

        debugPrint(
          'Starting image Base64 length: '
          '${event.startingKmImage!.length}',
        );

        debugPrint(
          'Starting image Base64 preview: '
          '${event.startingKmImage!.substring(0, event.startingKmImage!.length > 50 ? 50 : event.startingKmImage!.length)}...',
        );
      } else {
        debugPrint('Starting image: NOT PROVIDED');
      }

      // ============================================
      // DO NOT ADD
      // ============================================
      // date
      // time
      // closingKmImage
      // isForceOutPunch
      //
      // These parameters are completely absent
      // from the Punch In request.
      // ============================================

      // ============================================
      // DEBUG
      // ============================================
      debugPrint('========== PUNCH IN REQUEST ==========');

      jsonData.forEach((key, value) {
        if (key == 'startingKmImage') {
          final image = value?.toString() ?? '';

          debugPrint(
            '$key: BASE64 IMAGE '
            '(${image.length} characters)',
          );
        } else {
          debugPrint('$key: $value');
        }
      });

      debugPrint('======================================');

      // ============================================
      // CALL API
      // ============================================
      final response = await getPunchStatusUsecase.savePunchDetails(jsonData);

      debugPrint('Punch details response: $response');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.punchStatusSuccess,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Punch details error: $error');

      debugPrint('StackTrace: $stackTrace');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
