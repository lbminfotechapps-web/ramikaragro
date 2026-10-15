import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/notification_di.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

import '../widgets/notification_card.dart';
import '../widgets/notification_shimmer.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  final bool isLogin;
  final String userType;

  const NotificationPage({
    super.key,
    required this.userId,
    required this.isLogin,
    required this.userType,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final ScrollController _scrollController;

  NotificationBloc? _notificationBloc;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    debugPrint('========================================');
    debugPrint('NOTIFICATION PAGE');
    debugPrint('USER ID     : ${widget.userId}');
    debugPrint('IS LOGIN    : ${widget.isLogin}');
    debugPrint('USER TYPE   : ${widget.userType}');
    debugPrint('========================================');
  }

  // =========================================================
  // PAGINATION
  // =========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _notificationBloc?.add(const LoadMoreNotificationsEvent());
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _notificationBloc = null;

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) {
        final bloc = sl<NotificationBloc>();

        bloc.add(
          GetNotificationListEvent(
            userId: widget.userId,
            isLogin: widget.isLogin,
            userType: widget.userType,
          ),
        );

        return bloc;
      },
      child: Builder(
        builder: (context) {
          _notificationBloc = context.read<NotificationBloc>();

          return Scaffold(
            backgroundColor: context.backgroundColor,

            // =================================================
            // APP BAR
            // =================================================
            appBar: CustomAppBar(
              backgroundColor: context.primaryColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: context.onPrimaryColor,
                ),
                onPressed: () {
                  context.go(AppRouter.home);
                },
              ),
              title: 'Notifications',
              titleStyle: AppTextStyles.appBarTitle.copyWith(
                color: context.onPrimaryColor,
              ),
            ),

            // =================================================
            // BODY
            // =================================================
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopHeader(),
                  Expanded(
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        // =======================================
                        // LOADING
                        // =======================================

                        if (state is NotificationLoading) {
                          return const NotificationShimmer();
                        }

                        // =======================================
                        // ERROR
                        // =======================================

                        if (state is NotificationError) {
                          return _buildError(context, state.message);
                        }

                        // =======================================
                        // LOADED
                        // =======================================

                        if (state is NotificationLoaded) {
                          if (state.notifications.isEmpty) {
                            return _buildEmpty(context);
                          }

                          return _buildNotificationList(context, state);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // TOP HEADER
  // =========================================================

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          int count = 0;

          if (state is NotificationLoaded) {
            count = state.notifications.length;
          }

          return Row(
            children: [
              // =================================================
              // NOTIFICATION ICON
              // =================================================
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: context.onPrimaryColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.onPrimaryColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: context.onPrimaryColor,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              // =================================================
              // HEADER TEXT
              // =================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Updated',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: context.onPrimaryColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      count == 0
                          ? 'No notifications available'
                          : 'Here are your latest updates',
                      style: AppTextStyles.listTitle.copyWith(
                        color: context.onPrimaryColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // COUNT
              // =================================================
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.shadow.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // NOTIFICATION LIST
  // =========================================================

  Widget _buildNotificationList(
    BuildContext context,
    NotificationLoaded state,
  ) {
    return RefreshIndicator(
      color: context.primaryColor,
      backgroundColor: context.cardBackgroundColor,

      onRefresh: () async {
        context.read<NotificationBloc>().add(
          RefreshNotificationListEvent(
            userId: widget.userId,
            isLogin: widget.isLogin,
            userType: widget.userType,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 700));
      },

      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(14, 18, 14, 30),

        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),

        itemBuilder: (context, index) {
          // ===============================================
          // PAGINATION LOADER
          // ===============================================

          if (index == state.notifications.length) {
            return _buildPaginationLoader();
          }

          final notification = state.notifications[index];

          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  // =========================================================
  // NOTIFICATION CARD
  // =========================================================

  Widget _buildNotificationCard(dynamic notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.045),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: NotificationCard(notification: notification),
    );
  }

  // =========================================================
  // PAGINATION LOADER
  // =========================================================

  Widget _buildPaginationLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.primaryColor,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      color: context.primaryColor,

      onRefresh: () async {
        context.read<NotificationBloc>().add(
          RefreshNotificationListEvent(
            userId: widget.userId,
            isLogin: widget.isLogin,
            userType: widget.userType,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 700));
      },

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =========================================
                    // ICON
                    // =========================================
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: context.cardBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.10,
                                  ),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.notifications_none_rounded,
                            color: context.primaryColor,
                            size: 43,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      'Record Not Found',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // // =========================================
                    // // REFRESH BUTTON
                    // // =========================================
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     context.read<NotificationBloc>().add(
                    //       RefreshNotificationListEvent(
                    //         userId: widget.userId,
                    //         isLogin: widget.isLogin,
                    //         userType: widget.userType,
                    //       ),
                    //     );
                    //   },
                    //   icon: const Icon(Icons.refresh_rounded, size: 19),
                    //   label: const Text('Refresh Notifications'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: context.primaryColor,
                    //     foregroundColor: context.onPrimaryColor,
                    //     elevation: 0,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 21,
                    //       vertical: 13,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(14),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===============================================
            // ERROR ICON
            // ===============================================
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.appColors.error.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.error.withValues(alpha: 0.08),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  color: context.appColors.error,
                  size: 42,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Unable to Load',
              style: AppTextStyles.pageTitle.copyWith(
                color: context.primaryTextColor,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'We couldn’t load your notifications.\n'
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: context.secondaryTextColor,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 18),

            // ===============================================
            // ERROR MESSAGE
            // ===============================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.appColors.error.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: context.appColors.error.withValues(alpha: 0.10),
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: context.appColors.error,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ===============================================
            // TRY AGAIN
            // ===============================================
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationBloc>().add(
                  GetNotificationListEvent(
                    userId: widget.userId,
                    isLogin: widget.isLogin,
                    userType: widget.userType,
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: Text('Try Again', style: AppTextStyles.body),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
