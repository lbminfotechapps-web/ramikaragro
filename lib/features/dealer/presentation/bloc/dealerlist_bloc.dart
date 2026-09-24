import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solufine/features/dealer/domain/repository/dealer_repo.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DealerListBloc extends Bloc<DealerEevent, DealerListState> {
  final DealerListRepository repository;

  DealerListBloc({required this.repository}) : super(const DealerListState()) {
    on<DealerListEvent>(_onLoadDealers);
    on<AddDealerLocation>(_onAddDealerLocation);
  }

  Future<void> _onLoadDealers(
    DealerListEvent event,
    Emitter<DealerListState> emit,
  ) async {
    print('');
    print('========================================');
    print('DEALER BLOC EVENT RECEIVED');
    print('========================================');

    print('User ID     : ${event.user_id}');
    print('Latitude    : ${event.latitude}');
    print('Longitude   : ${event.longitude}');
    print('Search Key  : ${event.searchText}');
    print('Type        : Dealer');

    emit(state.copyWith(status: DealerListStatus.loading));

    print('DEALER BLOC STATUS: LOADING');

    try {
      final dealers = await repository.getDealers(
        event.user_id,
        event.latitude,
        event.longitude,
        event.searchText,
        event.type,
      );

      print('');
      print('========================================');
      print('DEALER BLOC RESPONSE');
      print('========================================');

      print('Dealers received: ${dealers.length}');

      for (final dealer in dealers) {
        print(
          'ID: ${dealer.outletId} | '
          'Name: ${dealer.outletName} | '
          'Mobile: ${dealer.outletPersonMobile} | '
          'Distance: ${dealer.outletDistance}',
        );
      }

      emit(
        state.copyWith(status: DealerListStatus.success, dealerList: dealers),
      );

      print('DEALER BLOC STATUS: SUCCESS');
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('DEALER BLOC ERROR');
      print('========================================');

      print('ERROR: $e');
      print('STACK: $stackTrace');

      emit(
        state.copyWith(
          status: DealerListStatus.failure,
          errorMessage: e.toString(),
        ),
      );

      print('DEALER BLOC STATUS: FAILURE');
    }
  }

  FutureOr<void> _onAddDealerLocation(
    AddDealerLocation event,
    Emitter<DealerListState> emit,
  ) async {
    debugPrint('');
    debugPrint('========================================');
    debugPrint('ADD DEALER LOCATION EVENT RECEIVED');
    debugPrint('========================================');

    // ============================================================
    // 1. PRINT EVENT DATA
    // ============================================================

    debugPrint('Dealer ID              : ${event.dealerId}');
    debugPrint('User ID                : ${event.userId}');
    debugPrint('Location History       : ${event.locationHistoryString}');

    debugPrint('Latitude               : ${event.latitude}');
    debugPrint('Longitude              : ${event.longitude}');

    debugPrint('Network Latitude       : ${event.networkLatitude}');
    debugPrint('Network Longitude      : ${event.networkLongitude}');

    debugPrint('GPS Latitude           : ${event.gpsLatitude}');
    debugPrint('GPS Longitude          : ${event.gpsLongitude}');

    debugPrint('Geo Address            : ${event.geoAddress}');

    debugPrint('Mobile Info            : ${event.mobileInfo}');
    debugPrint('Mobile IMEI            : ${event.mobileImei}');

    debugPrint('Network Info           : ${event.networkInfo}');
    debugPrint('Battery Info           : ${event.batteryInfo}');

    debugPrint('========================================');

    // ============================================================
    // 2. LOADING
    // ============================================================

    emit(
      state.copyWith(
        status: DealerListStatus.addDealerloading,
        errorMessage: null,
      ),
    );

    debugPrint('ADD DEALER LOCATION STATUS: LOADING');

    try {


      final Map<String, dynamic> jsonData = <String, dynamic>{
        'dealerId': event.dealerId,
        'userId': event.userId,

        'locationHistoryString': event.locationHistoryString,

        // Current Location
        'latitude': event.latitude,
        'longitude': event.longitude,

        // Network Location
        'networkLatitude': event.networkLatitude,
        'networkLongitude': event.networkLongitude,

        // GPS Location
        'gpsLatitude': event.gpsLatitude,
        'gpsLongitude': event.gpsLongitude,

        // Address
        'geoAddress': event.geoAddress,

        // Mobile
        'mobile_info': event.mobileInfo,
        'mobile_imei': event.mobileImei,

        // Network / Battery
        'strNetworkInfo': event.networkInfo,
        'strBatteryInfo': event.batteryInfo,
      };

      // ============================================================
      // 4. PRINT FINAL REQUEST
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('ADD DEALER LOCATION REQUEST');
      debugPrint('========================================');

      jsonData.forEach((key, value) {
        debugPrint('$key : $value');
      });

      debugPrint('========================================');

      // ============================================================
      // 5. CALL REPOSITORY
      // ============================================================

      final Map<String, dynamic> response = await repository.addDealerLocation(
        jsonData,
      );

      // ============================================================
      // 6. PRINT RESPONSE
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('ADD DEALER LOCATION RESPONSE');
      debugPrint('========================================');

      debugPrint('FULL RESPONSE : $response');
      debugPrint('STATUS        : ${response['status']}');
      debugPrint('MESSAGE       : ${response['message']}');
      debugPrint('RESULT        : ${response['result']}');

      debugPrint('========================================');

      // ============================================================
      // 7. READ RESPONSE
      // ============================================================

      final dynamic rawStatus = response['status'];

      // Handles:
      // true
      // "true"
      // 1
      // "1"
      final bool apiStatus =
          rawStatus == true ||
          rawStatus?.toString().toLowerCase() == 'true' ||
          rawStatus?.toString() == '1';

      final String message = response['message']?.toString().trim() ?? '';

      final String result = response['result']?.toString().trim() ?? '';

      debugPrint('');
      debugPrint('========================================');
      debugPrint('PARSED DEALER LOCATION RESPONSE');
      debugPrint('========================================');

      debugPrint('API STATUS : $apiStatus');
      debugPrint('MESSAGE    : "$message"');
      debugPrint('RESULT     : "$result"');

      debugPrint('========================================');

      // ============================================================
      // 8. SUCCESS
      // ============================================================

      if (apiStatus) {
        debugPrint('');
        debugPrint('========================================');
        debugPrint('ADD DEALER LOCATION SUCCESS');
        debugPrint('========================================');

        debugPrint('Dealer ID : ${event.dealerId}');
        debugPrint('Message   : $message');
        debugPrint('Result    : $result');

        debugPrint('========================================');

        emit(
          state.copyWith(
            status: DealerListStatus.addDealerLocationSuccess,
            errorMessage: null,
          ),
        );

        return;
      }

      // ============================================================
      // 9. API FAILURE
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('ADD DEALER LOCATION FAILED');
      debugPrint('========================================');

      debugPrint('Dealer ID : ${event.dealerId}');
      debugPrint('Status    : $rawStatus');
      debugPrint('Message   : $message');
      debugPrint('Result    : $result');

      debugPrint('========================================');

      emit(
        state.copyWith(
          status: DealerListStatus.failure,
          errorMessage: message.isNotEmpty
              ? message
              : 'Failed to update dealer location',
        ),
      );
    } catch (e, stackTrace) {
      // ============================================================
      // 10. EXCEPTION
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('ADD DEALER LOCATION ERROR');
      debugPrint('========================================');

      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');

      debugPrint('========================================');

      emit(
        state.copyWith(
          status: DealerListStatus.failure,
          errorMessage: e.toString(),
        ),
      );

      debugPrint('ADD DEALER LOCATION STATUS: FAILURE');
    }
  }
}
