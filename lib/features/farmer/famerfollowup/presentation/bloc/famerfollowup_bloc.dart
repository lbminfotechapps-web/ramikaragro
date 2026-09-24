import 'dart:convert';
import 'dart:io';

import 'package:solufine/core/utility/image_compression.dart';
import 'package:solufine/features/farmer/famerfollowup/domain/repository/famerfollowup_repository.dart';
import 'package:solufine/features/farmer/famerfollowup/presentation/bloc/famerfollowup_event.dart';
import 'package:solufine/features/farmer/famerfollowup/presentation/bloc/famerfollowup_state.dart';
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
      // ============================================================
      // 1. CHECK + COMPRESS FOLLOWUP IMAGE
      // ============================================================

      File? followupImageFile;

      debugPrint('==========================================');
      debugPrint('FOLLOWUP IMAGE CHECK');
      debugPrint('EVENT IMAGE PATH: ${event.imagePath}');
      debugPrint('==========================================');

      if (event.imagePath != null && event.imagePath!.trim().isNotEmpty) {
        final originalFile = File(event.imagePath!.trim());

        final bool exists = await originalFile.exists();

        debugPrint('ORIGINAL IMAGE EXISTS: $exists');

        if (exists) {
          debugPrint('ORIGINAL IMAGE PATH: ${originalFile.path}');

          debugPrint(
            'ORIGINAL IMAGE SIZE: '
            '${await originalFile.length()} bytes',
          );

          // ========================================================
          // COMPRESS IMAGE
          // Same as Farmer Add
          // ========================================================

          final compressedFile = await ImageCompression.compressImage(
            originalFile,
            maxWidth: 450,
            maxHeight: 450,
            quality: 45,
          );

          // ========================================================
          // USE COMPRESSED IMAGE IF AVAILABLE
          // OTHERWISE USE ORIGINAL IMAGE
          // ========================================================

          if (compressedFile != null && await compressedFile.exists()) {
            followupImageFile = compressedFile;

            debugPrint('USING COMPRESSED FOLLOWUP IMAGE');

            debugPrint(
              'COMPRESSED PATH: '
              '${followupImageFile.path}',
            );

            debugPrint(
              'COMPRESSED SIZE: '
              '${await followupImageFile.length()} bytes',
            );
          } else {
            followupImageFile = originalFile;

            debugPrint(
              'COMPRESSION FAILED - '
              'USING ORIGINAL FOLLOWUP IMAGE',
            );

            debugPrint(
              'IMAGE PATH: '
              '${followupImageFile.path}',
            );

            debugPrint(
              'IMAGE SIZE: '
              '${await followupImageFile.length()} bytes',
            );
          }
        } else {
          debugPrint('FOLLOWUP IMAGE FILE DOES NOT EXIST');
        }
      } else {
        debugPrint('FOLLOWUP IMAGE NOT SELECTED');
      }

      // ============================================================
      // 2. PRINT FINAL IMAGE BEING SENT
      // ============================================================

      debugPrint('==========================================');
      debugPrint('FOLLOWUP IMAGE TO REPOSITORY');
      debugPrint('==========================================');

      if (followupImageFile != null) {
        debugPrint('IMAGE AVAILABLE');

        debugPrint('PATH: ${followupImageFile.path}');

        debugPrint('EXISTS: ${await followupImageFile.exists()}');

        debugPrint('SIZE: ${await followupImageFile.length()} bytes');
      } else {
        debugPrint('IMAGE FILE IS NULL');
      }

      debugPrint('==========================================');

      // ============================================================
      // 3. CALL REPOSITORY
      // ALL EXISTING PARAMETERS REMAIN SAME
      // ============================================================

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

        // ==========================================================
        // IMPORTANT CHANGE
        // Pass compressed/original final image path
        // ==========================================================
        imagePath: followupImageFile?.path,
      );

      // ============================================================
      // 4. RESPONSE
      // ============================================================

      debugPrint('Repository response received');
      debugPrint('Response object: $response');
      debugPrint('Response status: ${response.status}');
      debugPrint(
        'Response status type: '
        '${response.status.runtimeType}',
      );

      final rawStatus = response.status.trim();

      debugPrint('RAW RESPONSE STATUS = [$rawStatus]');

      String status = rawStatus;

      // ============================================================
      // 5. HANDLE STRING/JSON STATUS
      // ============================================================

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

      // ============================================================
      // 6. SUCCESS / FAILURE
      // ============================================================

      if (status.toLowerCase().startsWith('success')) {
        debugPrint('==========================================');
        debugPrint('FAMER FOLLOWUP SUBMIT SUCCESS');
        debugPrint('API STATUS: $status');
        debugPrint('==========================================');

        emit(
          state.copyWith(
            status: FamerfollowupStatus.farmerFollowUpSuccess,
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

  /*
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
            status: FamerfollowupStatus.farmerFollowUpSuccess,
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


  */

  Future<void> _getRemarkHistory(
    GetRemarkHistoryEvent event,
    Emitter<FamerfollowupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FamerfollowupStatus.loading,
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
          status: FamerfollowupStatus.farmerHistorySuccess,
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
          status: FamerfollowupStatus.failure,
          historyError: e.toString(),
        ),
      );
    }
  }
}
