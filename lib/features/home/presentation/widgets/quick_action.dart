import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';

import 'package:demo/core/utility/appdialog.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';
import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:demo/core/utility/widgets/custom_loader.dart';
import 'package:demo/features/home/doman/home_entity/menu_entity.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext, BlocListener;
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class QuickAccessItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const QuickAccessItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });
}

class QuickAccessSection extends StatefulWidget {
  final List<MenuEntity> menus;
  final PunchStatEntity? punchStat;

  const QuickAccessSection({super.key, required this.menus, this.punchStat});

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  static const int initialItemCount = 5;
  static const int loadMoreCount = 6;

  int visibleItemCount = initialItemCount;

  Future<void> _submitShareLocation({required String remark}) async {
    // final bloc = context.read<QuickAcessBloc>();
    debugPrint('========================================');
    debugPrint('SHARE LOCATION SUBMIT');
    debugPrint('========================================');

    // ============================================
    // USER DATA
    // ============================================

    final userData = await SecureStorage.instance.getUserData();

    debugPrint('User data: $userData');

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      debugPrint('SHARE LOCATION ERROR: User ID not found');
      throw Exception('User information not found');
    }

    debugPrint('User ID: $userId');

    // ============================================
    // BATTERY
    // ============================================

    final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

    debugPrint('Battery Info: $batteryInfo');

    // ============================================
    // NETWORK
    // ============================================

    final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

    debugPrint('Network Info: $networkInfo');

    // ============================================
    // LOCATION
    // ============================================

    final position = await LocationUtil.instance.getCurrentLocation();

    String latitude = '';
    String longitude = '';
    String address = '';

    if (position != null) {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      debugPrint('Latitude: $latitude');
      debugPrint('Longitude: $longitude');

      address = await LocationUtil.instance.getAddress(
        position.latitude,
        position.longitude,
      );

      debugPrint('Geo Address: $address');
    } else {
      debugPrint('Location: NOT AVAILABLE');
    }

    // ============================================
    // SHARE LOCATION EVENT DATA
    // ============================================

    const inOutStatus = '3';
    const differenceByAndroid = '0.0';
    const locationHistoryString = '';

    const startingClosingKmAmount = '';
    const vehicleTypeId = '';
    const route = '';

    const activityId = '27';

    debugPrint('========== FINAL SHARE LOCATION DATA ==========');

    debugPrint('user_id: $userId');
    debugPrint('in_out_status: $inOutStatus');

    debugPrint('differenceByAndroid: $differenceByAndroid');

    debugPrint('locationHistoryString: $locationHistoryString');

    debugPrint('strBatteryInfo: $batteryInfo');
    debugPrint('strNetworkInfo: $networkInfo');

    debugPrint('pinRemark: $remark');

    debugPrint(
      'strStartingClosingKmAmount: '
      '$startingClosingKmAmount',
    );

    debugPrint('strVehicleTypeId: $vehicleTypeId');
    debugPrint('route: $route');

    debugPrint('latitude: $latitude');
    debugPrint('longitude: $longitude');

    debugPrint('networkLatitude: $latitude');
    debugPrint('networkLongitude: $longitude');

    debugPrint('gpsLatitude: $latitude');
    debugPrint('gpsLongitude: $longitude');

    debugPrint('geoAddress: $address');

    debugPrint('activityId: $activityId');

    debugPrint('==============================================');

    if (!mounted) {
      return;
    }

    // ============================================
    // DISPATCH SHARE LOCATION EVENT
    // ============================================

    context.read<QuickAcessBloc>().add(
      ShareLocationEvent(
        userId: userId,

        inOutStatus: inOutStatus,

        differenceByAndroid: differenceByAndroid,

        locationHistoryString: locationHistoryString,

        batteryInfo: batteryInfo,

        networkInfo: networkInfo,

        pinRemark: remark,

        startingClosingKmAmount: startingClosingKmAmount,

        vehicleTypeId: vehicleTypeId,

        route: route,

        latitude: latitude,

        longitude: longitude,

        networkLatitude: latitude,

        networkLongitude: longitude,

        gpsLatitude: latitude,

        gpsLongitude: longitude,

        geoAddress: address,

        startingKmImage: '',

        closingKmImage: '',

        activityId: activityId,
      ),
    );

    debugPrint('SHARE LOCATION EVENT DISPATCHED SUCCESSFULLY');

