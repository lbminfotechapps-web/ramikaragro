import 'package:solufine/core/theme/app_theme_context.dart';
import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/team_expense_entity.dart';
import '../bloc/team_expense_bloc.dart';
import '../bloc/team_expense_event.dart';

class TeamExpenseCard extends StatelessWidget {
  final TeamExpenseEntity expense;
  final int userId;

  const TeamExpenseCard({
    super.key,
    required this.expense,
    required this.userId,
  });

  // ============================================================
  // COLORS
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // fld_status controls the reporting status and available actions.
    final String status = expense.status.trim();

    final bool isPending = status == '0';
    final bool isApproved = status == '1';
    final bool isRejected = status == '2';

    final String employeeName = expense.expenseBy.trim().isNotEmpty
        ? expense.expenseBy.trim()
        : 'Employee #${expense.createdBy}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Row(
              children: [
                // Employee icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.appColors.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color:  context.backgroundColor,
                    size: 21,
                  ),
                ),

                SizedBox(width: 10),

                // Employee name + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: context.primaryTextColor,
                        ),
                      ),

                      SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: context.secondaryTextColor,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              expense.expenseDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // Status
                _statusBadge(
                  context,
                  isPending: isPending,
                  isApproved: isApproved,
                  isRejected: isRejected,
                ),
              ],
            ),

            SizedBox(height: 10),

            // ============================================================
            // TOTAL EXPENSE
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: context.appTheme.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.appColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color:  context.backgroundColor,
                      size: 19,
                    ),
                  ),

                  SizedBox(width: 9),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL EXPENSE',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.6,
                            color: context.secondaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Daily total',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₹ ${expense.dailyTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // ============================================================
            // BASIC INFORMATION
            // ============================================================
            _infoRow(
              context,
              Icons.location_on_outlined,
              'Visited Place',
              expense.visitedPlace,
            ),

            _infoRow(
              context,
              Icons.directions_bike_outlined,
              'Travel Mode',
              expense.travellingMode,
            ),

            if (expense.daExpenses > 0)
              _infoRow(
                context,
                Icons.account_balance_wallet_outlined,
                'DA Expense',
                '₹ ${expense.daExpenses.toStringAsFixed(2)}',
              ),

            if (expense.remark.trim().isNotEmpty)
              _infoRow(
                context,
                Icons.comment_outlined,
                'Remark',
                expense.remark,
              ),

            SizedBox(height: 6),

            Divider(height: 1, color: context.borderColor),

            SizedBox(height: 8),

            // ============================================================
            // APPROVED AMOUNT
            // ============================================================
            _amountItem(context, 'Approved Amount', expense.approveAmount),

            SizedBox(height: 7),

            // ============================================================
            // REPORTING STATUS
            // ============================================================
            _statusItem(context, 'Reporting Status', expense.reportingStatus),

            // ============================================================
            // ADMIN STATUS
            // ============================================================
            if (expense.adminStatus.trim().isNotEmpty) ...[
              SizedBox(height: 8),
              _adminStatus(
                context,
                isApproved: isApproved,
                isRejected: isRejected,
                status: expense.adminStatus,
              ),
            ],

            // ============================================================
            // ACTION BUTTONS
            // ============================================================
            if (expense.details.isNotEmpty || isPending) ...[
              SizedBox(height: 9),

              Row(
                children: [
                  // Details
                  if (expense.details.isNotEmpty)
                    Expanded(
                      child: _compactOutlineButton(
                        context,
                        icon: Icons.receipt_long_outlined,
                        label: 'Details',
                        color: context.primaryColor,
                        borderColor: context.borderColor,
                        onPressed: () {
                          _showExpenseDetails(context, expense);
                        },
                      ),
                    ),

                  if (expense.details.isNotEmpty && isPending)
                    SizedBox(width: 6),

                  // Approve
                  if (isPending)
                    Expanded(
                      child: _compactButton(
                        context,
                        icon: Icons.check_rounded,
                        label: 'Approve',
                        backgroundColor: context.primaryColor,
                        onPressed: () {
                          _showApproveDialog(context, expense);
                        },
                      ),
                    ),

                  if (isPending) SizedBox(width: 6),

                  // Reject
                  if (isPending)
                    Expanded(
                      child: _compactOutlineButton(
                        context,
                        icon: Icons.close_rounded,
                        label: 'Reject',
                        color: context.appColors.error,
                        borderColor: context.appColors.error.withValues(
                          alpha: 0.4,
                        ),
                        onPressed: () {
                          _showRejectDialog(context, expense);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    BuildContext context, {
    required bool isPending,
    required bool isApproved,
    required bool isRejected,
  }) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;
    final String text;

    if (isApproved) {
      backgroundColor = context.appColors.primaryContainer;
      textColor = context.appColors.onPrimaryContainer;
      icon = Icons.check_circle;
      text = 'Approved';
    } else if (isRejected) {
      backgroundColor = context.appColors.errorContainer;
      textColor = context.appColors.onErrorContainer;
      icon = Icons.cancel;
      text = 'Rejected';
    } else {
      backgroundColor = context.appColors.tertiaryContainer;
      textColor = context.appColors.onTertiaryContainer;
      icon = Icons.schedule;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          SizedBox(width: 4),
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

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final String displayValue = value.trim().isEmpty ? '-' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: context.primaryColor),

          SizedBox(width: 7),

          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.secondaryTextColor,
            ),
          ),

          SizedBox(width: 7),

          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMOUNT ITEM
  // ============================================================

  Widget _amountItem(BuildContext context, String title, double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9,
                color: context.secondaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS ITEM
  // ============================================================

  Widget _statusItem(BuildContext context, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9,
                color: context.secondaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.trim().isEmpty ? '-' : value.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADMIN STATUS
  // ============================================================

  Widget _adminStatus(
    BuildContext context, {
    required bool isApproved,
    required bool isRejected,
    required String status,
  }) {
    final Color color;
    final Color background;
    final IconData icon;

    if (isApproved) {
      color = context.appColors.onPrimaryContainer;
      background = context.appColors.primaryContainer;
      icon = Icons.check_circle_outline_rounded;
    } else if (isRejected) {
      color = context.appColors.onErrorContainer;
      background = context.appColors.errorContainer;
      icon = Icons.cancel_outlined;
    } else {
      color = context.appColors.onTertiaryContainer;
      background = context.appColors.tertiaryContainer;
      icon = Icons.pending_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT FILLED BUTTON
  // ============================================================

  Widget _compactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: context.onPrimaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMPACT OUTLINE BUTTON
  // ============================================================

  Widget _compactOutlineButton(
    BuildContext context, {
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
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APPROVE CONFIRMATION
  // ============================================================

  void _showApproveDialog(BuildContext context, TeamExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: context.primaryColor,
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'Approve Expense',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Text(
            'Approve expense '
            'of ₹${expense.dailyTotal.toStringAsFixed(2)}?',
            style: TextStyle(fontSize: 13, color: context.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: context.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _updateExpense(context, expense, '1');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Approve',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REJECT CONFIRMATION
  // ============================================================

  Future<void> _showRejectDialog(
    BuildContext context,
    TeamExpenseEntity expense,
  ) async {
    var remark = '';
    final submittedRemark = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reject expense of ₹${expense.dailyTotal.toStringAsFixed(2)}?',
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) => remark = value,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Remark',
                  hintText: 'Enter a rejection remark',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, remark.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.error,
              foregroundColor: context.appColors.onError,
            ),
            child: Text('Reject'),
          ),
        ],
      ),
    );
    if (!context.mounted || submittedRemark == null) return;
    _updateExpense(context, expense, '2', remark: submittedRemark);
  }
  // ============================================================
  // UPDATE EXPENSE
  // ============================================================

  void _updateExpense(
    BuildContext context,
    TeamExpenseEntity expense,
    String status, {
    String? remark,
  }) {
    final updateRemark = remark ?? expense.remark;
    final String expenseJson = jsonEncode({
      'expenseId': expense.expenseId,
      'expenseBy': expense.expenseBy,
      'expenseDate': expense.expenseDate,
      'visitedPlace': expense.visitedPlace,
      'travellingMode': expense.travellingMode,
      'dailyTotal': expense.dailyTotal,
      'daExpenses': expense.daExpenses,
      'approveAmount': expense.approveAmount,
      'remark': updateRemark,
    });

    debugPrint('==========================================');
    debugPrint('UPDATE EXPENSE');
    debugPrint('User ID: $userId');
    debugPrint('Expense ID: ${expense.expenseId}');
    debugPrint('Status: $status');
    debugPrint('Expense JSON: $expenseJson');
    debugPrint('Remark: $updateRemark');
    debugPrint('==========================================');

    context.read<TeamExpenseBloc>().add(
      UpdateTeamExpenseEvent(
        userId: userId,
        expenseId: expense.expenseId,
        status: status,
        expenseJson: expenseJson,
        remark: updateRemark,
      ),
    );
  }

  // ============================================================
  // EXPENSE DETAILS BOTTOM SHEET
  // ============================================================

  void _showExpenseDetails(BuildContext context, TeamExpenseEntity expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              SizedBox(height: 9),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Bottom sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.appColors.primaryContainer,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: context.backgroundColor,
                        size: 21,
                      ),
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Expense Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close_rounded, size: 21),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              // Detail list
              Expanded(
                child: expense.details.isEmpty
                    ? Center(
                        child: Text(
                          'No expense details available',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: expense.details.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final detail = expense.details[index];

                          return _detailCard(context, detail);
                        },
                      ),
              ),

              // Total
              Container(
                padding: const EdgeInsets.fromLTRB(18, 11, 18, 18),
                decoration: BoxDecoration(
                  color: context.appTheme.inputBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Expense',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ),
                    Text(
                      '₹ ${expense.dailyTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: context.primaryColor,
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

  // ============================================================
  // DETAIL CARD
  // ============================================================

  Widget _detailCard(BuildContext context, TeamExpenseDetailEntity detail) {
    final String imageName = detail.expenseImage.trim();

    final bool hasImage = imageName.isNotEmpty;

    String imageUrl = '';

    if (hasImage) {
      if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
        imageUrl = imageName;
      } else {
        imageUrl = '${ApiClient.imageExpensetUrl}$imageName';
      }
    }

    debugPrint('Expense Name: ${detail.expenseName}');

    debugPrint('Expense Image: $imageName');

    debugPrint('Expense Image URL: $imageUrl');

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // Detail header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.appColors.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  hasImage ? Icons.image_outlined : Icons.receipt_outlined,
                  color:  context.backgroundColor,
                  size: 19,
                ),
              ),

              SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.expenseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: context.primaryTextColor,
                      ),
                    ),

                    if (detail.expenseRemark.trim().isNotEmpty) ...[
                      SizedBox(height: 3),
                      Text(
                        detail.expenseRemark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8),

              Text(
                '₹ ${detail.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),

          // Image
          if (hasImage) ...[
            SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                _showFullImage(context, imageUrl, detail.expenseName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 170,
                  color: context.appTheme.inputBackground,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: context.primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('IMAGE LOAD ERROR: $error');

                      debugPrint('FAILED IMAGE URL: $imageUrl');

                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 38,
                              color: context.secondaryTextColor,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.secondaryTextColor,
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

            SizedBox(height: 5),

            Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 12,
                  color: context.primaryColor,
                ),

                SizedBox(width: 4),

                Expanded(
                  child: Text(
                    imageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),

                SizedBox(width: 5),

                Text(
                  'Tap to view',
                  style: TextStyle(
                    fontSize: 8,
                    color: context.primaryColor,
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

  // ============================================================
  // FULL IMAGE
  // ============================================================

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      barrierColor: context.appColors.scrim.withValues(alpha: 0.87),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
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
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: context.cardTextColor,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Close
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.cardTextColor,
                    ),
                  ),
                ),
              ),

              // Title
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
                    color: context.cardBackgroundColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.cardTextColor,
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
