import 'package:get_it/get_it.dart';

import 'auth_di.dart';
import 'dealer_di.dart';

final sl = GetIt.instance;

Future<void> initGlobalDi() async {

  //==============AUTH=========================
  await initAuthDi();
  // ============== DEALER ==============
  await initDealerDi();

 
}