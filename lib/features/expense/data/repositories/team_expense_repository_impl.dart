import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/expense/data/datasources/team_expense_remote_datasource.dart';
import 'package:demo/features/expense/domain/entities/team_expense_entity.dart';
import 'package:demo/features/expense/domain/repositories/team_expense_repository.dart';
import 'package:dio/dio.dart';

import '../models/team_expense_model.dart';


class TeamExpenseRemoteImpl
    implements TeamExpenseRepository {
  final TeamExpenseRemoteDatasource teamExpenseRemoteDatasource;

  TeamExpenseRemoteImpl(this.teamExpenseRemoteDatasource);



  @override
  Future<List<TeamExpenseEntity>> getTeamExpenses({required int userId, required String fromDate, required String toDate, required String searchText, required int startLimit}) {
  
   return teamExpenseRemoteDatasource.getTeamExpenses(userId: userId, fromDate: fromDate, toDate: toDate, searchText: searchText, startLimit: startLimit);
  }

  @override
  Future<bool> updateTeamExpense({required int userId, required String expenseId, required String expenseJson, required String expenseStatus, required String remark}) {
  return teamExpenseRemoteDatasource.updateTeamExpense(userId: userId, expenseId: expenseId, expenseJson: expenseJson, expenseStatus: expenseStatus, remark: remark);
  }

  
}