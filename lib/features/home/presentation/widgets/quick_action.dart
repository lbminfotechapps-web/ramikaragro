import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:demo/features/home/doman/home_entity/menu_entity.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

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
  // Initially show 7 API items.
  static const int initialItemCount = 7;

  // Every time More is clicked, show 4 more items.
  static const int loadMoreCount = 4;

  int visibleItemCount = initialItemCount;

  @override
  void didUpdateWidget(covariant QuickAccessSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset pagination when new API data comes.
    if (oldWidget.menus != widget.menus) {
      visibleItemCount = initialItemCount;
    }
  }

  void _showMore() {
    setState(() {
      visibleItemCount += loadMoreCount;

      if (visibleItemCount > widget.menus.length) {
        visibleItemCount = widget.menus.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menus.isEmpty) {
      return const SizedBox.shrink();
    }

    final int actualVisibleCount = visibleItemCount > widget.menus.length
        ? widget.menus.length
        : visibleItemCount;

    final bool hasMore = actualVisibleCount < widget.menus.length;

    return CustomCard(
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
              final crossAxisCount = constraints.maxWidth < 600 ? 4 : 8;

              // API items currently visible.
              final List<MenuEntity> visibleMenus = widget.menus
                  .take(actualVisibleCount)
                  .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                // +1 for More button.
                itemCount: visibleMenus.length + (hasMore ? 1 : 0),

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.9,
                ),

                itemBuilder: (context, index) {
                  // More button
                  if (index == visibleMenus.length) {
                    return _MoreItem(onTap: _showMore);
                  }

                  final menu = visibleMenus[index];

                  return QuickAccessMenuItem(
                    menu: menu,
                    punchStat: widget.punchStat,
                    onTap: () {
                      _onMenuTap(context, menu);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _onMenuTap(BuildContext context, MenuEntity menu) {
    debugPrint(
      'Menu clicked: '
      'ID=${menu.menuId}, '
      'Name=${menu.menuName}',
    );

    if (menu.menuId == '17') {
      context.go('/punch', extra: widget.punchStat);
      print('punch status data ${widget.punchStat}');
    }
    //
    // if (menu.menuId == '8') {
    //   context.go('/farmer-visit');
    // }
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
      color: _getBackgroundColor(menu.menuId),
      borderRadius: 14.r,
      padding: EdgeInsets.all(8.w),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                menu.iconImage,
                width: 30.w,
                height: 30.h,
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

                  return SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            displayName,
            maxLines: 1,
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