    debugPrint('========================================');
  }

  @override
  void didUpdateWidget(covariant QuickAccessSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.menus != widget.menus) {
      visibleItemCount = initialItemCount;
    }
  }

  void _showMore() {
    setState(() {
      visibleItemCount = widget.menus.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menus.isEmpty) {
      return const SizedBox.shrink();
    }

    final actualVisibleCount = visibleItemCount > widget.menus.length
        ? widget.menus.length
        : visibleItemCount;

    final hasMore = actualVisibleCount < widget.menus.length;

    return BlocListener<QuickAcessBloc, QuickAccessState>(
      listenWhen: (previous, current) =>
          previous.quickAccessStatus != current.quickAccessStatus,
      listener: (context, state) {
        // ==========================================
        // SHARE LOCATION SUCCESS
        // ==========================================
        if (state.quickAccessStatus == QuickAccessStatus.locationAddedSucces) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location shared successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // ==========================================
        // SHARE LOCATION FAILURE
        // ==========================================
        if (state.quickAccessStatus == QuickAccessStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to share location'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },

      child: CustomCard(
        padding: EdgeInsets.all(16.w),
        borderRadius: 24.r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 14.h),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 3 : 6;

                final visibleMenus = widget.menus
                    .take(actualVisibleCount)
                    .toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleMenus.length + (hasMore ? 1 : 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    if (index == visibleMenus.length) {
                      return _MoreItem(onTap: _showMore);
                    }

                    final menu = visibleMenus[index];

                    return QuickAccessMenuItem(
                      menu: menu,
                      punchStat: widget.punchStat,
                      onTap: () => _onMenuTap(context, menu),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenuTap(BuildContext context, MenuEntity menu) async {
    debugPrint(
      'Menu clicked: '
      'ID=${menu.menuId}, '
      'Name=${menu.menuName}',
    );
    final status = widget.punchStat?.inOutStatus ?? 0;
    debugPrint('Punch status inout: ${widget.punchStat?.inOutStatus}');
    debugPrint('Punch status data: ${widget.punchStat}');

    if (menu.menuId == '17') {
      if (status == '0') {
        context.push('/punchIn', extra: widget.punchStat);
      } else if (status == '1') {
        context.push('/punchOut', extra: widget.punchStat);
      } else if (status == '2') {
        context.push('/lastPunchOut', extra: widget.punchStat);
      }
    } else if (menu.menuId == '26') {
      if (status == '1') {
        await _showShareLocationDialog(context);
      } else if (status == '2') {
        AppDialog.show(
          context: context,
          message: "Your Are Not Last Punch Out, Do You Want Continue",
          onButtonPressed: () => {
            context.push('/lastPunchOut', extra: widget.punchStat),
          },
        );
      } else {
        AppDialog.show(
          context: context,
          message: "Your Are Not Punch In, Do You Want Continue",
          onButtonPressed: () => {context.push('/punchIn')},
        );
      }
    } else if (menu.menuId == '65') {
      context.push('/notVisitDealer');
    } else if (menu.menuId == '18') {
      context.push('/scheme');
    } else if (menu.menuId == '8') {
      if (status == '1') {
        context.push('/farmers');
      } else if (status == '2') {
        AppDialog.show(
          context: context,
          message: "Your Are Not Last Punch Out, Do You Want Continue",
          onButtonPressed: () => {
            context.push('/lastPunchOut', extra: widget.punchStat),
          },
        );
      } else {
        AppDialog.show(
          context: context,
          message: "Your Are Not Punch In, Do You Want Continue",
          onButtonPressed: () => {context.push('/punchIn')},
        );
      }
    } else if (menu.menuId == '20') {
      final userData = await SecureStorage.instance.getUserData();
      final userId = userData?['user_id']?.toString();

      if (!context.mounted) return;
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User information is not available')),
        );
        return;
      }

      context.push('/notification', extra: userId);
    } else if (menu.menuId == '14') {
      context.push('/leaveList');
    } else if (menu.menuId == '3') {
      if (status == '1') {
        context.push('/visits');
      } else if (status == '2') {
        AppDialog.show(
          context: context,
          message: "Your Are Not Last Punch Out, Do You Want Continue",
          onButtonPressed: () => {
            context.push('/lastPunchOut', extra: widget.punchStat),
          },
        );
      } else {
        AppDialog.show(
          context: context,
          message: "Your Are Not Punch In, Do You Want Continue",
          onButtonPressed: () => {context.push('/punchIn')},
        );
      }
    } else if (menu.menuId == '2') {
      context.push('/products');
    } else if (menu.menuId == '64') {
      context.push('/topTenDealer');
    } else if (menu.menuId == '56') {
      context.push('/social');
    } else if (menu.menuId == '68') {
      context.push('/teamLeaveList');
    } else if (menu.menuId == '21') {
      context.push('/userGuide');
    } else if (menu.menuId == '22') {
      context.push('/aboutUs');
    } else if (menu.menuId == '23') {
      context.push('/contactUs');
    } else if (menu.menuId == '19') {
      context.push('/gallery');
    } else if (menu.menuId == '71') {
      context.push('/addCollection');
    } else if (menu.menuId == '72') {
      context.push('/collectionList');
    } else if (menu.menuId == '16') {
      context.push('/collectionTargetAndAchievement');
    } else if (menu.menuId == '60') {
      context.push('/cropSchedule');
    } else if (menu.menuId == '13') {
      context.push('/expenseList');
    } else if (menu.menuId == '67') {
      context.push('/teamExpenseList');
    } else if (menu.menuId == '69') {
      context.push('/placeOrder');
    } else if (menu.menuId == '82') {
      context.push('/salesTargetAndAchievement');
    } else if (menu.menuId == '74') {
      context.push('/orderHistoy');
    } else if (menu.menuId == '75') {
      context.push('/dispatchHistoy');
    } else if (menu.menuId == '78') {
      context.push('/salesHistoy');
    } else if (menu.menuId == '9') {
      context.push('/addExpense');
    } else if (menu.menuId == '57' ||
        menu.menuId == '63' ||
        menu.menuId == '32') {
      final userData = await SecureStorage.instance.getUserData();
      final userId = userData?['user_id']?.toString();

      if (!context.mounted) return;

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User information is not available')),
        );
        return;
      }

      final route = switch (menu.menuId) {
        '57' => '/visitSummaryReport',
        '63' => '/empOutputReport',
        _ => '/empActivityReport',
      };

      context.push(route, extra: userId);
    }
  }

  Future<void> _showShareLocationDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final remarkController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text(
                      'Share Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: remarkController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Enter remark',
                    labelText: 'Remark',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: 12.w,
                        right: 8.w,
                        top: 12.h,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter remark';
                    }

                    return null;
                  },
                ),
              ),
              actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final remark = remarkController.text.trim();

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _submitShareLocation(remark: remark);

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isSubmitting
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    remarkController.dispose();
  }
}

