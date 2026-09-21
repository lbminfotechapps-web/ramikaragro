import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/addexpense/data/model/expense_parameter_model.dart';
import 'package:solufine/features/addexpense/data/model/vehicle_model.dart';
import 'package:dio/dio.dart';

abstract class ExpenseRemoteDatasource {
  Future<List<VehicleModel>> getVehicles({
    required String userId,
    required String lastDate,
  });

  Future<List<ExpenseParameterModel>> getExpenseParameters({
    required String userId,
  });

  Future<Map<String, dynamic>> getDAAmount({
    required String userId,
    required String expenseDate,
  });

  Future<Map<String, dynamic>> getExpenseDays({
    required String userId,
    required String expenseDate,
  });

  Future<int> checkExpenseStatus({
    required String userId,
    required String expenseDate,
  });

  Future<bool> submitExpense({required Map<String, String> fields});
}

class ExpenseRemoteDatasourceImpl implements ExpenseRemoteDatasource {
  final DioClient dioClient;

  ExpenseRemoteDatasourceImpl(this.dioClient);

  // ============================================================
  // 1. GET VEHICLES
  // ============================================================

  @override
  Future<List<VehicleModel>> getVehicles({
    required String userId,
    required String lastDate,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getVehicleType,
        data: FormData.fromMap({'userId': userId, 'lastDate': lastDate}),
      );

      // ----------------------------------------------------------
      // HTTP ERROR
      // ----------------------------------------------------------

      if (response.statusCode != 200) {
        throw Exception(
          'Get Vehicles API failed. '
          'Status Code: ${response.statusCode}\n'
          'Response: ${response.data}',
        );
      }

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = responseData.trim();

        if (responseData.isEmpty) {
          throw Exception('Get Vehicles API returned empty response.');
        }

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw Exception(
            'Unable to decode Get Vehicles API response.\n'
            'Raw response:\n$responseData',
          );
        }
      }

      // ----------------------------------------------------------
      // VALIDATE JSON
      // ----------------------------------------------------------

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid Get Vehicles API response format.');
      }

      final bool status =
          responseData['status'] == true ||
          responseData['status'].toString().toLowerCase() == 'true';

      print('API STATUS: $status');
      print('API MESSAGE: ${responseData['message']}');

      if (!status) {
        print(
          'GET VEHICLES API: '
          '${responseData['message'] ?? 'No Record Found'}',
        );

        return [];
      }

      // ----------------------------------------------------------
      // RESULT
      // ----------------------------------------------------------

      final result = responseData['result'];

      if (result == null) {
        print('GET VEHICLES API: result is null');
        return [];
      }

      if (result is! List) {
        throw Exception('Invalid result format from Get Vehicles API.');
      }

      // ----------------------------------------------------------
      // MODEL
      // ----------------------------------------------------------

      final List<VehicleModel> vehicles = result
          .whereType<Map>()
          .map((json) => VehicleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      return vehicles;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Get Vehicles API request failed.',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 2. GET EXPENSE PARAMETERS
  // ============================================================

  @override
  Future<List<ExpenseParameterModel>> getExpenseParameters({
    required String userId,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getExpenseParameters,
        data: FormData.fromMap({'userId': userId}),
      );

      // ----------------------------------------------------------
      // HTTP ERROR
      // ----------------------------------------------------------

      if (response.statusCode != 200) {
        throw Exception(
          'Get Expense Parameters API failed. '
          'Status Code: ${response.statusCode}\n'
          'Response: ${response.data}',
        );
      }

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = responseData.trim();

        if (responseData.isEmpty) {
          throw Exception(
            'Get Expense Parameters API returned empty response.',
          );
        }

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw Exception(
            'Unable to decode Get Expense Parameters API response.\n'
            'Raw response:\n$responseData',
          );
        }
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid Get Expense Parameters API response format.');
      }

      final bool status =
          responseData['status'] == true ||
          responseData['status'].toString().toLowerCase() == 'true';

      if (!status) {
        print(
          'GET EXPENSE PARAMETERS API: '
          '${responseData['message'] ?? 'No Record Found'}',
        );

        return [];
      }

      // ----------------------------------------------------------
      // RESULT
      // ----------------------------------------------------------

      final result = responseData['result'];

      if (result == null) {
        print('GET EXPENSE PARAMETERS API: result is null');
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid result format from Get Expense Parameters API.',
        );
      }
      // ----------------------------------------------------------
      // MODEL
      // ----------------------------------------------------------

      final List<ExpenseParameterModel> parameters = result
          .whereType<Map>()
          .map(
            (json) =>
                ExpenseParameterModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      return parameters;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Get Expense Parameters API request failed.',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 3. GET DA AMOUNT
  // ============================================================

  @override
  Future<Map<String, dynamic>> getDAAmount({
    required String userId,
    required String expenseDate,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getDAAmount,
        data: FormData.fromMap({'userId': userId, 'expenseDate': expenseDate}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Get DA Amount API failed. '
          'Status Code: ${response.statusCode}\n'
          'Response: ${response.data}',
        );
      }

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = responseData.trim();

        if (responseData.isEmpty) {
          throw Exception('Get DA Amount API returned empty response.');
        }

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw Exception(
            'Unable to decode Get DA Amount API response.\n'
            'Raw response:\n$responseData',
          );
        }
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid Get DA Amount API response format.');
      }

      final bool status =
          responseData['status'] == true ||
          responseData['status'].toString().toLowerCase() == 'true';

      print('API STATUS: $status');
      print('API MESSAGE: ${responseData['message']}');

      if (!status) {
        print(
          'GET DA AMOUNT API: '
          '${responseData['message'] ?? 'No Record Found'}',
        );

        return {};
      }

      // ----------------------------------------------------------
      // RESULT
      // ----------------------------------------------------------

      final result = responseData['result'];

      if (result == null) {
        print('GET DA AMOUNT API: result is null');
        return {};
      }

      if (result is! List || result.isEmpty) {
        print('GET DA AMOUNT API: result is empty');
        return {};
      }

      final resultData = result.first;

      if (resultData is! Map) {
        throw Exception('Invalid result format from Get DA Amount API.');
      }

      final daAmount = Map<String, dynamic>.from(resultData);

      print('DA AMOUNT DATA: $daAmount');
      print('==========================================');

      return daAmount;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Get DA Amount API request failed.',
      );
    } catch (e) {
      print('==========================================');
      print('GET DA AMOUNT API ERROR');
      print('ERROR: $e');
      print('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // 4. GET EXPENSE DAYS
  // ============================================================

  Future<Map<String, dynamic>> getExpenseDays({
    required String userId,
    required String expenseDate,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getExpensesStatus,
        data: FormData.fromMap({
          'userId': userId,
          'expenses_date': expenseDate,
        }),
      );

      dynamic data = response.data;

      if (data is String) {
        data = jsonDecode(data.trim());
      }

      if (data is! Map) {
        return {};
      }

      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      return {};
    } catch (e, stackTrace) {
      return {};
    }
  }

  // ============================================================
  // 5. CHECK EXPENSE STATUS
  // ============================================================

  Future<int> checkExpenseStatus({
    required String userId,
    required String expenseDate,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getExpensesStatus,
        data: FormData.fromMap({
          'user_id': userId,
          'expenses_date': expenseDate,
        }),
      );

      if (response.statusCode != 200) {
        print('CHECK EXPENSE STATUS FAILED');
        return 0;
      }

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData.trim());
      }

      print('API STATUS: ${responseData['status']}');
      print('API MESSAGE: ${responseData['message']}');

      final result = responseData['result'];

      if (result is List && result.isNotEmpty) {
        final firstResult = result.first;

        final expStatus =
            int.tryParse(firstResult['exp_status']?.toString() ?? '') ?? 0;

        final allowDay = firstResult['allow_day']?.toString() ?? '';

        return expStatus;
      }

      print('NO EXPENSE STATUS RESULT FOUND');
      print('====================================================');

      return 0;
    } on DioException catch (e) {
      return 0;
    } catch (e, stackTrace) {
      return 0;
    }
  }
  // ============================================================
  // 6. SUBMIT EXPENSE
  // ============================================================

  @override
  Future<bool> submitExpense({required Map<String, String> fields}) async {
    try {
      final formData = FormData.fromMap(fields);

      final response = await dioClient.client.post(
        ApiClient.addExpenseDetails,
        data: formData,
      );

      // ----------------------------------------------------------
      // HTTP ERROR
      // ----------------------------------------------------------

      if (response.statusCode != 200) {
        throw Exception(
          'Submit Expense API failed. '
          'Status Code: ${response.statusCode}\n'
          'Response: ${response.data}',
        );
      }

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = responseData.trim();

        if (responseData.isEmpty) {
          throw Exception('Submit Expense API returned empty response.');
        }

        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('JSON DECODE ERROR: $e');

          throw Exception(
            'Unable to decode Submit Expense API response.\n'
            'Raw response:\n$responseData',
          );
        }
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid Submit Expense API response format.');
      }

      final bool status =
          responseData['status'] == true ||
          responseData['status'].toString().toLowerCase() == 'true';

      print('API STATUS: $status');
      print('API MESSAGE: ${responseData['message']}');

      print('==========================================');

      return status;
    } on DioException catch (e) {
      print('==========================================');
      print('SUBMIT EXPENSE DIO ERROR');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('REQUEST URL: ${e.requestOptions.uri}');
      print('SERVER RESPONSE: ${e.response?.data}');
      print('==========================================');

      if (e.response?.statusCode == 404) {
        throw Exception('Expense API endpoint not found.');
      }

      throw Exception(
        'Unable to submit expense.\n'
        'Status Code: ${e.response?.statusCode ?? 'Unknown'}',
      );
    } catch (e) {
      print('==========================================');
      print('SUBMIT EXPENSE API ERROR');
      print('ERROR: $e');
      print('==========================================');

      rethrow;
    }
  }
}
