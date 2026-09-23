import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/features/leave/domain/entities/leave.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;

  const LeaveCard({
    super.key,
    required this.leave,
  });

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

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return Colors.orange;

      case '1':
      case 'approved':
      case 'approve':
        return Colors.green;

      case '2':
      case 'rejected':
      case 'reject':
        return Colors.red;

      default:
        return Colors.blue;
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
    final mainStatusColor = _statusColor(leave.status);

    return Container(
      margin: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: AppColors.primary,
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
                          color: Colors.grey.shade900,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        'Applied on ${_applicationDate(leave.leaveApplicationDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
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
                            color: Colors.grey.shade500,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: mainStatusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: mainStatusColor.withOpacity(0.15),
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
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [

                  Expanded(
                    child: _buildDateItem(
                      title: 'FROM',
                      value: leave.fromDate,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),

                  Container(
                    height: 32.h,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _buildDateItem(
                      title: 'TO',
                      value: leave.toDate,
                      icon: Icons.event_rounded,
                    ),
                  ),

                  Container(
                    height: 32.h,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: _buildDateItem(
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
                color: _statusColor(leave.rejectStatus),
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
                color: _statusColor(leave.adminStatus),
              ),
            ],

            // ==================================================
            // REMARK
            // ==================================================

            if (leave.remark.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),

              _buildInfoBox(
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

              _buildRejectBox(),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE ITEM
  // ============================================================

  Widget _buildDateItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [

        Icon(
          icon,
          size: 15.sp,
          color: AppColors.primary,
        ),

        SizedBox(height: 4.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 7.5.sp,
            color: Colors.grey.shade500,
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
            color: Colors.grey.shade800,
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
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: color.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [

          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15.sp,
              color: color,
            ),
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

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15.sp,
              color: Colors.blue,
            ),
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
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade800,
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

  Widget _buildRejectBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.red.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            height: 29.w,
            width: 29.w,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 16.sp,
              color: Colors.red,
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
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  leave.reasonForReject,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red.shade900,
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