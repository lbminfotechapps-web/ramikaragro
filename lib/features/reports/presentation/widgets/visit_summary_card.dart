import 'package:flutter/material.dart';

import '../../domain/entities/visit_report.dart';

class VisitSummaryCard extends StatelessWidget {
  final VisitReport report;

  const VisitSummaryCard({
    super.key,
    required this.report,
  });

  bool get isPresent {
    return report.status.toLowerCase() == 'present';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              9,
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: isPresent
                        ? const Color(0xFFEAF6EE)
                        : const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isPresent
                        ? Icons.person_pin_circle_outlined
                        : Icons.person_off_outlined,
                    color: isPresent
                        ? const Color(0xFF287A4B)
                        : const Color(0xFFD45C5C),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.empName.isEmpty
                            ? 'Employee'
                            : report.empName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202923),
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        report.empCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF737C76),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                _StatusBadge(
                  status: report.status,
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: .7,
            indent: 12,
            endIndent: 12,
          ),

          // ============================================================
          // DATE
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              5,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF68736D),
                ),

                const SizedBox(width: 5),

                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF7B847F),
                  ),
                ),

                const Spacer(),

                Text(
                  _displayValue(report.date),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF303934),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // IN / OUT
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.login_rounded,
                    title: 'IN Time',
                    value: _displayValue(report.inTime),
                    iconColor: const Color(0xFF2E8B57),
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.logout_rounded,
                    title: 'OUT Time',
                    value: _displayValue(report.outTime),
                    iconColor: const Color(0xFFD45C5C),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // VISITS
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.storefront_outlined,
                    title: 'Dealer Visits',
                    value: _displayValue(
                      report.dealerVisit,
                    ),
                    iconColor: const Color(0xFF8A6B2E),
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.agriculture_outlined,
                    title: 'Farmer Visits',
                    value: _displayValue(
                      report.farmerVisit,
                    ),
                    iconColor: const Color(0xFF4E7D5C),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // KM / TIME
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.route_outlined,
                    title: 'Total KM',
                    value: _displayValue(
                      report.totalKm,
                    ),
                    iconColor: const Color(0xFF287A4B),
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.timer_outlined,
                    title: 'Total Time',
                    value: _displayValue(
                      report.totalTime,
                    ),
                    iconColor: const Color(0xFF637A69),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // EXPENSE / MAP KM
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              3,
              12,
              10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Expense',
                    value: _displayValue(
                      report.expenseAmount,
                    ),
                    iconColor: const Color(0xFF8A6B2E),
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.location_on_outlined,
                    title: 'On Map KM',
                    value: _displayValue(
                      report.onMapKm,
                    ),
                    iconColor: const Color(0xFF4C7290),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }

    return value;
  }
}

// ========================================================================
// STATUS BADGE
// ========================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool present =
        status.toLowerCase() == 'present';

    final Color background = present
        ? const Color(0xFFEAF6EE)
        : const Color(0xFFFFEEEE);

    final Color foreground = present
        ? const Color(0xFF287A4B)
        : const Color(0xFFD45C5C);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            present
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 12,
            color: foreground,
          ),

          const SizedBox(width: 3),

          Text(
            status.isEmpty ? 'Unknown' : status,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// INFO ITEM
// ========================================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF7B847F),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF303934),
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
}