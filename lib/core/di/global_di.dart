import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/di/dealer_di.dart';
import 'package:demo/core/di/employee_activity_report_di.dart';
import 'package:demo/core/di/employee_output_di.dart';
import 'package:demo/core/di/farmer_di.dart';
import 'package:demo/core/di/home_di.dart';
import 'package:demo/core/di/visit_report_di.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initGlobalDi() async {

  await initAuthDi();
  await initHomeDi();

  // =========================
  // DEALER
  // =========================

  // await initDealerDi();

  // =========================
  // FUTURE FEATURES
  // =========================

  await initFarmerDi();
  await initDealerDi();
  await initEmployeeActivityDi();
  await initVisitReportDi();
  await initEmployeeOutputDi();
  
}
