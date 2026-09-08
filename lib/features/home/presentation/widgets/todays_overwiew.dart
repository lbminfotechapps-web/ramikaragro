import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class TodaysOverviewCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Border? border;

  const TodaysOverviewCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OverviewSection extends StatelessWidget {
  final List<OverviewItemData> overviewItems;

  const OverviewSection({
    super.key,
    this.overviewItems = const [
      OverviewItemData(
        icon: Icons.people,
        value: '25',
        title: 'Employees',
        status: 'Active',
        color: Colors.green,
        backgroundColor: Color(0xFFF1FAF4),
      ),
      OverviewItemData(
        icon: Icons.store,
        value: '156',
        title: 'Dealers',
        status: 'Active',
        color: Colors.blue,
        backgroundColor: Color(0xFFF1F5FD),
      ),
      OverviewItemData(
        icon: Icons.agriculture,
        value: '1,248',
        title: 'Farmers',
        status: 'Visited',
        color: Colors.orange,
        backgroundColor: Color(0xFFFFF8ED),
      ),
      OverviewItemData(
        icon: Icons.track_changes,
        value: '75%',
        title: 'Target',
        status: 'Achieved',
        color: Colors.purple,
        backgroundColor: Color(0xFFF9F0FF),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: 28.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Overview",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: const Row(
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemCount = overviewItems.length;
              final spacing = 6.w;
              final itemWidth = itemCount == 0
                  ? 0.0
                  : (constraints.maxWidth - (spacing * (itemCount - 1))) /
                        itemCount;

              return SizedBox(
                height: 100.h,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisExtent: itemWidth,
                    mainAxisSpacing: spacing,
                  ),
                  itemBuilder: (context, index) {
                    return _OverviewItem(data: overviewItems[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OverviewItemData {
  final IconData icon;
  final String value;
  final String title;
  final String status;
  final Color color;
  final Color backgroundColor;

  const OverviewItemData({
    required this.icon,
    required this.value,
    required this.title,
    required this.status,
    required this.color,
    required this.backgroundColor,
  });
}

class _OverviewItem extends StatelessWidget {
  final OverviewItemData data;

  const _OverviewItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: data.backgroundColor,
      borderRadius: 12.r,
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26.w,
            height: 26.h,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(data.icon, color: data.color, size: 15.sp),
          ),
          SizedBox(height: 3.h),
          Text(
            data.value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            data.status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: data.color,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
