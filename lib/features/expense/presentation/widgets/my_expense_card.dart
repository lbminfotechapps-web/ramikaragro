import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/my_expense_entity.dart';

class MyExpenseCard extends StatefulWidget {
  final MyExpenseEntity expense;

  const MyExpenseCard({super.key, required this.expense});

  @override
  State<MyExpenseCard> createState() => _MyExpenseCardState();
}

class _MyExpenseCardState extends State<MyExpenseCard> {
  bool showDetails = false;

  Color get primaryGreen => context.primaryColor;
  Color get mediumGreen => context.primaryColor;
  Color get lightGreen => context.primaryColor.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;

    return Container(
      // ============================================================
      // OPTIMIZED OUTER SPACE
      // ============================================================
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          // ============================================================
          // MAIN CARD
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              children: [
                // ======================================================
                // HEADER
                // ======================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: context.onPrimaryColor,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPENSE DATE',
                            style: AppTextStyles.badge.copyWith(
                              letterSpacing: 0.5,
                              color: context.secondaryTextColor,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            expense.expenseDate,
                            style: AppTextStyles.listTitle.copyWith(
                              color: context.cardTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Total',
                            style: AppTextStyles.badge.copyWith(
                              letterSpacing: 0.5,
                              color: context.secondaryTextColor,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            '₹ ${expense.dailyTotal}',
                            style: AppTextStyles.listTitle.copyWith(
                              color: context.cardTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    _statusBadge(expense.status),
                  ],
                ),

                const SizedBox(height: 10),

                // ======================================================
                // VISITED PLACE + TRAVEL MODE
                // ======================================================
                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        icon: Icons.location_on_rounded,
                        title: 'Visited Place',
                        value: expense.visitedPlace,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.directions_bike_rounded,
                        title: 'Travel Mode',
                        value: expense.travellingMode,
                      ),
                    ),
                  ],
                ),

                // ======================================================
                // REPORTING STATUS
                // ======================================================
                if (expense.reportingStatus.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),

