
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';
import 'package:flutter/material.dart';

import 'crop_schedule_detail_card.dart';

class CropScheduleCard extends StatelessWidget {
  final CropSchedule schedule;

  const CropScheduleCard({
    super.key,
    required this.schedule,
  });

  String get imageUrl {
    if (schedule.attachment.isNotEmpty) {
      return '${ApiClient.imageBaseUrl}${schedule.attachment}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // CROP IMAGE
                // ------------------------------------------------

                Hero(
                  tag: 'crop-${schedule.cropId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: SizedBox(
                      width: 92,
                      height: 92,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return _ImagePlaceholder(
                                  icon: Icons.agriculture_rounded,
                                );
                              },
                              loadingBuilder:
                                  (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }

                                return const _ImageLoading();
                              },
                            )
                          : const _ImagePlaceholder(
                              icon: Icons.agriculture_rounded,
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // ------------------------------------------------
                // CROP INFORMATION
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Crop name
                      Text(
                        schedule.cropName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight(16),
                          letterSpacing: -0.3,
                        ),
                      ),

                    
            
                      const SizedBox(height: 10),

                      // Steps
                      Row(
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${schedule.details.length} '
                            '${schedule.details.length == 1 ? 'schedule step' : 'schedule steps'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // DIVIDER
          // =====================================================

          if (schedule.details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),

          // =====================================================
          // SECTION TITLE
          // =====================================================

          if (schedule.details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF176B3A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Text(
                    'Schedule Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // =====================================================
          // DETAILS
          // =====================================================

          if (schedule.details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                6,
              ),
              child: Column(
                children: [
                  ...List.generate(
                    schedule.details.length,
                    (index) {
                      final detail =
                          schedule.details[index];

                      return CropScheduleDetailCard(
                        detail: detail,
                        isLast:
                            index ==
                                schedule.details.length - 1,
                      );
                    },
                  ),
                ],
              ),
            ),

          // =====================================================
          // NO DETAILS
          // =====================================================

          if (schedule.details.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                18,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'No schedule details available.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
  final IconData icon;

  const _ImagePlaceholder({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      child: Center(
        child: Icon(
          icon,
          size: 34,
          color: Colors.green.shade600,
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
      color: Colors.grey.shade100,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

