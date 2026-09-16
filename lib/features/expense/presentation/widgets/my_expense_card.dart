import 'package:demo/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/my_expense_entity.dart';

class MyExpenseCard extends StatefulWidget {
  final MyExpenseEntity expense;

  const MyExpenseCard({
    super.key,
    required this.expense,
  });

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

    final bool approved = expense.status == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3EAE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // MAIN CARD
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ======================================================
                // HEADER
                // ======================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE8F5ED),
                            Color(0xFFD8EEE0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: mediumGreen,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPENSE DATE',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.7,
                              color: Color(0xFF8A938D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            expense.expenseDate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF18231C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _statusBadge(approved),
                  ],
                ),

                const SizedBox(height: 18),

                // ======================================================
                // TOTAL EXPENSE
                // ======================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F9F7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL EXPENSE',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: Color(0xFF8A938D),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Daily total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF69756E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        '₹ ${expense.dailyTotal}',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

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

                    const SizedBox(width: 10),

                    Expanded(
                      child: _infoItem(
                        icon: Icons.directions_bike_rounded,
                        title: 'Travel Mode',
                        value: expense.travellingMode,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ======================================================
                // VIEW DETAILS BUTTON
                // ======================================================
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: showDetails ? primaryGreen : lightGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            showDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 21,
                            color: showDetails
                                ? Colors.white
                                : primaryGreen,
                          ),

                          const SizedBox(width: 7),

                          Text(
                            showDetails
                                ? 'Hide Expense Details'
                                : 'View Expense Details',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: showDetails
                                  ? Colors.white
                                  : primaryGreen,
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: showDetails
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${expense.details.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: showDetails
                                    ? Colors.white
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
  // STATUS BADGE
  // ==================================================================

  Widget _statusBadge(bool approved) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: approved
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: approved
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),

          const SizedBox(width: 5),

          Text(
            approved ? 'Approved' : 'Pending',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: approved
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEDF1EE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: mediumGreen,
            ),
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
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF8A938D),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
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
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAF8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const Divider(
            height: 1,
            color: Color(0xFFE3EAE5),
          ),

          const SizedBox(height: 14),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EXPENSE BREAKDOWN',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6D7971),
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...expense.details.map(
            (detail) {
              return _detailItem(
                context: context,
                name: detail.expName,
                amount: detail.amount,
                image: detail.expenseImage,
              );
            },
          ),
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
    } else if (lowerName.contains('hotel') ||
        lowerName.contains('lodge')) {
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE6ECE8),
        ),
      ),
      child: Column(
        children: [
          // ============================================================
          // EXPENSE NAME + AMOUNT
          // ============================================================

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: mediumGreen,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  name.isEmpty ? 'Expense' : name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263229),
                  ),
                ),
              ),

              Text(
                '₹ $amount',
                style: const TextStyle(
                  fontSize: 12,
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
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                _showExpenseImage(
                  context,
                  image,
                  name,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      '${ApiClient.imageExpensetUrl}$image',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,

                      // Loading
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: mediumGreen,
                              value: loadingProgress
                                          .expectedTotalBytes !=
                                      null
                                  ? loadingProgress
                                          .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },

                      // Error
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image_outlined,
                                size: 36,
                                color: Color(0xFFC62828),
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Unable to load image',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC62828),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  image,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF8A938D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // VIEW IMAGE OVERLAY
                    // ==================================================

                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
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
    final imageUrl =
        '${ApiClient.imageExpensetUrl}$imageName';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======================================================
                // HEADER
                // ======================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          expenseName.isEmpty
                              ? 'Expense Image'
                              : expenseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
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

                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const SizedBox(
                          height: 350,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const SizedBox(
                          height: 350,
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                  size: 50,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Unable to load image',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
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

                const SizedBox(height: 14),

                // ======================================================
                // IMAGE NAME
                // ======================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  child: Text(
                    imageName,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
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