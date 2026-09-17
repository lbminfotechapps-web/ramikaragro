import 'dart:async';
import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:demo/features/home/doman/home_entity/inpunch_pending_entity.dart';
import 'package:demo/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:demo/features/home/presentation/home_bloc/home_event.dart';
import 'package:demo/features/home/presentation/home_bloc/home_state.dart';

import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:demo/features/home/presentation/widgets/notvisited.dart';
import 'package:demo/features/home/presentation/widgets/quick_action.dart';
import 'package:demo/features/home/presentation/widgets/todays_overwiew.dart';
import 'package:demo/features/home/presentation/widgets/visit_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _username = 'user';

  Timer? _appBarTimer;

  bool _showUserInfo = true;

  static const String _appName = 'Ramikar Agro';
  static const String _appSubtitle = 'Agro Business';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDeveloperOptionWarning();
    });
    _appBarTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;

      setState(() {
        _showUserInfo = !_showUserInfo;
      });
    });

    _loadUserData();
  }

  @override
  void dispose() {
    _appBarTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await SecureStorage.instance.getUserData();

    if (userData == null) {
      debugPrint('No stored user data found');
      return;
    }

    final userId = userData['user_id']?.toString() ?? '';

    if (userId.isEmpty) {
      debugPrint('Stored user data has no user_id');
    } else {
      await getEmployeeStatus(userId);
    }

    final userName = userData['user_name']?.toString();

    if (!mounted || userName == null || userName.isEmpty) return;

    setState(() {
      _username = userName;
    });

    context.read<HomeBloc>().add(GetInpunchPendingEvent(userId: userId));
  }

  Future<void> getUserName() async {
    final userData = await SecureStorage.instance.getUserData();

    if (userData != null) {
      final userName = userData['user_name']?.toString();
      print('user name $userName');

      if (userName != null && userName.isNotEmpty) {
        if (mounted) {
          setState(() {
            _username = userName;
          });
        }
      }
    }
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: AppColors.darkBackgroundColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: AppColors.darkBackgroundColor),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await SecureStorage.instance.clearAll();

      if (!mounted) return;

      context.go(AppRouter.login);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog();

        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          leading: Builder(
            builder: (scaffoldContext) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.person_2_outlined,
                    color: AppColors.textColor,
                  ),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openDrawer();
                  },
                ),
              );
            },
          ),

          title: _showUserInfo ? _username : _appName,

          subtitle: _showUserInfo ? 'Good Morning' : _appSubtitle,

          showBackButton: false,

          onLogOutTap: () {
            _logout();
          },
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: buildPunchCard("Today's Punch", '09:15 AM'),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            int pendingCount = 0;

                            if (state.status == HomeStatus.success) {
                              pendingCount = state.data.length;
                            }
                            print("List Size is. :${state.data.length}");
                            return buildInfoCard(
                              'In Punch Pending',
                              pendingCount.toString(),
                              onTap: () => _showPendingListDialog(state.data),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.loading) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        height: 140.h,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    // If API has data, use it.
                    // If API returns empty/null, use zero values.
                    final homeData =
                        state.homedata ??
                        HomeVisitEntity(
                          status: false,
                          message: '',
                          todayTotalVisit: '0',
                          todayDealerCnt: '0',
                          todayFarmerCnt: '0',
                          monthlyTotalVisit: '0',
                          monthlyDealerCnt: '0',
                          monthlyFarmerCnt: '0',
                          monthlyUniqueDealerCnt: '0',
                          monthlyUniqueFarmerCnt: '0',
                        );

                    return VisitStatisticsTable(homeData);
                  },
                ),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.loading) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        height: 140.h,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    // If API has data, use it.
                    // If API returns empty/null, use zero values.
                    final homeData =
                        state.homedata ??
                        HomeVisitEntity(
                          status: false,
                          message: '',
                          todayTotalVisit: '0',
                          todayDealerCnt: '0',
                          todayFarmerCnt: '0',
                          monthlyTotalVisit: '0',
                          monthlyDealerCnt: '0',
                          monthlyFarmerCnt: '0',
                          monthlyUniqueDealerCnt: '0',
                          monthlyUniqueFarmerCnt: '0',
                        );

                    return NotVisitedCard(homeData);
                  },
                ),

                SizedBox(height: 8.h),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return VisitOverviewCard(
                      dealerCount: state.totalDealerCount ?? '0',
                      farmerCount: state.totalFarmerCount ?? '0',
                    );
                  },
                ),

                SizedBox(height: 12.h),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, homeState) {
                    if (homeState.status == HomeStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (homeState.status == HomeStatus.failure) {
                      return Text(
                        homeState.errorMessage ?? 'Failed to load menu',
                      );
                    }

                    if (homeState.menus.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return BlocBuilder<QuickAcessBloc, QuickAccessState>(
                      builder: (context, quickAccessState) {
                        return QuickAccessSection(
                          menus: homeState.menus,
                          punchStat: quickAccessState.punchStat,
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );

    /* 
   

    */
  }

  Widget buildPunchCard(String label, String value) {
    return CustomCard(
      color: const Color(0xFF009B3A),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(Icons.fingerprint, color: Colors.white, size: 30.h),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.cardColor, fontSize: 10.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.cardColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.cardColor,
                      size: 12.h,
                    ),
                    Text(
                      'Nashik, Maharashtra',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.cardColor,
                        fontSize: 8.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Container(
                  margin: EdgeInsets.only(left: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Punch In',
                    style: TextStyle(
                      color: AppColors.cardColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callPhoneNumber(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer')),
    );
  }

  Future<void> _showPendingListDialog(
    List<InpunchPendingEntity> pendingList,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.pending_actions, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text('In Punch Pending')),
              Text(
                pendingList.length.toString(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: pendingList.isEmpty
              ? const SizedBox(width: 280, child: Text('No pending requests'))
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 620,
                    maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.55,
                  ),
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 28,
                        headingRowHeight: 44,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 68,
                        dividerThickness: 0.6,
                        headingRowColor: WidgetStatePropertyAll(
                          colorScheme.primary.withOpacity(0.1),
                        ),
                        headingTextStyle: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text('Employee')),
                          DataColumn(label: Text('Mobile')),
                        ],
                        rows: List<DataRow>.generate(pendingList.length, (
                          index,
                        ) {
                          final pending = pendingList[index];
                          final mobileNumber =
                              pending.fldMobileNo?.trim() ?? '';

                          return DataRow(
                            color: WidgetStateProperty.resolveWith(
                              (states) => index.isEven
                                  ? colorScheme.surface
                                  : colorScheme.primary.withOpacity(0.035),
                            ),
                            cells: [
                              DataCell(Text(pending.fldAdmName ?? 'Unknown')),
                              DataCell(
                                Text(
                                  mobileNumber.isEmpty ? '-' : mobileNumber,
                                  style: mobileNumber.isEmpty
                                      ? null
                                      : TextStyle(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                ),
                                onTap: mobileNumber.isEmpty
                                    ? null
                                    : () => _callPhoneNumber(mobileNumber),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget buildInfoCard(String label, String value, {VoidCallback? onTap}) {
    return CustomCard(
      color: const Color(0xFFFFF8EF),
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: Colors.orange, size: 28.h),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Pending Request', style: TextStyle(fontSize: 10.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getEmployeeStatus(String userId) async {
    try {
      final dioClient = GetIt.instance<DioClient>();
      final formData = FormData.fromMap({'userId': userId});

      final response = await dioClient.client.post(
        ApiClient.getEmployeeStatus,
        data: formData,
      );

      dynamic data = response.data;

      if (data is String) {
        data = jsonDecode(data.trim());
      }

      if (data is! Map) {
        return;
      }
      if (data['status'] != true) {
        return;
      }

      final result = data['result'];

      if (result is! List || result.isEmpty) {
        return;
      }

      final firstResult = result.first;

      if (firstResult is! Map) {
        return;
      }

      final empStatus = firstResult['fld_status']?.toString().trim() ?? '';
      if (empStatus.isEmpty) {
        return;
      }

      if (empStatus == 'Active') {
        return;
      }
      await SecureStorage.instance.clearAll();

      if (!mounted) {
        return;
      }
      context.go(AppRouter.login);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> showDeveloperOptionWarning() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),

          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),

          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Warning',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'It looks like Developer Options are enabled on your device.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'For security purposes, please disable Developer Options before continuing.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Please follow these steps:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildStep(number: '1', text: 'Go to Settings'),

              _buildStep(number: '2', text: "Search for 'Developer Options'"),

              _buildStep(number: '3', text: 'Disable Developer Options'),
            ],
          ),

          // ----------------------------------------------------
          // BUTTONS
          // ----------------------------------------------------
          actions: [
            OutlinedButton(
              onPressed: () async {
                try {
                  // Open Developer Options directly
                  const intent = AndroidIntent(
                    action: 'android.settings.DEVELOPMENT_SETTINGS',
                  );

                  await intent.launch();
                } catch (e) {
                  debugPrint('Could not open Developer Options: $e');

                  // Fallback: open general Settings
                  try {
                    const intent = AndroidIntent(
                      action: 'android.settings.SETTINGS',
                    );

                    await intent.launch();
                  } catch (e) {
                    debugPrint('Could not open Settings: $e');
                  }
                }
              },

              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                side: BorderSide(color: AppColors.accentGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),

              child: const Text(
                'SETTINGS',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
              ),

              child: const Text(
                'CONTINUE',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // WARNING STEP
  // ------------------------------------------------------------

  Widget _buildStep({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
