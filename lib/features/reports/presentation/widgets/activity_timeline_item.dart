import 'package:demo/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/employee_activity.dart';

class ActivityTimelineItem extends StatelessWidget {
  final EmployeeActivity activity;
  final bool isFirst;
  final bool isLast;

  const ActivityTimelineItem({
    super.key,
    required this.activity,
    required this.isFirst,
    required this.isLast,
  });

  Color get _activityColor {
    final name = activity.activityName.toUpperCase();

    if (name.contains('IN PUNCH')) {
      return const Color(0xFF168A45);
    }

    if (name.contains('OUT PUNCH')) {
      return const Color(0xFFE53935);
    }

    if (name.contains('FARMER')) {
      return const Color(0xFFF28C28);
    }

    if (name.contains('SHARE LOCATION')) {
      return const Color(0xFF1976D2);
    }

    return const Color(0xFF7E57C2);
  }

  IconData get _activityIcon {
    final name = activity.activityName.toUpperCase();

    if (name.contains('IN PUNCH')) {
      return Icons.login_rounded;
    }

    if (name.contains('OUT PUNCH')) {
      return Icons.logout_rounded;
    }

    if (name.contains('FARMER')) {
      return Icons.agriculture_rounded;
    }

    if (name.contains('SHARE LOCATION')) {
      return Icons.location_on_rounded;
    }

    return Icons.notifications_active_rounded;
  }

  String get _visitName {
    if (activity.farmerName.trim().isNotEmpty) {
      return activity.farmerName.trim();
    }

    if (activity.outletName.trim().isNotEmpty) {
      return activity.outletName.trim();
    }

    if (activity.visitTo.trim().isNotEmpty) {
      return activity.visitTo.trim();
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========================================================
          // TIMELINE
          // ========================================================

          SizedBox(
            width: 42,
            child: Column(
              children: [
                // TOP LINE
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: _activityColor.withOpacity(0.20),
                    ),
                  )
                else
                  const Expanded(
                    child: SizedBox(),
                  ),

                // ICON
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: _activityColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _activityColor.withOpacity(0.25),
                      width: 1.3,
                    ),
                  ),
                  child: Icon(
                    _activityIcon,
                    color: _activityColor,
                    size: 18,
                  ),
                ),

                // BOTTOM LINE
                if (!isLast)
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: 2,
                      color: _activityColor.withOpacity(0.20),
                    ),
                  )
                else
                  const Expanded(
                    child: SizedBox(),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ========================================================
          // ACTIVITY CARD
          // ========================================================

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _activityColor.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 7,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE + TIME
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _activityColor.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            activity.activityName.isEmpty
                                ? 'Activity'
                                : activity.activityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _activityColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        activity.time,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // ==================================================
                  // VISIT
                  // ==================================================

                  if (_visitName.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      title: 'Visit',
                      value: _visitName,
                    ),
                  ],

                  // ==================================================
                  // FARMER
                  // ==================================================

                  if (activity.farmerName.trim().isNotEmpty &&
                      activity.farmerName.trim() != _visitName) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.agriculture_rounded,
                      title: 'Farmer',
                      value: activity.farmerName,
                    ),
                  ],

                  // ==================================================
                  // OUTLET
                  // ==================================================

                  if (activity.outletName.trim().isNotEmpty &&
                      activity.outletName.trim() != _visitName) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.storefront_outlined,
                      title: 'Outlet',
                      value: activity.outletName,
                    ),
                  ],

                  // ==================================================
                  // TRANSACTION
                  // ==================================================

                  if (activity.dailyTranId.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.receipt_long_outlined,
                      title: 'Transaction',
                      value: activity.dailyTranId,
                    ),
                  ],

                  // ==================================================
                  // EMPLOYEE
                  // ==================================================

                  if (activity.adminName.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Employee',
                      value: activity.adminName,
                    ),
                  ],

                  // ==================================================
                  // SELFIE
                  // ==================================================

                  if (activity.selfieImage.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SelfieImage(
                      imageName: activity.selfieImage,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF78817B),
        ),

        const SizedBox(width: 6),

        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7A827D),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF303632),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SELFIE IMAGE
// ============================================================================

class _SelfieImage extends StatelessWidget {
  final String imageName;

  const _SelfieImage({
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        '${ApiClient.imageBaseUrl}$imageName';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,

              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: const Color(0xFFF1F3F2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF168A45),
                    ),
                  ),
                );
              },

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: const Color(0xFFF1F3F2),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF8A918D),
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: Color(0xFF8A918D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // SELFIE LABEL
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Selfie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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