import 'dart:async';

import 'package:solufine/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:solufine/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAcessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final GetPunchStatusUsecase getPunchStatusUsecase;

  QuickAcessBloc(this.getPunchStatusUsecase) : super(const QuickAccessState()) {
    on<PunchStatEvent>(_onGetPunchStatus);
    on<VehicleTypeEvent>(_onGetVehicleType);
    on<PunchInOutDetailsAddEvent>(_onPunchInOutAddDetails);
    on<ShareLocationEvent>(_onShareLocationAdd);
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
      // ============================================================
      // BASIC REQUEST DATA
      // ============================================================

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

      // ============================================================
      // DETERMINE PUNCH TYPE
      // ============================================================
      final bool isPunchIn = event.inOutStatus == '1';

      final bool isOutPunch =
          event.inOutStatus == '2' && event.isForceOutPunch != true;

      final bool isLastForceOut =
          event.inOutStatus == '2' && event.isForceOutPunch == true;

      debugPrint('========================================');
      debugPrint('PUNCH REQUEST TYPE');
      debugPrint('isPunchIn: $isPunchIn');
      debugPrint('isOutPunch: $isOutPunch');
      debugPrint('isLastForceOut: $isLastForceOut');
      debugPrint('========================================');

      // ============================================================
      // PUNCH IN
      // ============================================================
      // Send ONLY startingKmImage if available.
      //
      // Do NOT send closingKmImage.
      // Do NOT send date.
      // Do NOT send time.
      // Do NOT send isForceOutPunch.
      // ============================================================

      if (isPunchIn) {
        if (event.startingKmImage != null &&
            event.startingKmImage!.isNotEmpty) {
          jsonData['startingKmImage'] = event.startingKmImage;

          debugPrint(
            'startingKmImage: '
            'BASE64 (${event.startingKmImage!.length} chars)',
          );
        } else {
          debugPrint('startingKmImage: NOT PROVIDED');
        }
      }
      // ============================================================
      // NORMAL OUT PUNCH
      // ============================================================
      // Send ONLY closingKmImage if available.
      //
      // Do NOT send startingKmImage.
      // Do NOT send date.
      // Do NOT send time.
      // isForceOutPunch is not sent.
      // ============================================================

      if (isOutPunch) {
        if (event.closingKmImage != null && event.closingKmImage!.isNotEmpty) {
          jsonData['closingKmImage'] = event.closingKmImage;

          debugPrint(
            'closingKmImage: '
            'BASE64 (${event.closingKmImage!.length} chars)',
          );
        } else {
          debugPrint('closingKmImage: NOT PROVIDED');
        }
      }

      // ============================================================
      // LAST FORCE OUT
      // ============================================================
      // Do NOT send any image.
      //
      // Do NOT send startingKmImage.
      // Do NOT send closingKmImage.
      //
      // Send isForceOutPunch only if your API requires it.
      // ============================================================

      if (isLastForceOut) {
        debugPrint('LAST FORCE OUT');

        debugPrint('Date: ${event.date}');

        debugPrint('Time: ${event.newTime}');

        // Date
        if (event.date != null && event.date!.isNotEmpty) {
          jsonData['date'] = event.date;
        }

        // Time
        if (event.newTime != null && event.newTime!.isNotEmpty) {
          jsonData['time'] = event.newTime;
        }

        // Force out flag
        jsonData['isForceOutPunch'] = true;

        // IMPORTANT:
        // Do NOT add startingKmImage
        // Do NOT add closingKmImage
      }

      // ============================================================
      // OPTIONAL DATE
      // ============================================================

      if (event.date != null && event.date!.isNotEmpty) {
        jsonData['date'] = event.date;

        debugPrint('date: ${event.date}');
      }

      // ============================================================
      // OPTIONAL TIME
      // ============================================================

      if (event.newTime != null && event.newTime!.isNotEmpty) {
        jsonData['time'] = event.newTime;

        debugPrint('time: ${event.newTime}');
      }

      // ============================================================
      // FINAL REQUEST DEBUG
      // ============================================================

      debugPrint('');
      debugPrint('========== FINAL PUNCH REQUEST ==========');

      jsonData.forEach((key, value) {
        if (key == 'startingKmImage' || key == 'closingKmImage') {
          final String image = value?.toString() ?? '';

          debugPrint(
            '$key: BASE64 IMAGE '
            '($image characters)',
          );
        } else {
          debugPrint('$key: $value');
        }
      });

      debugPrint('==========================================');

      // ============================================================
      // API CALL
      // ============================================================

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

  FutureOr<void> _onShareLocationAdd(
    ShareLocationEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(
      state.copyWith(
        quickAccessStatus: QuickAccessStatus.loading,
        errorMessage: null,
      ),
    );

    try {
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
        'startingKmImage': event.startingKmImage ?? '',
        'closingKmImage': event.closingKmImage ?? '',
        'activityId': event.activityId,
      };

      debugPrint('========================================');
      debugPrint('SHARE LOCATION REQUEST');
      debugPrint('========================================');

      jsonData.forEach((key, value) {
        debugPrint('$key : $value');
      });

      debugPrint('========================================');

      final result = await getPunchStatusUsecase.savePunchDetails(jsonData);

      debugPrint('========================================');
      debugPrint('SHARE LOCATION RESPONSE');
      debugPrint('========================================');
      debugPrint('Status: ${result}');

      debugPrint('========================================');

      if (result['status'] == true) {
        emit(
          state.copyWith(
            quickAccessStatus: QuickAccessStatus.locationAddedSucces,
            // errorMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            quickAccessStatus: QuickAccessStatus.failure,
            // errorMessage: result.message,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('SHARE LOCATION ERROR');
      debugPrint('$e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
