import 'dart:convert';

import 'package:demo/features/reports/data/modles/not_visited_dealer_model.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/not_visited_dealer.dart';
import '../../domain/repositories/dealer_repository.dart';
import '../datasources/dealer_remote_data_source.dart';

class DealerRepositoryImpl
    implements DealerRepository {
  final DealerRemoteDataSource dataSource;

  DealerRepositoryImpl(
    this.dataSource,
  );

  @override
  Future<List<NotVisitedDealer>>
      getNotVisitedDealers({
    required int days,
    required int startLimit,
  }) async {
    try {
      final Response response =
          await dataSource
              .getNotVisitedDealers(
        days: days,
        startLimit: startLimit,
      );

      dynamic data = response.data;

      // =========================================================
      // STRING → JSON
      // =========================================================

      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          throw ServerException(
            'Invalid JSON response from server',
          );
        }
      }

      // =========================================================
      // CHECK MAP
      // =========================================================

      if (data is! Map<String, dynamic>) {
        throw ServerException(
          'Invalid server response',
        );
      }

      // =========================================================
      // STATUS
      // =========================================================

      final status = data['status'];

      // If your API returns true
      if (status != true) {
        throw ServerException(
          data['message']?.toString() ??
              'Failed to fetch dealers',
        );
      }

      // =========================================================
      // RESULT
      // =========================================================

      final result = data['result'];

      if (result is! List) {
        throw ServerException(
          'Invalid result format',
        );
      }

      // =========================================================
      // MODEL
      // =========================================================

      final List<NotVisitedDealer>
          dealers =
          result.map<NotVisitedDealer>(
        (json) {
          return NotVisitedDealerModel
              .fromJson(
            Map<String, dynamic>.from(
              json,
            ),
          );
        },
      ).toList();

      print(
        'Repository received: ${dealers.length}',
      );

      return dealers;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error',
      );
    } catch (e) {
      throw ServerException(
        'Failed to get not visited dealers: $e',
      );
    }
  }
}