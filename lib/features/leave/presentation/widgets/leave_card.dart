import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/features/leave/domain/entities/leave.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;

  const LeaveCard({super.key, required this.leave});

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _statusText(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return 'Pending';

      case '1':
      case 'approved':
      case 'approve':
        return 'Approved';

      case '2':
      case 'rejected':
      case 'reject':
        return 'Rejected';

      default:
        return status.trim().isEmpty ? '-' : status.trim();
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(BuildContext context, String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return context.appWarning;

      case '1':
      case 'approved':
      case 'approve':
        return context.appSuccess;

      case '2':
      case 'rejected':
      case 'reject':
        return context.appColors.error;

      default:
        return context.primaryColor;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return Icons.access_time_rounded;

      case '1':
      case 'approved':
      case 'approve':
        return Icons.check_circle_outline_rounded;

      case '2':
      case 'rejected':
      case 'reject':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline_rounded;
    }
  }

  // ============================================================
  // APPLICATION DATE
  // ============================================================

  String _applicationDate(String date) {
    if (date.trim().isEmpty) {
      return '-';
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // STATUS DISPLAY TEXT
  // ============================================================

  String _statusDisplayText(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
        return 'Pending';

      case '1':
        return 'Approved';

      case '2':
        return 'Rejected';

      case 'pending':
        return 'Pending';

      case 'approved':
      case 'approve':
        return 'Approved';

      case 'rejected':
      case 'reject':
        return 'Rejected';

      default:
        return status.trim().isEmpty ? '-' : status.trim();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mainStatusColor = _statusColor(context, leave.status);

    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 5.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave icon
                Container(
                  height: 38.w,
                  width: 38.w,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: context.primaryColor,
                    size: 20.sp,
                  ),
                ),

                SizedBox(width: 9.w),

                // Application details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Application',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: context.cardTextColor,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        'Applied on ${_applicationDate(leave.leaveApplicationDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (leave.admName.trim().isNotEmpty) ...[
                        SizedBox(height: 2.h),

                        Text(
                          leave.admName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: context.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Main status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: mainStatusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: mainStatusColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(leave.status),
                        size: 13.sp,
                        color: mainStatusColor,
                      ),

                      SizedBox(width: 4.w),

                      Text(
                        _statusText(leave.status),
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: mainStatusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ==================================================
            // DATE INFORMATION
            // ==================================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: context.appTheme.inputBackground,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateItem(
                      context,
                      title: 'FROM',
                      value: leave.fromDate,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),

                  Container(height: 32.h, width: 1, color: context.borderColor),

                  Expanded(
                    child: _buildDateItem(
                      context,
                      title: 'TO',
                      value: leave.toDate,
                      icon: Icons.event_rounded,
                    ),
                  ),

                  Container(height: 32.h, width: 1, color: context.borderColor),

                  Expanded(
                    child: _buildDateItem(
                      context,
                      title: 'DAYS',
                      value: leave.leaveDays,
                      icon: Icons.timelapse_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // REPORTING STATUS
            // ==================================================
            if (leave.rejectStatus.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),

              _buildStatusBox(
                title: 'REPORTING STATUS',
                value: leave.rejectStatus,
                icon: Icons.supervisor_account_rounded,
                color: _statusColor(context, leave.rejectStatus),
              ),
            ],

            // ==================================================
            // ADMIN STATUS
            // ==================================================
            if (leave.adminStatus.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),

              _buildStatusBox(
                title: 'ADMIN STATUS',
                value: leave.adminStatus,
                icon: Icons.admin_panel_settings_outlined,
                color: _statusColor(context, leave.adminStatus),
              ),
            ],

            // ==================================================
            // REMARK
            // ==================================================
            if (leave.remark.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),

              _buildInfoBox(
                context,
                icon: Icons.notes_rounded,
                title: 'Remark',
                value: leave.remark,
              ),
            ],

            // ==================================================
            // REJECTION REASON
            // ==================================================
            if (leave.reasonForReject.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),

              _buildRejectBox(context),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE ITEM
  // ============================================================

  Widget _buildDateItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 15.sp, color: context.primaryColor),

        SizedBox(height: 4.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 7.5.sp,
            color: context.secondaryTextColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),

        SizedBox(height: 2.h),

        Text(
          value.trim().isEmpty ? '-' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: context.cardTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REPORTING / ADMIN STATUS BOX
  // ============================================================

  Widget _buildStatusBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15.sp, color: color),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 7.5.sp,
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  _statusDisplayText(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: color,
                    fontWeight: FontWeight.w800,
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
  // REMARK BOX
  // ============================================================

  Widget _buildInfoBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15.sp, color: context.primaryColor),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 7.5.sp,
                    color: context.primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.cardTextColor,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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
  // REJECTION BOX
  // ============================================================

  Widget _buildRejectBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.appColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.appColors.error.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: context.appColors.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 16.sp,
              color: context.appColors.error,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REJECTION REASON',
                  style: TextStyle(
                    fontSize: 7.5.sp,
                    color: context.appColors.error,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  leave.reasonForReject,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.appColors.error,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
