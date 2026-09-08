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
        return Icons.check_circle_outline;

      case "2":
        return Icons.cancel_outlined;

      default:
        return Icons.help_outline;
    }
  }

  // ============================================================
  // APPLICATION DATE
  // ============================================================

  String _applicationDate(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return "";
    }

    return value.trim().split(" ").first;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _statusColor(leave.status);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.045,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==================================================
            // TOP SECTION
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ICON
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade700,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green
                            .withOpacity(
                          0.20,
                        ),
                        blurRadius: 10,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .event_available_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                // APPLICATION DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        "APPLICATION DATE",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _applicationDate(
                          leave
                              .leaveApplicationDate,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      if (leave.admName
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          leave.admName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // STATUS
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor
                        .withOpacity(
                      0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: statusColor
                          .withOpacity(
                        0.12,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(
                          leave.status,
                        ),
                        size: 14,
                        color:
                            statusColor,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        _statusText(
                          leave.status,
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              statusColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DATE INFORMATION
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xfff7f9f8),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                border: Border.all(
                  color:
                      Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateColumn(
                      title: "FROM",
                      value: leave.fromDate,
                      icon:
                          Icons.calendar_today_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _buildDateColumn(
                      title: "TO",
                      value: leave.toDate,
                      icon:
                          Icons.event_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _buildDateColumn(
                      title: "DAYS",
                      value: leave.leaveDays,
                      icon:
                          Icons.timelapse_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // REMARK
            // ==================================================

            if (leave.remark
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 13),

              _buildInfoBox(
                icon: Icons.notes_rounded,
                title: "Remark",
                value: leave.remark,
              ),
            ],

            // ==================================================
            // REJECT REASON
            // ==================================================

            if (leave.reasonForReject
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 10),

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
          size: 16,
          color: Colors.green,
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value.isEmpty ? "-" : value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
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
      height: 42,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(
          0.045,
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: Colors.blue.withOpacity(
            0.07,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue
                  .withOpacity(
                0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.black87,
                    height: 1.4,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(
          0.045,
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: Colors.red.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(
                0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "REJECTION REASON",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  leave.reasonForReject,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    height: 1.4,
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