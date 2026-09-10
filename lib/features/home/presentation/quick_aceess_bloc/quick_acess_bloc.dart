import 'dart:async';
import 'dart:io';

import 'package:demo/core/utility/image_compression.dart';
import 'package:demo/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAcessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final GetPunchStatusUsecase getPunchStatusUsecase;

  QuickAcessBloc(this.getPunchStatusUsecase) : super(const QuickAccessState()) {
    on<PunchStatEvent>(_onGetPunchStatus);
    on<VehicleTypeEvent>(_onGetVehicleType);
    on<PunchInOutDetailsAddEvent>(_onPunchInOutAddDetails);
  }

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
      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.success,
          punchStat: punchStat,
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
      File? startingKmFile;
      File? closingKmFile;

      // ============================================
      // COMPRESS STARTING KM IMAGE
      // ============================================
      if (event.startingKmImage.isNotEmpty) {
        final originalFile = File(event.startingKmImage);

        if (await originalFile.exists()) {
          startingKmFile = await ImageCompression.compressImage(
            originalFile,
            maxWidth: 450,
            maxHeight: 450,
            quality: 45,
          );

          if (startingKmFile == null) {
            throw Exception('Unable to compress starting KM image');
          }
        } else {
          print(
            'Starting KM image file not found: '
            '${event.startingKmImage}',
          );
        }
      }

      // ============================================
      // COMPRESS CLOSING KM IMAGE
      // ============================================
      if (event.closingKmImage.isNotEmpty) {
        final originalFile = File(event.closingKmImage);

        if (await originalFile.exists()) {
          closingKmFile = await ImageCompression.compressImage(
            originalFile,
            maxWidth: 450,
            maxHeight: 450,
            quality: 45,
          );

          if (closingKmFile == null) {
            throw Exception('Unable to compress closing KM image');
          }
        } else {
          print(
            'Closing KM image file not found: '
            '${event.closingKmImage}',
          );
        }
      }

      // ============================================
      // REQUEST DATA
      // ============================================
      final jsonData = <String, dynamic>{
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
        'date': event.date,
        "time": event.newTime,
        "isForceOutPunch": event.isForceOutPunch,
      };

      // ============================================
      // ADD STARTING IMAGE FILE
      // ============================================
      if (startingKmFile != null) {
        jsonData['startingKmImage'] = startingKmFile;
      }

      // ============================================
      // ADD CLOSING IMAGE FILE
      // ============================================
      if (closingKmFile != null) {
        jsonData['closingKmImage'] = closingKmFile;
      }

      // ============================================
      // DEBUG
      // ============================================
      print('========== PUNCH REQUEST ==========');
      print('user_id: ${event.userId}');
      print('date: ${event.date}');
      print('newTime: ${event.newTime}');
      print('isForceOut: ${event.isForceOutPunch}');
      print('in_out_status: ${event.inOutStatus}');
      print('vehicle_type_id: ${event.vehicleTypeId}');
      print(
        'starting_km_amount: '
        '${event.startingClosingKmAmount}',
      );
      print('route: ${event.route}');
      print('latitude: ${event.latitude}');
      print('longitude: ${event.longitude}');
      print('activity_id: ${event.activityId}');

      print(
        'starting_image: '
        '${startingKmFile?.path ?? 'NO FILE'}',
      );

      print(
        'closing_image: '
        '${closingKmFile?.path ?? 'NO FILE'}',
      );

      print('===================================');

      // ============================================
      // CALL API
      // ============================================
      final response = await getPunchStatusUsecase.savePunchDetails(jsonData);

      print('Punch details response: $response');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.success,
          errorMessage: null,
        ),
      );
    } catch (error) {
      print('Punch details error: $error');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
