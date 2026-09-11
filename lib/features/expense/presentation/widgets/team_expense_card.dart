
import 'package:demo/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/team_expense_entity.dart';
import '../bloc/team_expense_bloc.dart';
import '../bloc/team_expense_event.dart';

class TeamExpenseCard extends StatelessWidget {
  final TeamExpenseEntity expense;

  // ADDED: userId required for approve/reject API
  final int userId;

  const TeamExpenseCard({
    super.key,
    required this.expense,
    required this.userId, // ADDED
  });

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFE8F5ED);

  @override
  Widget build(BuildContext context) {
    final String status = expense.status.trim();

    final bool isPending = status == '0';
    final bool isApproved = status == '1';
    final bool isRejected = status == '2';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ------------------------------------------------------------
            // HEADER
            // ------------------------------------------------------------
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: mediumGreen,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.expenseBy.isNotEmpty
                            ? expense.expenseBy
                            : 'Employee #${expense.createdBy}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18231C),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: Color(0xFF7A857E),
                          ),

                          const SizedBox(width: 4),

                          Text(
                            expense.expenseDate,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7A857E),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9AA49E),
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            '#${expense.expenseId}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7A857E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _statusBadge(
                  isPending: isPending,
                  isApproved: isApproved,
                  isRejected: isRejected,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------------
            // TOTAL EXPENSE
            // ------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F9F7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: mediumGreen,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL EXPENSE',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.7,
                            color: Color(0xFF8A938D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Daily total',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF69756E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₹ ${expense.dailyTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            // ------------------------------------------------------------
            // BASIC INFORMATION
            // ------------------------------------------------------------
            _infoRow(
              Icons.location_on_outlined,
              'Visited Place',
              expense.visitedPlace,
            ),

            _infoRow(
              Icons.directions_bike_outlined,
              'Travel Mode',
              expense.travellingMode,
            ),

            if (expense.daExpenses > 0)
              _infoRow(
                Icons.account_balance_wallet_outlined,
                'DA Expense',
                '₹ ${expense.daExpenses.toStringAsFixed(2)}',
              ),

            if (expense.remark.trim().isNotEmpty)
              _infoRow(
                Icons.comment_outlined,
                'Remark',
                expense.remark,
              ),

            const SizedBox(height: 7),

            const Divider(
              height: 1,
              color: Color(0xFFE8EDE9),
            ),

            const SizedBox(height: 9),

            // ------------------------------------------------------------
            // APPROVED + REPORTING
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _amountItem(
                    'Approved',
                    expense.approveAmount,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statusItem(
                    'Reporting',
                    expense.reportingStatus,
                  ),
                ),
              ],
            ),

            // ------------------------------------------------------------
            // ADMIN STATUS
            // ------------------------------------------------------------
            if (expense.adminStatus.trim().isNotEmpty) ...[
              const SizedBox(height: 9),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFE8F5E9)
                      : isRejected
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle_outline_rounded
                          : isRejected
                              ? Icons.cancel_outlined
                              : Icons.pending_outlined,
                      size: 17,
                      color: isApproved
                          ? Colors.green.shade700
                          : isRejected
                              ? Colors.red.shade700
                              : Colors.orange.shade800,
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        expense.adminStatus,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isApproved
                              ? Colors.green.shade700
                              : isRejected
                                  ? Colors.red.shade700
                                  : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ------------------------------------------------------------
            // ACTION BUTTONS
            // ------------------------------------------------------------
            const SizedBox(height: 10),

            Row(
              children: [
                // DETAILS
                if (expense.details.isNotEmpty)
                  Expanded(
                    child: _compactOutlineButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Details',
                      color: mediumGreen,
                      borderColor: const Color(0xFFBFD5C7),
                      onPressed: () {
                        _showExpenseDetails(
                          context,
                          expense,
                        );
                      },
                    ),
                  ),

                if (expense.details.isNotEmpty && isPending)
                  const SizedBox(width: 7),

                // APPROVE
                if (isPending)
                  Expanded(
                    child: _compactButton(
                      icon: Icons.check_rounded,
                      label: 'Approve',
                      backgroundColor: mediumGreen,
                      onPressed: () {
                        _showApproveDialog(
                          context,
                          expense,
                        );
                      },
                    ),
                  ),

                if (isPending)
                  const SizedBox(width: 7),

                // REJECT
                if (isPending)
                  Expanded(
                    child: _compactOutlineButton(
                      icon: Icons.close_rounded,
                      label: 'Reject',
                      color: const Color(0xFFD32F2F),
                      borderColor: const Color(0xFFE5BABA),
                      onPressed: () {
                        _showRejectDialog(
                          context,
                          expense,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS BADGE
  // ===========================================================================

  Widget _statusBadge({
    required bool isPending,
    required bool isApproved,
    required bool isRejected,
  }) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;
    final String text;

    if (isApproved) {
      backgroundColor = const Color(0xFFE8F5E9);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
      text = 'Approved';
    } else if (isRejected) {
      backgroundColor = const Color(0xFFFFEBEE);
      textColor = Colors.red.shade700;
      icon = Icons.cancel;
      text = 'Rejected';
    } else {
      backgroundColor = const Color(0xFFFFF4E5);
      textColor = Colors.orange.shade800;
      icon = Icons.schedule;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: mediumGreen,
          ),

          const SizedBox(width: 7),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF68736C),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF263229),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // AMOUNT ITEM
  // ===========================================================================

  Widget _amountItem(
    String title,
    double amount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6ECE8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8A938D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STATUS ITEM
  // ===========================================================================

  Widget _statusItem(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6ECE8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8A938D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COMPACT FILLED BUTTON
  // ===========================================================================

  Widget _compactButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPACT OUTLINE BUTTON
  // ===========================================================================

  Widget _compactOutlineButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: borderColor,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // APPROVE CONFIRMATION
  // ===========================================================================

  void _showApproveDialog(
    BuildContext context,
    TeamExpenseEntity expense,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            5,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            8,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            12,
            4,
            12,
            12,
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF2D6A4F),
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'Approve Expense',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Text(
            'Approve expense #${expense.expenseId} '
            'for ₹${expense.dailyTotal.toStringAsFixed(2)}?',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF68736C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF68736C),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _updateExpense(
                  context,
                  expense,
                  '1',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mediumGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // REJECT CONFIRMATION
  // ===========================================================================

  void _showRejectDialog(
    BuildContext context,
    TeamExpenseEntity expense,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            5,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            8,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            12,
            4,
            12,
            12,
          ),
          title: const Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: Color(0xFFD32F2F),
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'Reject Expense',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Text(
            'Reject expense #${expense.expenseId} '
            'for ₹${expense.dailyTotal.toStringAsFixed(2)}?',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF68736C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF68736C),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _updateExpense(
                  context,
                  expense,
                  '2',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // UPDATE EXPENSE
  // ===========================================================================

  void _updateExpense(
    BuildContext context,
    TeamExpenseEntity expense,
    String status,
  ) {
    context.read<TeamExpenseBloc>().add(
          UpdateTeamExpenseEvent(
            // FIX: userId now comes from TeamExpenseCard
            userId: userId,
            expenseId: expense.expenseId,
            status: status,
          ),
        );
  }

  // ===========================================================================
  // EXPENSE DETAILS BOTTOM SHEET
  // ===========================================================================

  void _showExpenseDetails(
    BuildContext context,
    TeamExpenseEntity expense,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 9),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DDD8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  15,
                  12,
                  10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: mediumGreen,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expense Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF18231C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expense #${expense.expenseId}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7A857E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: expense.details.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final detail =
                        expense.details[index];

                    return _detailCard(
                      context,
                      detail,
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  18,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F9F7),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Expense',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF526057),
                        ),
                      ),
                    ),

                    Text(
                      '₹ ${expense.dailyTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // DETAIL CARD
  // ===========================================================================

  Widget _detailCard(
    BuildContext context,
    TeamExpenseDetailEntity detail,
  ) {
    final String imageName =
        detail.expenseImage.trim();

    final bool hasImage = imageName.isNotEmpty;

    String imageUrl = '';

    if (hasImage) {
      if (imageName.startsWith('http://') ||
          imageName.startsWith('https://')) {
        imageUrl = imageName;
      } else {
        imageUrl =
            '${ApiClient.imageExpensetUrl}$imageName';
      }
    }

    debugPrint(
      'Expense Name: ${detail.expenseName}',
    );

    debugPrint(
      'Expense Image: $imageName',
    );

    debugPrint(
      'Expense Image URL: $imageUrl',
    );

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE3EAE5),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  hasImage
                      ? Icons.image_outlined
                      : Icons.receipt_outlined,
                  color: mediumGreen,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.expenseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263229),
                      ),
                    ),

                    if (detail.expenseRemark
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        detail.expenseRemark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF7A857E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '₹ ${detail.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          if (hasImage) ...[
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                _showFullImage(
                  context,
                  imageUrl,
                  detail.expenseName,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 170,
                  color: const Color(0xFFF1F5F2),
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

                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: mediumGreen,
                        ),
                      );
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      debugPrint(
                        'IMAGE LOAD ERROR: $error',
                      );

                      debugPrint(
                        'FAILED IMAGE URL: $imageUrl',
                      );

                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 38,
                              color: Color(0xFF8A938D),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7A857E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 12,
                  color: mediumGreen,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    imageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF7A857E),
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                const Text(
                  'Tap to view',
                  style: TextStyle(
                    fontSize: 8,
                    color: mediumGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // FULL IMAGE
  // ===========================================================================

  void _showFullImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

