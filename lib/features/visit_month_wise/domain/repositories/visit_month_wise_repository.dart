import 'package:solufine/features/visit_month_wise/domain/entities/visit_day_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_frequency.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_geo_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_hour_wise.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_top_employee.dart';
import 'package:solufine/features/visit_month_wise/domain/entities/visit_top_list.dart';

import '../entities/visit_month_wise.dart';
import '../entities/visit_report_employee.dart';

abstract class VisitMonthWiseRepository {


  // ============================================================
  // EMPLOYEES
  // ============================================================

  Future<List<VisitReportEmployee>>
      getAssignedEmployees({
    required String userId,
    required String searchText,
  });


  // ============================================================
  // MONTH WISE REPORT
  // ============================================================

  Future<VisitMonthWiseReport>
      getVisitMonthWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

   // ============================================================
  // DAY WISE
  // ============================================================

  Future<VisitDayWiseReport>
      getVisitDayWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });


 // ============================================================
  // Hour WISE
  // ============================================================
    Future<VisitHourWiseReport> getVisitHourWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

 // ============================================================
  // Visit Frequency Report
  // ============================================================

  Future<VisitFrequencyReport>
    getVisitFrequency({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

 Future<VisitGeoWiseReport> getVisitGeoWise({
    required String fromDate,
    required String toDate,
    required String employeeId,
  });

Future<VisitTopListReport>
    getVisitTopList({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

Future<VisitTopEmployeeReport>
    getVisitTopEmployee({
  required String fromDate,
  required String toDate,
  required String employeeId,
});

}