import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/di/collection_di.dart';
import 'package:demo/core/di/collection_list_di.dart';
import 'package:demo/core/di/collection_target_di.dart';
import 'package:demo/core/di/crop_schedule_di.dart';
import 'package:demo/core/di/dealer_di.dart';
import 'package:demo/core/di/employee_activity_report_di.dart';
import 'package:demo/core/di/employee_output_di.dart';
import 'package:demo/core/di/farmer_di.dart';
import 'package:demo/core/di/gallery_di.dart';
import 'package:demo/core/di/home_di.dart';
import 'package:demo/core/di/leave_list_di.dart';
import 'package:demo/core/di/not_visited_dealer_di.dart';
import 'package:demo/core/di/notification_di.dart';
import 'package:demo/core/di/product_di.dart';

import 'package:demo/core/di/scheme_di.dart';
import 'package:demo/core/di/social_media_di.dart';
import 'package:demo/core/di/team_leave_di.dart';
import 'package:demo/core/di/top_ten_dealer_di.dart';
import 'package:demo/core/di/visit_report_di.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initGlobalDi() async {
  await initAuthDi();
  await initHomeDi();

  await initFarmerDi();
  await initGalleryDi();
  await initSchemeDi();
  await initDealerDi();
  await initEmployeeActivityDi();
  await initVisitReportDi();
  await initEmployeeOutputDi();
  await initNotificationDi();
  await initLeaveListDi();
  await initTopTenDealerDi();
  await initSocialMediaDi();
  await initTeamLeaveDi();
  await initCollectionWiseFormDi();
  await initNotVisitedDealerDi();
  await initProductDi();
  await initCollectionListDi();
  await initDealerTargetDi();
  await initCropScheduleDi();
}
