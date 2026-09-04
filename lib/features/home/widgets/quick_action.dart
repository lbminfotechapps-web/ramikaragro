import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

final quickAccessItems = <QuickAccessItem>[
  QuickAccessItem(
    title: 'In Punch',
    icon: Icons.access_time_rounded,
    iconColor: Colors.green,
    backgroundColor: const Color(0xFFF1FAF4),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Dealer visit',
    icon: Icons.storefront_rounded,
    iconColor: Colors.blue,
    backgroundColor: const Color(0xFFF1F5FD),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Farmer visit',
    icon: Icons.agriculture_rounded,
    iconColor: Colors.orange,
    backgroundColor: const Color(0xFFFFF8ED),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Products',
    icon: Icons.inventory_2_outlined,
    iconColor: Colors.purple,
    backgroundColor: const Color(0xFFF9F0FF),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Reports',
    icon: Icons.description_outlined,
    iconColor: Colors.pink,
    backgroundColor: const Color(0xFFFFF1FB),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Schemes',
    icon: Icons.verified_user_outlined,
    iconColor: Colors.cyan,
    backgroundColor: const Color(0xFFF0FBFC),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'Gallery',
    icon: Icons.image_outlined,
    iconColor: Colors.deepPurple,
    backgroundColor: const Color(0xFFF4F1FF),
    onTap: () {},
  ),
  QuickAccessItem(
    title: 'More',
    icon: Icons.more_horiz_rounded,
    iconColor: Colors.black87,
    backgroundColor: const Color(0xFFF5F5F5),
    onTap: () {},
  ),
];

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

class QuickAccessSection extends StatelessWidget {
  final List<QuickAccessItem> items;

  const QuickAccessSection({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
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

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  return QuickAccessItemWidget(item: items[index]);
                },
              );
            },
          ),
        ],
      ),
    );
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
