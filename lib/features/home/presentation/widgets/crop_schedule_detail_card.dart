
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/utility/widgets/custom_loader.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule_detail.dart';
import 'package:flutter/material.dart';

class CropScheduleDetailCard extends StatelessWidget {
  final CropScheduleDetail detail;
  final bool isLast;

  const CropScheduleDetailCard({
    super.key,
    required this.detail,
    this.isLast = false,
  });

  String get imageUrl {
    if (detail.attachment.isNotEmpty) {
      return '${ApiClient.imageBaseUrl}${detail.attachment}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =====================================================
          // TIMELINE
          // =====================================================

          SizedBox(
            width: 34,
            child: Column(
              children: [
                // Number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF176B3A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      detail.sequenceNo.isEmpty
                          ? '•'
                          : detail.sequenceNo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Timeline line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      color: Colors.green.shade100,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // =====================================================
          // DETAIL CONTENT
          // =====================================================

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // IMAGE
                  // ------------------------------------------------

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 82,
                      height: 82,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }

                              return const CustomLoader(
           
            );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade400,
                                size: 28,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // TEXT
                  // ------------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Step title
                        Text(
                          'Step ${detail.sequenceNo}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // Description
                        if (detail.description.isNotEmpty)
                          Text(
                            detail.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Colors.grey.shade700,
                            ),
                          )
                        else
                          Text(
                            'No description available',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                            ),
                          ),

                        const SizedBox(height: 9),

                        // Schedule ID
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(7),
                          ),
                          child: Text(
                            'Schedule #${detail.scheduleId}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
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

