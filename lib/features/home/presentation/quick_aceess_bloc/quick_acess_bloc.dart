import 'dart:async';
import 'dart:math' as math;

import 'package:solufine/core/location_tracking/location_repository.dart';
import 'package:solufine/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:solufine/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAcessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final GetPunchStatusUsecase getPunchStatusUsecase;

  final LocationRepository repository;

  QuickAcessBloc(this.getPunchStatusUsecase, this.repository)
    : super(const QuickAccessState()) {
    on<PunchStatEvent>(_onGetPunchStatus);
    on<SavePunchInLocationEvent>(_onSavePunchInLocation);
    on<VehicleTypeEvent>(_onGetVehicleType);
    on<PunchInOutDetailsAddEvent>(_onPunchInOutAddDetails);
    on<ShareLocationEvent>(_onShareLocationAdd);

    on<SaveNextLocationEvent>(_onSaveNextLocation);
    on<StoreTrackLocation>(_onStoretrackLocation);
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
        debugPrint('PUNCH IN API SUCCESS');
        debugPrint('Saving Punch In location locally');
        debugPrint('========================================');
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

  Future<void> _onSavePunchInLocation(
    SavePunchInLocationEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    try {
      debugPrint('========================================');
      debugPrint('LOCATION TRACKING');
      debugPrint('Saving Punch In location');
      debugPrint('User ID: ${event.userId}');
      debugPrint('Latitude: ${event.latitude}');
      debugPrint('Longitude: ${event.longitude}');
      debugPrint('Address: ${event.geoAddress}');
      debugPrint('Accuracy: ${event.accuracy}');
      debugPrint('Provider: ${event.provider}');
      debugPrint('Timestamp: ${event.capturedAt}');
      debugPrint('========================================');

      await repository.saveLocation(
        userId: event.userId,
        latitude: event.latitude,
        longitude: event.longitude,
        geoAddress: event.geoAddress,
        capturedAt: event.capturedAt,
        accuracy: event.accuracy,
        provider: event.provider,
        distance: 0.0,
      );

      debugPrint('LOCATION TRACKING: Punch In location saved');

      // TEMPORARY VERIFICATION
      final savedLocations = await repository.getAllLocations(event.userId);

      debugPrint('========================================');
      debugPrint('SAVED LOCATION RECORDS');
      debugPrint('Total records: ${savedLocations.length}');

      for (final location in savedLocations) {
        debugPrint(
          'ID: ${location.id} | '
          'UserId: ${location.userId} | '
          'Lat: ${location.latitude} | '
          'Lng: ${location.longitude} | '
          'Address: ${location.geoAddress} | '
          'Time: ${location.capturedAt} | '
          'Accuracy: ${location.accuracy} | '
          'Provider: ${location.provider} | '
          'Distance: ${location.distance}',
        );
      }

      debugPrint('========================================');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.locationTrackingSucess,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('LOCATION TRACKING ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveNextLocation(
    SaveNextLocationEvent event,
    Emitter<QuickAccessState> emit,
  ) async {
    try {
      debugPrint('========================================');
      debugPrint('NEXT LOCATION TRACKING');
      debugPrint('Saving next location');
      debugPrint('User ID: ${event.userId}');
      debugPrint('Latitude: ${event.latitude}');
      debugPrint('Longitude: ${event.longitude}');
      debugPrint('Address: ${event.geoAddress}');
      debugPrint('Accuracy: ${event.accuracy}');
      debugPrint('Provider: ${event.provider}');
      debugPrint('Timestamp: ${event.capturedAt}');
      debugPrint('========================================');

      final previousLocation = await repository.getLastLocation(event.userId);

      double distance = 0.0;

      if (previousLocation != null) {
        final previousLatitude = double.tryParse(previousLocation.latitude);

        final previousLongitude = double.tryParse(previousLocation.longitude);

        final currentLatitude = double.tryParse(event.latitude);

        final currentLongitude = double.tryParse(event.longitude);

        if (previousLatitude != null &&
            previousLongitude != null &&
            currentLatitude != null &&
            currentLongitude != null) {
          distance = _calculateDistanceInMeters(
            previousLatitude,
            previousLongitude,
            currentLatitude,
            currentLongitude,
          );
        }
      }

      debugPrint(
        'Distance from previous location: '
        '${distance.toStringAsFixed(2)} meters',
      );

      await repository.saveLocation(
        userId: event.userId,
        latitude: event.latitude,
        longitude: event.longitude,
        geoAddress: event.geoAddress,
        capturedAt: event.capturedAt,
        accuracy: event.accuracy,
        provider: event.provider,
        distance: distance,
      );

      debugPrint('NEXT LOCATION SAVED SUCCESSFULLY');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.locationTrackingSucess,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('NEXT LOCATION ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      emit(
        state.copyWith(
          quickAccessStatus: QuickAccessStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  double _calculateDistanceInMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadius = 6371000.0;

    final lat1 = latitude1 * math.pi / 180;
    final lat2 = latitude2 * math.pi / 180;

    final deltaLat = (latitude2 - latitude1) * math.pi / 180;

    final deltaLongitude = (longitude2 - longitude1) * math.pi / 180;

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
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

  FutureOr<void> _onStoretrackLocation(
    StoreTrackLocation event,
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
        'userId': event.userId,
        'dailyTranId': event.dailyTranId,
        'strAllLocations': event.strAllLocations,
      };

      debugPrint('========================================');
      debugPrint('STORE LOCATION REQUEST');
      debugPrint('========================================');

      jsonData.forEach((key, value) {
        debugPrint('$key : $value');
      });

      debugPrint('========================================');

      final result = await getPunchStatusUsecase.storeLocationData(jsonData);

      debugPrint('========================================');
      debugPrint('STORE LOCATION RESPONSE');
      debugPrint('========================================');
      debugPrint('Status: ${result}');

      debugPrint('========================================');

      if (result['status'] == true) {
        debugPrint('========================================');
        debugPrint('STORE LOCATION API SUCCESS');
        debugPrint('Now cleaning local location records...');
        debugPrint('========================================');

        final int? parsedUserId = int.tryParse(event.userId);

        if (parsedUserId != null) {
          // --------------------------------------------------------
          // DELETE EVERYTHING EXCEPT LATEST LOCATION
          // --------------------------------------------------------

          final int deletedCount = await repository.deleteAllExceptLastLocation(
            parsedUserId,
          );

          debugPrint('========================================');
          debugPrint('LOCATION CLEANUP SUCCESS');
          debugPrint('DELETED RECORDS: $deletedCount');
          debugPrint('LAST LOCATION KEPT');
          debugPrint('========================================');

          // --------------------------------------------------------
          // TEMPORARY VERIFICATION
          // --------------------------------------------------------

          final remainingLocations = await repository.getAllLocations(
            parsedUserId,
          );

          debugPrint('========================================');
          debugPrint('REMAINING LOCATION RECORDS');
          debugPrint('TOTAL: ${remainingLocations.length}');

          for (final location in remainingLocations) {
            debugPrint(
              'ID: ${location.id} | '
              'Lat: ${location.latitude} | '
              'Lng: ${location.longitude} | '
              'Time: ${location.capturedAt} | '
              'Accuracy: ${location.accuracy} | '
              'Provider: ${location.provider} | '
              'Address: ${location.geoAddress} | '
              'Distance: ${location.distance}',
            );
          }

          debugPrint('========================================');
        } else {
          debugPrint('LOCATION CLEANUP: Invalid userId ${event.userId}');
        }

        emit(
          state.copyWith(
            quickAccessStatus: QuickAccessStatus.locationAddedSucces,
            errorMessage: null,
          ),
        );
      } else {
        emit(state.copyWith(quickAccessStatus: QuickAccessStatus.failure));
      }
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('STORE LOCATION ERROR');
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
