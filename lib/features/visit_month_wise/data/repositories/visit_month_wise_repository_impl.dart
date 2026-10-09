import 'package:solufine/features/visit_month_wise/domain/entities/visit_day_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_frequency.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_geo_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_hour_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_top_employee.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_top_list.dart';

import '../../domain/entities/visit_month_wise.dart';
import '../../domain/entities/visit_report_employee.dart';

import '../../domain/repositories/visit_month_wise_repository.dart';

import '../datasources/visit_month_wise_remote_datasource.dart';

class VisitMonthWiseRepositoryImpl implements VisitMonthWiseRepository {
  final VisitMonthWiseRemoteDataSource remoteDataSource;

  VisitMonthWiseRepositoryImpl({required this.remoteDataSource});

  // ============================================================
  // REPORT
  // ============================================================

  @override
  Future<VisitMonthWiseReport> getVisitMonthWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitMonthWise(
      fromDate: fromDate,

      toDate: toDate,

      employeeId: employeeId,
    );
  }

  // ============================================================
  // DAY WISE
  // ============================================================

  @override
  Future<VisitDayWiseReport> getVisitDayWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitDayWise(
      fromDate: fromDate,

      toDate: toDate,

      employeeId: employeeId,
    );
  }

  // ============================================================
  //  HOURS WISE
  // ============================================================

  @override
  Future<VisitHourWiseReport> getVisitHourWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitHourWise(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }

  // ============================================================
  // VISIT FREQUENCY
  // ============================================================

  @override
  Future<VisitFrequencyReport> getVisitFrequency({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitFrequency(
      fromDate: fromDate,

      toDate: toDate,

      employeeId: employeeId,
    );
  }

  @override
  Future<VisitGeoWiseReport> getVisitGeoWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitGeoWise(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }

  @override
  Future<VisitTopListReport> getVisitTopList({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) {
    return remoteDataSource.getVisitTopList(
      fromDate: fromDate,

      toDate: toDate,

      employeeId: employeeId,
    );
  }



  @override
Future<VisitTopEmployeeReport>
    getVisitTopEmployee({
  required String fromDate,
  required String toDate,
  required String employeeId,
}) {
  return remoteDataSource
      .getVisitTopEmployee(
    fromDate: fromDate,
    toDate: toDate,
    employeeId: employeeId,
  );
}

  // ============================================================
  // EMPLOYEES
  // ============================================================

  @override
  Future<List<VisitReportEmployee>> getAssignedEmployees({
    required String userId,
    required String searchText,
  }) {
    return remoteDataSource.getAssignedEmployees(
      userId: userId,

      searchText: searchText,
    );
  }
}
