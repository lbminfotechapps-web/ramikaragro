import 'package:flutter/material.dart';

import '../../domain/entities/top_ten_dealer.dart';

class DealerCard extends StatelessWidget {
  final TopTenDealer dealer;
  final int index;
  final VoidCallback onTap;

  const DealerCard({
    super.key,
    required this.dealer,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEDF0F2),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildRank(),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dealer.outletName.isNotEmpty
                          ? dealer.outletName
                          : 'Unknown Dealer',
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color: Color(0xFF17202A),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF8A94A6),
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            dealer.outletAddress
                                    .isNotEmpty
                                ? dealer.outletAddress
                                : 'Address not available',
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Color(0xFF8A94A6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 62,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dealer.visitCount,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF2E7D32),
                      ),
                    ),

                    const Text(
                      'visits',
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRank() {
    final rank = index + 1;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: rank == 1
            ? const Color(0xFFFFF3CD)
            : rank == 2
                ? const Color(0xFFE9ECEF)
                : rank == 3
                    ? const Color(0xFFFDE2C5)
                    : const Color(0xFFF1F3F5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: rank == 1
                ? const Color(0xFFB7791F)
                : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }
}