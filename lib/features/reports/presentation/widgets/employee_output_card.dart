import 'package:flutter/material.dart';

import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputCard
    extends StatelessWidget {
  final EmployeeOutputReport report;

  const EmployeeOutputCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          12,
          11,
          12,
          10,
        ),

        child: Column(
          children: [
            // ======================================================
            // EMPLOYEE
            // ======================================================

            Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFEAF6EE),
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color:
                        Color(0xFF287A4B),
                    size: 21,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.empName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF202923),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Employee ID: ${report.empId}',
                        style:
                            const TextStyle(
                          fontSize: 10,
                          color:
                              Color(0xFF7A837E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ======================================================
            // DEALER / FARMER
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: _VisitItem(
                    icon:
                        Icons.storefront_outlined,
                    title: 'Dealer',
                    value:
                        report.outletCnt,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _VisitItem(
                    icon:
                        Icons.agriculture_outlined,
                    title: 'Farmer',
                    value:
                        report.farmerCnt,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // ======================================================
            // LOCATION / TOTAL
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: _VisitItem(
                    icon:
                        Icons.location_on_outlined,
                    title: 'Location',
                    value:
                        report.currentCnt,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _VisitItem(
                    icon:
                        Icons.analytics_outlined,
                    title: 'Total Visits',
                    value:
                        report.totalVisits,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// VISIT ITEM
// ================================================================

class _VisitItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _VisitItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF7F9F8),
        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF287A4B),
          ),

          const SizedBox(width: 7),

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
                    color:
                        Color(0xFF7A837E),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF202923),
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