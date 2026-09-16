
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';
import 'package:flutter/material.dart';

import 'crop_schedule_detail_card.dart';

class CropScheduleCard extends StatefulWidget {
  final CropSchedule schedule;

  const CropScheduleCard({
    super.key,
    required this.schedule,
  });

  @override
  State<CropScheduleCard> createState() => _CropScheduleCardState();
}

class _CropScheduleCardState extends State<CropScheduleCard> {
  bool _showDetails = false;

  CropSchedule get schedule => widget.schedule;

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFEAF5EE);
  static const Color borderGreen = Color(0xFFD5E8DC);

  String get imageUrl {
    if (schedule.attachment.isNotEmpty) {
      return '${ApiClient.imageCropscheduleUrl}${schedule.attachment}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasDetails = schedule.details.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _showDetails
              ? const Color(0xFFB7D8C3)
              : const Color(0xFFE8EDE9),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // =========================================================
          // MAIN HEADER
          // =========================================================

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =====================================================
                // IMAGE
                // =====================================================

                Hero(
                  tag: 'crop-${schedule.cropId}',
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: lightGreen,
                      border: Border.all(
                        color: const Color(0xFFDCEBE1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const _ImagePlaceholder();
                              },
                              loadingBuilder: (
                                context,
                                child,
                                progress,
                              ) {
                                if (progress == null) {
                                  return child;
                                }

                                return const _ImageLoading();
                              },
                            )
                          : const _ImagePlaceholder(),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // =====================================================
                // INFORMATION
                // =====================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small label
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'CROP SCHEDULE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: mediumGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Crop name
                      Text(
                        schedule.cropName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.35,
                          color: Color(0xFF17221B),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Schedule count
                     
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // VIEW DETAILS
          // =========================================================

          if (hasDetails)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _showDetails
                            ? const [
                                Color(0xFFE3F2E9),
                                Color(0xFFF2F9F4),
                              ]
                            : const [
                                Color(0xFFF7FAF8),
                                Color(0xFFF1F7F3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showDetails
                            ? const Color(0xFFB8D8C4)
                            : const Color(0xFFDDE9E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.06),
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _showDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.visibility_outlined,
                            size: 19,
                            color: primaryGreen,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showDetails
                                    ? 'Hide Details'
                                    : 'View Details',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _showDetails
                                    ? 'Close schedule information'
                                    : 'View complete schedule',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF7A857E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${schedule.details.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // =========================================================
          // DETAILS SECTION
          // =========================================================

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _showDetails && hasDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  child: Container(
                    height: 1,
                    color: const Color(0xFFEDF1EE),
                  ),
                ),

                // ===================================================
                // SECTION HEADER
                // ===================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    16,
                    14,
                    8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 28,
                        decoration: BoxDecoration(
                          color: mediumGreen,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Schedule Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C271F),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Crop activity timeline',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF89928C),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: borderGreen,
                          ),
                        ),
                        child: Text(
                          '${schedule.details.length} Steps',
                          style: const TextStyle(
                            fontSize: 10,
                            color: mediumGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===================================================
                // DETAIL LIST
                // ===================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    6,
                    14,
                    8,
                  ),
                  child: Column(
                    children: List.generate(
                      schedule.details.length,
                      (index) {
                        final detail = schedule.details[index];

                        // return CropScheduleDetailCard(
                        //   detail: detail,
                        //   isLast: index ==
                        //       schedule.details.length - 1,
                        // );

                          return CropScheduleDetailCard(
                            detail: detail,
                          );

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // NO DETAILS
          // =========================================================

          if (!hasDetails)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8ECE9),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Color(0xFF8A938D),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'No schedule details available.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A837D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================
// IMAGE PLACEHOLDER
// =============================================================

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF5EE),
            Color(0xFFDDEFE4),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.agriculture_rounded,
            size: 27,
            color: Color(0xFF2D6A4F),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// IMAGE LOADING
// =============================================================

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F7F4),
      child: const Center(
        child: SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Color(0xFF2D6A4F),
          ),
        ),
      ),
    );
  }
}

