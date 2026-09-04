import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/di/farmer_di.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initGlobalDi() async {
  // =========================
  // AUTH
  // =========================

  await initAuthDi();

  // =========================
  // DEALER
  // =========================

  // await initDealerDi();

  // =========================
  // FUTURE FEATURES
  // =========================

  await initFarmerDi();
  // await initExpenseDi();
  // await initScheduleDi();
  // await initProfileDi();
}