class QuickAccessItemWidget extends StatelessWidget {
  final QuickAccessItem item;

  const QuickAccessItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: item.backgroundColor,
      borderRadius: 14.r,
      padding: EdgeInsets.all(8.w),
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 28.sp, color: item.iconColor),
          SizedBox(height: 6.h),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class QuickAccessMenuItem extends StatelessWidget {
  final MenuEntity menu;
  final PunchStatEntity? punchStat;
  final VoidCallback? onTap;

  const QuickAccessMenuItem({
    super.key,
    required this.menu,
    this.punchStat,
    this.onTap,
  });

  String get displayName {
    if (menu.menuId != '17') {
      return menu.menuName;
    }

    return punchStat?.inOutStatus == '0' ? 'In Punch' : 'Out Punch';
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 1,
      color: _getBackgroundColor(menu.menuId),
      borderRadius: 14.r,
      padding: EdgeInsets.all(8.w),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.network(
              menu.iconImage,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.apps_rounded,
                  size: 30.sp,
                  color: AppColors.textColor,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const CustomLoader();
              },
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            displayName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String menuId) {
    switch (menuId) {
      case '17':
        return const Color(0xFFF1FAF4);
      case '8':
        return const Color(0xFFFFF8ED);
      case '3':
        return const Color(0xFFF1F5FD);
      case '1':
        return const Color(0xFFF5F5F5);
      case '2':
        return const Color(0xFFF9F0FF);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}

class _MoreItem extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: const Color(0xFFF5F5F5),
      borderRadius: 14.r,
      padding: EdgeInsets.all(8.w),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz_rounded, size: 28.sp, color: Colors.black87),
          SizedBox(height: 6.h),
          Text(
            'More',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
