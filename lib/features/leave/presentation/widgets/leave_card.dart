
import 'package:flutter/material.dart';

import '../../domain/entities/leave.dart';

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
    switch (status) {
      case "0":
        return "Pending";
      case "1":
        return "Approved";
      case "2":
        return "Rejected";
      default:
        return "Unknown";
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case "0":
        return Colors.orange;
      case "1":
        return Colors.green;
      case "2":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status) {
      case "0":
        return Icons.access_time_rounded;
      case "1":
        return Icons.check_circle_outline_rounded;
      case "2":
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ============================================================
  // APPLICATION DATE
  // ============================================================

  String _applicationDate(String value) {
    if (value.trim().isEmpty) {
      return "";
    }

    return value.trim().split(" ").first;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(leave.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leave icon
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Color(0xFF087C3A),
                    size: 23,
                  ),
                ),

                const SizedBox(width: 10),

                // Application information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   "APPLICATION DATE",
                      //   style: TextStyle(
                      //     fontSize: 8,
                      //     color: Colors.grey,
                      //     fontWeight: FontWeight.w700,
                      //     letterSpacing: 0.6,
                      //   ),
                      // ),
                      // const SizedBox(height: 2),
                      Text(
                        _applicationDate(
                          leave.leaveApplicationDate,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      if (leave.admName.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            leave.admName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(leave.status),
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusText(leave.status),
                        style: TextStyle(
                          fontSize: 9,
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // DATE INFORMATION
            // ==================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateColumn(
                      title: "FROM",
                      value: leave.fromDate,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _buildDateColumn(
                      title: "TO",
                      value: leave.toDate,
                      icon: Icons.event_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _buildDateColumn(
                      title: "DAYS",
                      value: leave.leaveDays,
                      icon: Icons.timelapse_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // REMARK
            // ==================================================

            if (leave.remark.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoBox(
                icon: Icons.notes_rounded,
                title: "Remark",
                value: leave.remark,
              ),
            ],

            // ==================================================
            // REJECT REASON
            // ==================================================

            if (leave.reasonForReject.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildRejectBox(),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE COLUMN
  // ============================================================

  Widget _buildDateColumn({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF087C3A),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 7.5,
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? "-" : value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Container(
      height: 34,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.blue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
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
  // REJECT BOX
  // ============================================================

  Widget _buildRejectBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withOpacity(0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "REJECTION REASON",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  leave.reasonForReject,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
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

