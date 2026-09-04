import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_card.dart';
import 'package:demo/features/home/widgets/quick_action.dart';
import 'package:demo/features/home/widgets/todays_overwiew.dart';
import 'package:demo/features/home/widgets/visit_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        leading: Container(
          width: 45,
          height: 45,
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
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: 'User',
        subtitle: 'Good Morning',
        showBackButton: false,
        onNotificationTap: () {
          // Handle notification tap
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
                      height: 120.h,
                      child: buildPunchCard("Today's Punch", '09:15 AM'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SizedBox(
                      height: 120.h,
                      child: buildInfoCard('In Punch Pending', '2'),
                    ),
                  ),

                  // SizedBox(width: 8.w),
                  //
                ],
              ),
              SizedBox(height: 12.h),
              const OverviewSection(),
              SizedBox(height: 12.h),
              const VisitOverviewCard(),

              SizedBox(height: 12.h),
              QuickAccessSection(items: quickAccessItems),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),

      // FutureBuilder<Map<String, dynamic>?>(
      //   future: SecureStorage.instance.getUserData(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }

      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text('Error loading user data: ${snapshot.error}'),
      //       );
      //     }

      //     final user = snapshot.data;

      //     if (user == null || user.isEmpty) {
      //       return const Center(child: Text('No stored user data found.'));
      //     }

      //     final userName = user['user_name'] ?? 'N/A';
      //     final userEmail = user['user_email'] ?? 'N/A';
      //     final userId = user['user_id'] ?? 'N/A';
      //     final mobile = user['fld_mobile_no'] ?? 'N/A';
      //     final designation = user['designation'] ?? 'N/A';

      //     final items = <MapEntry<String, String>>[
      //       MapEntry('User Name', userName.toString()),
      //       MapEntry('Email', userEmail.toString()),
      //       MapEntry('User ID', userId.toString()),
      //       MapEntry('Mobile', mobile.toString()),
      //       MapEntry('Designation', designation.toString()),
      //     ];

      //     return Padding(
      //       padding: const EdgeInsets.all(20),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const SizedBox(height: 12),

      //           Text(
      //             'Welcome, $userName',
      //             style: const TextStyle(
      //               fontSize: 24,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),

      //           const SizedBox(height: 20),

      //           Card(
      //             elevation: 2,
      //             child: Padding(
      //               padding: const EdgeInsets.all(16),
      //               child: ListView.separated(
      //                 shrinkWrap: true,
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 itemCount: items.length,
      //                 separatorBuilder: (_, __) => const Divider(),
      //                 itemBuilder: (context, index) {
      //                   final item = items[index];

      //                   return Row(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(
      //                         item.key,
      //                         style: const TextStyle(
      //                           fontWeight: FontWeight.w600,
      //                         ),
      //                       ),

      //                       const SizedBox(width: 12),

      //                       Expanded(
      //                         child: Text(
      //                           item.value,
      //                           textAlign: TextAlign.right,
      //                         ),
      //                       ),
      //                     ],
      //                   );
      //                 },
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
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

  Widget buildInfoCard(String label, String value) {
    return CustomCard(
      color: const Color(0xFFFFF8EF),
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
}





// class CustomCard extends StatelessWidget {
//   final Widget child;
//   final Color color;
//   final EdgeInsetsGeometry padding;
//   final double borderRadius;
//   final VoidCallback? onTap;

//   const CustomCard({
//     super.key,
//     required this.child,
//     this.color = Colors.white,
//     this.padding = const EdgeInsets.all(16),
//     this.borderRadius = 20,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final card = Container(
//       padding: padding,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: child,
//     );

//     if (onTap == null) {
//       return card;
//     }

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(borderRadius),
//       child: card,
//     );
//   }
// }

