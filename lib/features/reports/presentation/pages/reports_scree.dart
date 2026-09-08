import 'package:demo/core/di/employee_activity_report_di.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';

import 'package:demo/features/reports/presentation/bloc/employee_activity_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/visit_report_bloc.dart';

import 'package:demo/features/reports/presentation/pages/employee_activity_report_page.dart';
import 'package:demo/features/reports/presentation/pages/employee_output_report_page.dart';
import 'package:demo/features/reports/presentation/pages/not_visited_dealer_page.dart';
import 'package:demo/features/reports/presentation/pages/visit_summary_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class ReportsScree extends StatefulWidget {
  const ReportsScree({super.key});

  @override
  State<ReportsScree> createState() => _ReportsScreeState();
}

class _ReportsScreeState extends State<ReportsScree> {
  String? userId;
  bool isLoadingUserId = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ============================================================
  // LOAD USER ID
  // ============================================================

  Future<void> _loadUserId() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      if (!mounted) return;

      setState(() {
        userId = userData?['user_id']?.toString();
        isLoadingUserId = false;
      });

      debugPrint('========================================');
      debugPrint('REPORT DASHBOARD');
      debugPrint('USER DATA : $userData');
      debugPrint('USER ID   : $userId');
      debugPrint('========================================');
    } catch (e) {
      debugPrint('Report User ID Error: $e');

      if (!mounted) return;

      setState(() {
        isLoadingUserId = false;
      });
    }
  }

  // ============================================================
  // CHECK USER ID
  // ============================================================

  bool _checkUserId() {
    if (userId != null && userId!.isNotEmpty) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User information is not available'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    return false;
  }

  // ============================================================
  // EMPLOYEE ACTIVITY
  // ============================================================

  void _openEmployeeActivityReport() {
    if (!_checkUserId()) return;
    print('report click');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<EmployeeActivityBloc>(
          create: (_) => sl<EmployeeActivityBloc>(),
          child: EmployeeActivityReportPage(userId: userId!),
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE OUTPUT
  // ============================================================

  void _openEmployeeOutputReport() {
    if (!_checkUserId()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<EmployeeOutputBloc>(
          create: (_) => sl<EmployeeOutputBloc>(),
          child: EmployeeOutputReportPage(userId: userId!),
        ),
      ),
    );
  }

  // ============================================================
  // VISIT SUMMARY
  // ============================================================

  void _openVisitSummary() {
    if (!_checkUserId()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<VisitReportBloc>(
          create: (_) => sl<VisitReportBloc>(),
          child: VisitSummaryPage(userId: userId!),
        ),
      ),
    );
  }

  // ============================================================
  // NOT VISITED
  // ============================================================
 
  void _openNotVisited() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const NotVisitedDealerPage(),
    ),
  );
}

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundColor,

      // ========================================================
      // APP BAR
      // // ========================================================
      // appBar: CustomAppBar(
      //   title: 'Reports',
      //   subtitle: 'Business performance overview',
      // ),