                  _buildStatusBox(
                    title: 'REPORTING STATUS',
                    value: expense.reportingStatus,
                    icon: Icons.supervisor_account_rounded,
                    color: _getStatusColor(expense.reportingStatus),
                  ),
                ],

                // ======================================================
                // ADMIN STATUS
                // ======================================================
                if (expense.adminStatus.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),

                  _buildStatusBox(
                    title: 'ADMIN STATUS',
                    value: expense.adminStatus,
                    icon: Icons.admin_panel_settings_outlined,
                    color: _getStatusColor(expense.adminStatus),
                  ),
                ],

                // ======================================================
                // REMARK
                // ======================================================
                if (expense.remark.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),

                  _buildRemarkBox(expense.remark),
                ],

                const SizedBox(height: 9),

                // ======================================================
                // VIEW DETAILS BUTTON
                // ======================================================
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: showDetails ? primaryGreen : lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            showDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 19,
                            color: showDetails
                                ? context.onPrimaryColor
                                : primaryGreen,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            showDetails
                                ? 'Hide Expense Details'
                                : 'View Expense Details',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: showDetails
                                  ? context.onPrimaryColor
                                  : primaryGreen,
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: showDetails
                                  ? context.onPrimaryColor.withValues(
                                      alpha: 0.15,
                                    )
                                  : context.cardBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${expense.details.length}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: showDetails
                                    ? context.onPrimaryColor
                                    : mediumGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // EXPENSE DETAILS
          // ============================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: showDetails
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildDetails(expense),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // MAIN STATUS BADGE
  // ==================================================================

  Widget _statusBadge(String status) {
    final (label, backgroundColor, foregroundColor) = switch (status.trim()) {
      '1' => (
        'Approved',
        context.appSuccess.withValues(alpha: 0.1),
        context.appSuccess,
      ),
      '2' => (
        'Cancelled',
        context.appColors.error.withValues(alpha: 0.1),
        context.appColors.error,
      ),
      _ => (
        'Pending',
        context.appWarning.withValues(alpha: 0.1),
        context.appWarning,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foregroundColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
  // ==================================================================
  // STATUS COLOR
  // ==================================================================

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return context.appWarning;

      case '1':
      case 'approved':
      case 'approve':
        return context.appSuccess;

      case '2':
      case 'rejected':
      case 'reject':
        return context.appError;

      default:
        return mediumGreen;
    }
  }

  // ==================================================================
  // STATUS DISPLAY TEXT
  // ==================================================================

  String _statusDisplayText(String status) {
    switch (status.trim().toLowerCase()) {
      case '0':
        return 'Pending';

      case '1':
        return 'Approved';

      case '2':
        return 'Rejected';

      case 'pending':
        return 'Pending';

      case 'approved':
      case 'approve':
        return 'Approved';

      case 'rejected':
      case 'reject':
        return 'Rejected';

      default:
        return status.trim().isEmpty ? '-' : status.trim();
    }
  }

  // ==================================================================
  // STATUS BOX
  // ==================================================================

  Widget _buildStatusBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: color),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.badge.copyWith(
                    letterSpacing: 0.4,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _statusDisplayText(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // REMARK BOX
  // ==================================================================

  Widget _buildRemarkBox(String remark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 15,
              color: context.primaryColor,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REMARK',
                  style: AppTextStyles.badge.copyWith(
                    letterSpacing: 0.4,
                    color: context.primaryColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  remark,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.cardTextColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // INFO ITEM
  // ==================================================================

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: mediumGreen),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.badge.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.cardTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // EXPENSE DETAILS
  // ==================================================================

  Widget _buildDetails(MyExpenseEntity expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 0, 11, 11),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Divider(height: 1, color: context.borderColor),

          const SizedBox(height: 9),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EXPENSE BREAKDOWN',
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 0.6,
                color: context.secondaryTextColor,
              ),
            ),
          ),

          const SizedBox(height: 7),

          ...expense.details.map((detail) {
            return _detailItem(
              context: context,
              name: detail.expName,
              amount: detail.amount,
              image: detail.expenseImage,
            );
          }),
        ],
      ),
    );
  }

  // ==================================================================
  // DETAIL ITEM + IMAGE
  // ==================================================================

  Widget _detailItem({
    required BuildContext context,
    required String name,
    required String amount,
    required String image,
  }) {
    IconData icon = Icons.payments_outlined;

    final lowerName = name.toLowerCase();

    if (lowerName.contains('petrol')) {
      icon = Icons.local_gas_station_outlined;
    } else if (lowerName.contains('travel')) {
      icon = Icons.route_outlined;
    } else if (lowerName.contains('mobile')) {
      icon = Icons.phone_android_outlined;
    } else if (lowerName.contains('hotel') || lowerName.contains('lodge')) {
      icon = Icons.hotel_outlined;
    } else if (lowerName.contains('car')) {
      icon = Icons.directions_car_outlined;
    } else if (lowerName.contains('auto')) {
      icon = Icons.local_taxi_outlined;
    } else if (lowerName.contains('insurance')) {
      icon = Icons.shield_outlined;
    }

    final bool hasImage = image.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // ============================================================
          // EXPENSE NAME + AMOUNT
          // ============================================================
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: mediumGreen),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  name.isEmpty ? 'Expense' : name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.cardTextColor,
                  ),
                ),
              ),

              Text(
                '₹ $amount',
                style: AppTextStyles.labelSmall.copyWith(color: primaryGreen),
              ),
            ],
          ),

          // ============================================================
          // IMAGE
          // ============================================================
          if (hasImage) ...[
            const SizedBox(height: 7),

            GestureDetector(
              onTap: () {
                _showExpenseImage(context, image, name);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.network(
                      '${ApiClient.imageExpensetUrl}$image',
                      width: double.infinity,
                      height: 135,
                      fit: BoxFit.cover,

                      // Loading
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          width: double.infinity,
                          height: 135,
                          decoration: BoxDecoration(
                            color: context.appTheme.inputBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: mediumGreen,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },

                      // Error
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 135,
                          decoration: BoxDecoration(
                            color: context.appColors.error.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 28,
                                color: context.appColors.error,
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Unable to load image',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: context.appColors.error,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  image,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.badge.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Positioned(
                      right: 7,
                      bottom: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: context.onPrimaryColor,
                              size: 12,
                            ),

                            SizedBox(width: 3),

                            Text(
                              'View',
                              style: AppTextStyles.badge.copyWith(
                                color: context.onPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================================================================
  // FULL SCREEN IMAGE
  // ==================================================================

  void _showExpenseImage(
    BuildContext context,
    String imageName,
    String expenseName,
  ) {
    final imageUrl = '${ApiClient.imageExpensetUrl}$imageName';

    showDialog(
      context: context,
      barrierColor: context.appColors.shadow.withValues(alpha: 0.88),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======================================================
                // HEADER
                // ======================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 9, 7, 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          expenseName.isEmpty ? 'Expense Image' : expenseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: context.cardTextColor,
                          ),
                        ),
                      ),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.cardTextColor,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),

                // ======================================================
                // IMAGE
                // ======================================================
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: context.cardTextColor,
                            ),
                          ),
                        );
                      },

                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: context.secondaryTextColor,
                                  size: 42,
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'Unable to load image',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ======================================================
                // IMAGE NAME
                // ======================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Text(
                    imageName,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
