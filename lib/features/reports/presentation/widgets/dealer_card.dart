import 'package:flutter/material.dart';

import '../../domain/entities/not_visited_dealer.dart';

class DealerCard extends StatelessWidget {
  final NotVisitedDealer dealer;

  const DealerCard({
    super.key,
    required this.dealer,
  });

  @override
  Widget build(BuildContext context) {
    final name = dealer.outletName.trim().isNotEmpty
        ? dealer.outletName.trim()
        : 'Unknown Dealer';

    final initials = _getInitials(name);

    final hasMobile = dealer.mobile.trim().isNotEmpty;
    final hasAddress = dealer.address.trim().isNotEmpty;
    final lastVisit = dealer.lastTransactionDate?.trim();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8ECEF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            children: [
              // Avatar
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF168A4A),
                      Color(0xFF29A961),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              // Name + ID
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF17202A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Dealer ID: ${dealer.outletId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF89939D),
                      ),
                    ),
                  ],
                ),
              ),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Not Visited',
                  style: TextStyle(
                    color: Color(0xFFE47720),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          // =====================================================
          // MOBILE + LAST VISIT
          // =====================================================

          Row(
            children: [
              if (hasMobile)
                Expanded(
                  child: _InfoItem(
                    icon: Icons.phone_rounded,
                    text: dealer.mobile,
                  ),
                ),

              if (hasMobile)
                const SizedBox(width: 10),

              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  text: lastVisit?.isNotEmpty == true
                      ? lastVisit!
                      : 'Never',
                  iconColor: lastVisit?.isNotEmpty == true
                      ? const Color(0xFF168A4A)
                      : const Color(0xFFE47720),
                ),
              ),
            ],
          ),

          // =====================================================
          // ADDRESS
          // =====================================================

          if (hasAddress) ...[
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 17,
                  color: Color(0xFF168A4A),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    dealer.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Color(0xFF5F6871),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // INITIALS
  // =============================================================

  String _getInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'D';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(
            0,
            parts.first.length >= 2 ? 2 : 1,
          )
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

// =============================================================
// INFO ITEM
// =============================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _InfoItem({
    required this.icon,
    required this.text,
    this.iconColor = const Color(0xFF168A4A),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4F5963),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}