/*
      AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 18,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: TextStyle(
                color: Color(0xFF182026),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Business performance overview',
              style: TextStyle(
                color: Color(0xFF8C969E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),

            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.analytics_rounded,
              color: Color(0xFF168A4A),
              size: 20,
            ),
          ),
        ],
      ),

      */

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        color: const Color(0xFF168A4A),
        onRefresh: _loadUserId,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              SizedBox(height: 45.h),
              _buildHeader(),

              SizedBox(height: 16.h),

              // ==================================================
              // SECTION TITLE
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(
                      color: Color(0xFF17202A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EF),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      '4 Available',
                      style: TextStyle(
                        color: Color(0xFF168A4A),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==================================================
              // REPORT CARDS
              // ==================================================
              _buildReportGrid(),

              const SizedBox(height: 15),

              // ==================================================
              // QUICK INSIGHT
              // ==================================================
              _buildInsight(),

              const SizedBox(height: 10),

              // ==================================================
              // USER INFORMATION
              // ==================================================
              _buildUserInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF117A43), Color(0xFF28A960)],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(21),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF168A4A).withOpacity(0.18),

            blurRadius: 15,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [
          // ======================================================
          // HEADER TOP
          // ======================================================

          Row(
            children: [
              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Performance Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Track employees, visits and business activity',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // HEADER STATS
          // ======================================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                const _HeaderStat(value: '04', label: 'Reports'),

                _HeaderDivider(),

                _HeaderStat(value: userId ?? '--', label: 'User ID'),

                _HeaderDivider(),

                _HeaderStat(
                  value: isLoadingUserId ? '...' : 'Active',
                  label: 'Status',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT GRID
  // ============================================================

  Widget _buildReportGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        return GridView(
          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,

            crossAxisSpacing: 10,

            mainAxisSpacing: 10,

            childAspectRatio: isTablet ? 1.15 : 1.05,
          ),

          children: [
            // ==================================================
            // NOT VISITED
            // ==================================================

            _ReportCard(
              icon: Icons.store_mall_directory_rounded,

              title: 'Not Visited',

              subtitle: 'Last 30 Days',

              badge: 'DEALER',

              iconColor: const Color(0xFFE47720),

              iconBackground: const Color(0xFFFFF1E5),

              onTap: _openNotVisited,
            ),

            // ==================================================
            // EMPLOYEE ACTIVITY
            // ==================================================
            _ReportCard(
              icon: Icons.groups_rounded,

              title: 'Employee',

              subtitle: 'Activity Report',

              badge: 'ACTIVITY',

              iconColor: const Color(0xFF1976D2),

              iconBackground: const Color(0xFFEAF3FF),

              onTap: _openEmployeeActivityReport,
            ),

            // ==================================================
            // EMPLOYEE OUTPUT
            // ==================================================
            _ReportCard(
              icon: Icons.bar_chart_rounded,

              title: 'Employee',

              subtitle: 'Output Report',

              badge: 'OUTPUT',

              iconColor: const Color(0xFF7B4DCE),

              iconBackground: const Color(0xFFF1EAFE),

              onTap: _openEmployeeOutputReport,
            ),

            // ==================================================
            // VISIT SUMMARY
            // ==================================================
            _ReportCard(
              icon: Icons.donut_large_rounded,

              title: 'Visit',

              subtitle: 'Summary Report',

              badge: 'VISITS',

              iconColor: const Color(0xFF168A4A),

              iconBackground: const Color(0xFFE7F7EF),

              onTap: _openVisitSummary,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // QUICK INSIGHT
  // ============================================================

  Widget _buildInsight() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE6EAED)),
      ),

      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DB),

              borderRadius: BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.lightbulb_outline_rounded,

              color: Color(0xFFE19A00),

              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Quick Insight',

                  style: TextStyle(
                    color: Color(0xFF17202A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Review employee activity and visits to monitor daily performance.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Color(0xFF89939D),
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER INFO
  // ============================================================

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),

        borderRadius: BorderRadius.circular(13),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,

            color: Color(0xFF168A4A),

            size: 17,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              userId == null
                  ? 'Loading user information...'
                  : 'Logged in as User ID $userId',

              style: const TextStyle(
                color: Color(0xFF167A43),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (isLoadingUserId)
            const SizedBox(
              height: 13,
              width: 13,

              child: CircularProgressIndicator(strokeWidth: 1.8),
            ),
        ],
      ),
    );
  }
}

// =================================================================
// REPORT CARD
// =================================================================

class _ReportCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final String badge;

  final Color iconColor;

  final Color iconBackground;

  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        splashColor: iconColor.withOpacity(0.08),

        child: Container(
          padding: const EdgeInsets.all(13),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: const Color(0xFFE5E9EC)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),

                blurRadius: 8,

                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICON + ARROW
              // ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    height: 42,
                    width: 42,

                    decoration: BoxDecoration(
                      color: iconBackground,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(icon, color: iconColor, size: 22),
                  ),

                  Container(
                    height: 27,
                    width: 27,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,

                      size: 10,

                      color: Color(0xFF8B949C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // BADGE
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                decoration: BoxDecoration(
                  color: iconBackground,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  badge,

                  style: TextStyle(
                    color: iconColor,

                    fontSize: 8,

                    fontWeight: FontWeight.w800,

                    letterSpacing: 0.4,
                  ),
                ),
              ),

              const Spacer(),

              // ==================================================
              // TITLE
              // ==================================================
              Text(
                title,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFF17202A),

                  fontSize: 13,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              // ==================================================
              // SUBTITLE
              // ==================================================
              Text(
                subtitle,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFF929BA3),

                  fontSize: 9,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// HEADER STAT
// =================================================================

class _HeaderStat extends StatelessWidget {
  final String value;

  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 15,

              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,

            style: const TextStyle(
              color: Colors.white70,

              fontSize: 8,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// HEADER DIVIDER
// =================================================================

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }
}
