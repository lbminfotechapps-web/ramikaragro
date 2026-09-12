import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

import '../models/team_expense_model.dart';

class TeamExpenseRemoteDatasource {
  final DioClient dioClient;

  TeamExpenseRemoteDatasource(this.dioClient);

  // ===========================================================================
  // GET TEAM EXPENSES
  // ===========================================================================

  Future<List<TeamExpenseModel>> getTeamExpenses({
    required int userId,
    required String fromDate,
    required String toDate,
    required String searchText,
    required int startLimit,
  }) async {
    final formData = FormData.fromMap({
      'userId': userId.toString(),
      'fromDate': fromDate,
      'toDate': toDate,
      'searchText': searchText,
      'startLimit': startLimit.toString(),
    });

    final response = await dioClient.client.post(
      ApiClient.getMyEmployeeExpensesList,
      data: formData,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    print('Team Expense Response: ${response.data}');

    final String responseString =
        response.data.toString().trim();

    if (responseString.isEmpty) {
      throw Exception('Empty response from team expense API');
    }

    final Map<String, dynamic> jsonResponse =
        jsonDecode(responseString);

    final bool status =
        jsonResponse['status'] == true;

    if (!status) {
      return [];
    }

    final List result =
        jsonResponse['result'] ?? [];

    return result
        .map(
          (e) => TeamExpenseModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // APPROVE / REJECT EXPENSE
  // ===========================================================================

  Future<bool> updateTeamExpense({
    required int userId,
    required String expenseId,
    required String expenseJson,
    required String expenseStatus,
    required String remark,
  }) async {
    final formData = FormData.fromMap({
      'userId': userId.toString(),
      'expense_id': expenseId,
      'expenseJson': expenseJson,
      'expenseStatus': expenseStatus,
      'remark': remark,
    });

    print('==========================================');
    print('UPDATE EXPENSE API');
    print('userId: $userId');
    print('expense_id: $expenseId');
    print('expenseJson: $expenseJson');
    print('expenseStatus: $expenseStatus');
    print('remark: $remark');
    print('==========================================');

    final response = await dioClient.client.post(
      ApiClient.update_expenses,
      data: formData,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    print(
      'Update Expense Response: ${response.data}',
    );

    final String responseString =
        response.data.toString().trim();

    if (responseString.isEmpty) {
      throw Exception(
        'Empty response from update expense API',
      );
    }

    final Map<String, dynamic> jsonResponse =
        jsonDecode(responseString);

    final bool statusSuccess =
        jsonResponse['status'] == true;

    if (!statusSuccess) {
      throw Exception(
        jsonResponse['message']?.toString() ??
            'Unable to update expense',
      );
    }

    return true;
  }
}