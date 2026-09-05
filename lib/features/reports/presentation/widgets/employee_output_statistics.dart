import 'package:flutter/material.dart';

import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputStatistics
    extends StatelessWidget {
  final List<EmployeeOutputReport>
      reports;

  const EmployeeOutputStatistics({
    super.key,
    required this.reports,
  });

  int _toInt(String value) {
    return int.tryParse(value) ?? 0;
  }

  int get totalDealerVisits {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(item.outletCnt),
    );
  }

  int get totalFarmerVisits {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(item.farmerCnt),
    );
  }

  int get totalLocations {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(item.currentCnt),
    );
  }

  int get totalVisits {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(item.totalVisits),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
            color:
                Color(0xFF202923),
          ),
        ),

        const SizedBox(height: 7),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Dealer',
                value:
                    '$totalDealerVisits',
                icon:
                    Icons.storefront_outlined,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: _StatCard(
                title: 'Farmer',
                value:
                    '$totalFarmerVisits',
                icon:
                    Icons.agriculture_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Location',
                value:
                    '$totalLocations',
                icon:
                    Icons.location_on_outlined,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: _StatCard(
                title: 'Total Visits',
                value:
                    '$totalVisits',
                icon:
                    Icons.analytics_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,

      padding:
          const EdgeInsets.all(8),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.03),
            blurRadius: 7,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEAF6EE),
              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Icon(
              icon,
              size: 17,
              color:
                  const Color(0xFF287A4B),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 9.5,
                    color:
                        Color(0xFF7A837E),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 18,
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