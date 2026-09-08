import 'package:demo/core/di/leave_list_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';

class AddLeavePage extends StatefulWidget {
  const AddLeavePage({super.key});

  @override
  State<AddLeavePage> createState() => _AddLeavePageState();
}

class _AddLeavePageState extends State<AddLeavePage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF168A45);
  static const Color darkGreen = Color(0xFF0C6632);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color backgroundColor = Color(0xFFF7F9F8);

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController reasonController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  DateTime? fromDate;
  DateTime? toDate;

  String startLeaveType = "Full Day";
  String endLeaveType = "Full Day";

  late LeaveBloc leaveBloc;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    leaveBloc = sl<LeaveBloc>();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    reasonController.dispose();
    leaveBloc.close();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER - FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final selected = await showDatePicker(
      context: context,
      initialDate: fromDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      fromDate = selected;

      // If current To Date is before new From Date,
      // clear To Date.
      if (toDate != null &&
          toDate!.isBefore(selected)) {
        toDate = null;
      }

      // Reset leave types when changing From Date.
      startLeaveType = "Full Day";
      endLeaveType = "Full Day";

      // If From and To are same date,
      // synchronize End Day.
      if (toDate != null &&
          _isSameDate(fromDate!, toDate!)) {
        endLeaveType = startLeaveType;
      }
    });
  }

  // ============================================================
  // DATE PICKER - TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    if (fromDate == null) {
      _showError("Please select From Date first");
      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      toDate = selected;

      // ========================================================
      // SAME DATE
      // ========================================================

      if (_isSameDate(fromDate!, selected)) {
        // Automatically copy Start Day to End Day.
        //
        // Full Day   -> Full Day
        // First Half -> First Half
        // Second Half -> Second Half
        //
        endLeaveType = startLeaveType;
      }

      // ========================================================
      // MULTIPLE DATE
      // ========================================================

      else {
        // For multiple dates, End Day can be selected separately.
        endLeaveType = "Full Day";
      }
    });
  }

  // ============================================================
  // SAME DATE CHECK
  // ============================================================

  bool _isSameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // ============================================================
  // DATE DIFFERENCE
  // ============================================================

  int get dateDifference {
    if (fromDate == null || toDate == null) {
      return 0;
    }

    final DateTime from = DateTime(
      fromDate!.year,
      fromDate!.month,
      fromDate!.day,
    );

    final DateTime to = DateTime(
      toDate!.year,
      toDate!.month,
      toDate!.day,
    );

    return to.difference(from).inDays + 1;
  }

  // ============================================================
  // TOTAL LEAVE DAYS
  // ============================================================

  double get totalLeaveDays {
    if (fromDate == null || toDate == null) {
      return 0;
    }

    final int days = dateDifference;

    // ==========================================================
    // SAME DATE
    // ==========================================================

    if (days == 1) {
      switch (startLeaveType) {
        case "First Half":
          return 0.5;

        case "Second Half":
          return 0.5;

        case "Full Day":
        default:
          return 1.0;
      }
    }

    // ==========================================================
    // MULTIPLE DATES
    // ==========================================================

    double total = days.toDouble();

    final bool startIsHalf =
        startLeaveType == "First Half" ||
        startLeaveType == "Second Half";

    final bool endIsHalf =
        endLeaveType == "First Half" ||
        endLeaveType == "Second Half";

    if (startIsHalf) {
      total -= 0.5;
    }

    if (endIsHalf) {
      total -= 0.5;
    }

    return total;
  }

  // ============================================================
  // FORMAT LEAVE DAYS
  // ============================================================

  String _formatLeaveDays(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // START LEAVE TYPE
  // ============================================================

  void _onStartLeaveTypeChanged(String? value) {
    if (value == null) return;

    setState(() {
      startLeaveType = value;

      // ========================================================
      // SAME DATE
      // ========================================================
      //
      // Automatically synchronize End Day.
      //
      // First Half  -> First Half
      // Second Half -> Second Half
      // Full Day    -> Full Day
      //

      if (fromDate != null &&
          toDate != null &&
          _isSameDate(fromDate!, toDate!)) {
        endLeaveType = value;
      }
    });
  }

  // ============================================================
  // END LEAVE TYPE
  // ============================================================

  void _onEndLeaveTypeChanged(String? value) {
    if (value == null) return;

    setState(() {
      endLeaveType = value;
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    // ----------------------------------------------------------
    // FROM DATE
    // ----------------------------------------------------------

    if (fromDate == null) {
      _showError("Please select From Date");
      return;
    }

    // ----------------------------------------------------------
    // TO DATE
    // ----------------------------------------------------------

    if (toDate == null) {
      _showError("Please select To Date");
      return;
    }

    // ----------------------------------------------------------
    // DATE VALIDATION
    // ----------------------------------------------------------

    if (toDate!.isBefore(fromDate!)) {
      _showError(
        "To Date cannot be before From Date",
      );
      return;
    }

    // ----------------------------------------------------------
    // SAME DATE SYNCHRONIZATION
    // ----------------------------------------------------------

    if (_isSameDate(fromDate!, toDate!)) {
      endLeaveType = startLeaveType;
    }

    // ----------------------------------------------------------
    // REASON
    // ----------------------------------------------------------

    if (reasonController.text.trim().isEmpty) {
      _showError("Please enter reason");
      return;
    }

    // ----------------------------------------------------------
    // TOTAL DAYS
    // ----------------------------------------------------------

    if (totalLeaveDays <= 0) {
      _showError("Invalid leave days");
      return;
    }

    // ----------------------------------------------------------
    // FORMAT DATE
    // ----------------------------------------------------------

    final String formattedFromDate =DateFormat("yyyy-MM-dd").format(fromDate!);

    final String formattedToDate =DateFormat("yyyy-MM-dd").format(toDate!);

    // ----------------------------------------------------------
    // DEBUG
    // ----------------------------------------------------------

    print("========== APPLY LEAVE ==========");
    print("From Date       = $formattedFromDate");
    print("To Date         = $formattedToDate");
    print("Start Leave     = $startLeaveType");
    print("End Leave       = $endLeaveType");
    print("Total Leave     = $totalLeaveDays");
    print("Reason          = ${reasonController.text.trim()}");
    print("================================");

    // ----------------------------------------------------------
    // BLOC EVENT
    // ----------------------------------------------------------

    leaveBloc.add(
      AddLeaveEvent(
        fromDate: formattedFromDate,
        endDate: formattedToDate,
        startLeaveType: startLeaveType,
        endLeaveType: endLeaveType,
        totalLeaveDays: totalLeaveDays.toString(),
        reason: reasonController.text.trim(),
      ),
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: leaveBloc,
      child: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          // ======================================================
          // SUCCESS
          // ======================================================

          if (state.addLeaveStatus ==
              AddLeaveStatus.success) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.successMessage ??
                            "Leave applied successfully",
                      ),
                    ),
                  ],
                ),
                backgroundColor: primaryGreen,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            Future.delayed(
              const Duration(milliseconds: 500),
              () {
                if (context.mounted) {
                  context.pop(true);
                }
              },
            );
          }

          // ======================================================
          // FAILURE
          // ======================================================

          if (state.addLeaveStatus ==
              AddLeaveStatus.failure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage ??
                            "Unable to apply leave",
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading =
              state.addLeaveStatus ==
                  AddLeaveStatus.loading;

          final bool sameDate =
              fromDate != null &&
              toDate != null &&
              _isSameDate(
                fromDate!,
                toDate!,
              );

          return Scaffold(
            backgroundColor: backgroundColor,

            // ==================================================
            // APP BAR
            // ==================================================

            appBar: AppBar(
              elevation: 0,
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              centerTitle: false,
              titleSpacing: 0,


              leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: AppColors.backgroundColor,
              ),
              onPressed: () {
                context.go(AppRouter.home);
              },
              ),

              title: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Apply Leave",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Submit your leave request",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // BODY
            // ==================================================

            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        12,
                        14,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ====================================
                          // DATES
                          // ====================================

                          _sectionTitle(
                            Icons.date_range_rounded,
                            "Leave Dates",
                          ),

                          const SizedBox(height: 7),

                          _buildDateSection(),

                          const SizedBox(height: 13),

                          // ====================================
                          // LEAVE TYPE
                          // ====================================

                          _sectionTitle(
                            Icons.timelapse_rounded,
                            "Leave Type",
                          ),

                          const SizedBox(height: 7),

                          _buildLeaveTypeSection(),

                          const SizedBox(height: 13),

                          // ====================================
                          // TOTAL DAYS
                          // ====================================

                          _buildTotalDaysCard(),

                          const SizedBox(height: 13),

                          // ====================================
                          // REASON
                          // ====================================

                          _sectionTitle(
                            Icons.notes_rounded,
                            "Reason",
                          ),

                          const SizedBox(height: 7),

                          _buildReasonField(),

                          // Small bottom space
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM BUTTONS
                  // ==================================================

                  _buildBottomButtons(
                    isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: primaryGreen,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222622),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE SECTION
  // ============================================================

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          child: _dateCard(
            title: "FROM",
            date: fromDate,
            icon: Icons.login_rounded,
            onTap: _selectFromDate,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _dateCard(
            title: "TO",
            date: toDate,
            icon: Icons.logout_rounded,
            onTap: _selectToDate,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE CARD
  // ============================================================

  Widget _dateCard({
    required String title,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool selected = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primaryGreen.withOpacity(0.35)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: selected
                    ? lightGreen
                    : Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: selected
                    ? primaryGreen
                    : Colors.grey.shade500,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    date == null
                        ? "Select date"
                        : DateFormat(
                            "dd MMM yyyy",
                          ).format(date),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: date == null
                          ? Colors.grey.shade400
                          : const Color(
                              0xFF202522,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEAVE TYPE SECTION
  // ============================================================

  Widget _buildLeaveTypeSection() {
    final bool sameDate =
        fromDate != null &&
        toDate != null &&
        _isSameDate(
          fromDate!,
          toDate!,
        );

    return Row(
      children: [
        Expanded(
          child: _leaveTypeDropdown(
            label: "START DAY",
            value: startLeaveType,
            enabled: true,
            onChanged:
                _onStartLeaveTypeChanged,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _leaveTypeDropdown(
            label: "END DAY",
            value: endLeaveType,
            // Disable End Day for same date.
            enabled: !sameDate,
            onChanged:
                _onEndLeaveTypeChanged,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LEAVE TYPE DROPDOWN
  // ============================================================

  Widget _leaveTypeDropdown({
    required String label,
    required String value,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 62,
      padding: const EdgeInsets.fromLTRB(
        11,
        6,
        6,
        2,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.grey.shade500,
            ),
          ),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: enabled
                      ? primaryGreen
                      : Colors.grey.shade400,
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFF202522)
                      : Colors.grey.shade400,
                ),
                onChanged:
                    enabled ? onChanged : null,
                items: const [
                  DropdownMenuItem(
                    value: "Full Day",
                    child: Text("Full Day"),
                  ),
                  DropdownMenuItem(
                    value: "First Half",
                    child: Text("First Half"),
                  ),
                  DropdownMenuItem(
                    value: "Second Half",
                    child: Text("Second Half"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL DAYS CARD
  // ============================================================

  Widget _buildTotalDaysCard() {
    final bool hasDates =
        fromDate != null &&
        toDate != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryGreen.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL LEAVE DAYS",
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: primaryGreen,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Calculated automatically",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Text(
            hasDates
                ? _formatLeaveDays(
                    totalLeaveDays,
                  )
                : "0",
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REASON FIELD
  // ============================================================

  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: reasonController,
        maxLines: 3,
        textCapitalization:
            TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText:
              "Enter reason for leave...",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 4,
              top: 10,
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: primaryGreen,
              size: 20,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(
            minWidth: 40,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.fromLTRB(
            4,
            10,
            10,
            10,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons(
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ==================================================
            // CANCEL
            // ==================================================

            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => context.pop(),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.grey.shade700,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 9),

            // ==================================================
            // SUBMIT
            // ==================================================

            Expanded(
              flex: 2,
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : _submit,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Submit Leave",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
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
    );
  }
}