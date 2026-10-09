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

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFE8F5ED);

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;

    return Container(
      // ============================================================
      // OPTIMIZED OUTER SPACE
      // ============================================================
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5ED), Color(0xFFD8EEE0)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: mediumGreen,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPENSE DATE',
                            style: TextStyle(
                              fontSize: 8,
                              letterSpacing: 0.5,
                              color: Color(0xFF8A938D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            expense.expenseDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF18231C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Total',
                            style: TextStyle(
                              fontSize: 8,
                              letterSpacing: 0.5,
                              color: Color(0xFF8A938D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            '₹ ${expense.dailyTotal}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF18231C),
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
                            color: showDetails ? Colors.white : primaryGreen,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            showDetails
                                ? 'Hide Expense Details'
                                : 'View Expense Details',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: showDetails ? Colors.white : primaryGreen,
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
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${expense.details.length}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: showDetails ? Colors.white : mediumGreen,
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
      '1' => ('Approved', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      '2' => ('Cancelled', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      _ => ('Pending', const Color(0xFFFFF4E5), const Color(0xFFE65100)),
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
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: foregroundColor,
            ),
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
        return Colors.orange;

      case '1':
      case 'approved':
      case 'approve':
        return Colors.green;

      case '2':
      case 'rejected':
      case 'reject':
        return Colors.red;

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
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.13)),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
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
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 0.4,
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _statusDisplayText(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w900,
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
  // REMARK BOX
  // ==================================================================

  Widget _buildRemarkBox(String remark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE7FA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: const BoxDecoration(
              color: Color(0xFFE6EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notes_rounded,
              size: 15,
              color: Color(0xFF4267A8),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REMARK',
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 0.4,
                    color: Color(0xFF4267A8),
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  remark,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF37474F),
                    fontWeight: FontWeight.w600,
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
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEDF1EE)),
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
                  style: const TextStyle(
                    fontSize: 7,
                    color: Color(0xFF8A938D),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263229),
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
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAF8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE3EAE5)),

          const SizedBox(height: 9),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EXPENSE BREAKDOWN',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6D7971),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE6ECE8)),
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
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263229),
                  ),
                ),
              ),

              Text(
                '₹ $amount',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: primaryGreen,
                ),
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
                            color: const Color(0xFFF1F5F2),
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
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image_outlined,
                                size: 28,
                                color: Color(0xFFC62828),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Unable to load image',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC62828),
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
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF8A938D),
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
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 12,
                            ),

                            SizedBox(width: 3),

                            Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
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
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
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

                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },

                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                  size: 42,
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'Unable to load image',
                                  style: TextStyle(
                                    color: Colors.white70,
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
                    style: const TextStyle(color: Colors.white54, fontSize: 9),
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
