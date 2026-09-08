import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/di/dealer_di.dart';
import 'package:demo/core/di/farmer_di.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initGlobalDi() async {
  // =========================
  // AUTH
  // =========================

  await initAuthDi();

  

  await initFarmerDi();
  await initDealerDi();
  // await initExpenseDi();
  // await initScheduleDi();
  // await initProfileDi();
}
