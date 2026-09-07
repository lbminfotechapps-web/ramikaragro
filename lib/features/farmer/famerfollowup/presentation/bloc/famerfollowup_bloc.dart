import 'dart:convert';

import 'package:demo/features/farmer/famerfollowup/domain/repository/famerfollowup_repository.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_event.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamerfollowupBloc extends Bloc<FamerfollowupEvent, FamerfollowupState> {
  final FamerfollowupRepository repository;

  FamerfollowupBloc({required this.repository})
    : super(const FamerfollowupState()) {
    on<SubmitFollowupEvent>(_submitFollowup);
    on<GetRemarkHistoryEvent>(_getRemarkHistory);
  }

  Future<void> _submitFollowup(
    SubmitFollowupEvent event,
    Emitter<FamerfollowupState> emit,
  ) async {
    emit(
      state.copyWith(status: FamerfollowupStatus.loading, errorMessage: null),
    );

    debugPrint('FAMER FOLLOWUP STATUS: LOADING');

    try {
      debugPrint('Calling repository.submitFollowup()...');

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

      debugPrint('Repository response received');
      debugPrint('Response object: $response');
      debugPrint('Response status: ${response.status}');
      debugPrint('Response status type: ${response.status.runtimeType}');

      final rawStatus = response.status.trim();

      debugPrint('RAW RESPONSE STATUS = [$rawStatus]');

      String status = rawStatus;

      try {
        if (rawStatus.startsWith('{')) {
          final decoded = jsonDecode(rawStatus);

          if (decoded is Map) {
            status = decoded['status']?.toString().trim() ?? '';
          }
        }
      } catch (e) {
        debugPrint('STATUS JSON PARSE ERROR: $e');
      }

      debugPrint('FINAL API STATUS = [$status]');

      if (status.toLowerCase().startsWith('success')) {
        debugPrint('==========================================');
        debugPrint('FAMER FOLLOWUP SUBMIT SUCCESS');
        debugPrint('API STATUS: $status');
        debugPrint('==========================================');

        emit(
          state.copyWith(
            status: FamerfollowupStatus.success,
            errorMessage: null,
          ),
        );
      } else {
        debugPrint('==========================================');
        debugPrint('FAMER FOLLOWUP SUBMIT FAILURE');
        debugPrint('API STATUS: $status');
        debugPrint('==========================================');

        emit(
          state.copyWith(
            status: FamerfollowupStatus.failure,
            errorMessage: 'Failed to submit record',
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('==========================================');
      debugPrint('FAMER FOLLOWUP SUBMIT EXCEPTION');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('==========================================');

      emit(
        state.copyWith(
          status: FamerfollowupStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _getRemarkHistory(
    GetRemarkHistoryEvent event,
    Emitter<FamerfollowupState> emit,
  ) async {
    emit(
      state.copyWith(
        historyStatus: FollowupHistoryStatus.loading,
        historyError: null,
        historyList: [],
      ),
    );

    try {
      debugPrint('========== HISTORY API ==========');
      debugPrint('FARMER ID: ${event.farmerId}');

      final response = await repository.getRemarkHistory(
        farmerId: event.farmerId,
      );

      debugPrint('HISTORY RESPONSE COUNT: ${response.length}');
      debugPrint('HISTORY RESPONSE: $response');

      emit(
        state.copyWith(
          historyStatus: FollowupHistoryStatus.success,
          historyList: response,
          historyError: null,
        ),
      );

      debugPrint('STATE HISTORY LIST COUNT: ${response.length}');
    } catch (e, stackTrace) {
      debugPrint('HISTORY ERROR: $e');
      debugPrint('STACKTRACE: $stackTrace');

      emit(
        state.copyWith(
          historyStatus: FollowupHistoryStatus.failure,
          historyError: e.toString(),
        ),
      );
    }
  }
}
