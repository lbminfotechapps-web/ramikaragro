
import 'package:solufine/core/di/my_expense_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/my_expense_bloc.dart';
import '../bloc/my_expense_event.dart';
import '../bloc/my_expense_state.dart';
import '../widgets/my_expense_card.dart';

class MyExpensePage extends StatefulWidget {
  const MyExpensePage({
    super.key,
  });

  @override
  State<MyExpensePage> createState() => _MyExpensePageState();
}

class _MyExpensePageState extends State<MyExpensePage> {
  // ---------------------------------------------------------------------------
  // VARIABLES
  // ---------------------------------------------------------------------------

  String fromDate = '';
  String toDate = '';

  MyExpenseBloc? _myExpenseBloc;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    // First day of current month
    fromDate = _formatDate(
      DateTime(
        now.year,
        now.month,
        1,
      ),
    );

    // Today's date
    toDate = _formatDate(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _myExpenseBloc = null;
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyExpenseBloc>(
      create: (_) {
        final bloc = sl<MyExpenseBloc>();

        // Keep reference to the exact Bloc created by BlocProvider.
        _myExpenseBloc = bloc;

        return bloc;
      },
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F8F6),

            appBar: _buildAppBar(),

            body: Column(
              children: [
                // -------------------------------------------------------------
                // DATE FILTER
                // -------------------------------------------------------------

                _buildFilterSection(),

                // -------------------------------------------------------------
                // EXPENSE CONTENT
                // -------------------------------------------------------------

                Expanded(
                  child: BlocBuilder<MyExpenseBloc, MyExpenseState>(
                    builder: (context, state) {
                      // -------------------------------------------------------
                      // LOADING
                      // -------------------------------------------------------

                      if (state is MyExpenseInitial ||
                          state is MyExpenseLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2D6A4F),
                          ),
                        );
                      }

                      // -------------------------------------------------------
                      // ERROR
                      // -------------------------------------------------------

                      if (state is MyExpenseError) {
                        return _buildError(
                          context,
                          state.message,
                        );
                      }

                      // -------------------------------------------------------
                      // EMPTY
                      // -------------------------------------------------------

                      if (state is MyExpenseEmpty) {
                        return _buildEmpty(context);
                      }

                      // -------------------------------------------------------
                      // LOADED
                      // -------------------------------------------------------

                      if (state is MyExpenseLoaded) {
                        return _buildExpenseList(
                          context,
                          state.expenses,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'My Expense List',
      showBackButton: true,
      onBackTap: () => context.go(AppRouter.home),
      actionIcon: Icons.refresh_rounded,
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FILTER SECTION
  // ---------------------------------------------------------------------------

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------
          // FROM DATE
          // ---------------------------------------------------------------

          Expanded(
            child: _dateFilter(
              title: 'From Date',
              value: fromDate,
              icon: Icons.calendar_today_outlined,
              onTap: _selectFromDate,
            ),
          ),

          const SizedBox(width: 10),

          // ---------------------------------------------------------------
          // TO DATE
          // ---------------------------------------------------------------

          Expanded(
            child: _dateFilter(
              title: 'To Date',
              value: toDate,
              icon: Icons.event_outlined,
              onTap: _selectToDate,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FILTER ITEM
  // ---------------------------------------------------------------------------

  Widget _dateFilter({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2EAE4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF2D6A4F),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A938D),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF263229),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF7A857E),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECT FROM DATE
  // ---------------------------------------------------------------------------

  Future<void> _selectFromDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(fromDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    final selectedToDate = _parseDate(toDate);

    // From date cannot be greater than To date.
    if (selectedToDate != null &&
        selectedDate.isAfter(selectedToDate)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'From Date cannot be after To Date',
          ),
        ),
      );

      return;
    }

    setState(() {
      fromDate = _formatDate(selectedDate);
    });

    // Reload API with new date.
    _loadExpenses();
  }

  // ---------------------------------------------------------------------------
  // SELECT TO DATE
  // ---------------------------------------------------------------------------

  Future<void> _selectToDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    final selectedFromDate = _parseDate(fromDate);

    // To date cannot be less than From date.
    if (selectedFromDate != null &&
        selectedDate.isBefore(selectedFromDate)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'To Date cannot be before From Date',
          ),
        ),
      );

      return;
    }

    setState(() {
      toDate = _formatDate(selectedDate);
    });

    // Reload API with new date.
    _loadExpenses();
  }

  // ---------------------------------------------------------------------------
  // PARSE DATE
  // ---------------------------------------------------------------------------

  DateTime? _parseDate(String value) {
    try {
      if (value.isEmpty) {
        return null;
      }

      final parts = value.split('-');

      if (parts.length != 3) {
        return null;
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(
        year,
        month,
        day,
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // FORMAT DATE
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ---------------------------------------------------------------------------
  // LOAD EXPENSES
  // ---------------------------------------------------------------------------

  Future<void> _loadExpenses() async {
    final userData =
        await SecureStorage.instance.getUserData();

    print(
      'My Expense User Data: $userData',
    );

    final userId = int.tryParse(
      userData?['user_id']?.toString() ?? '',
    );

    print(
      'My Expense User ID: $userId',
    );

    print(
      'My Expense From Date: $fromDate',
    );

    print(
      'My Expense To Date: $toDate',
    );

    // ---------------------------------------------------------------
    // USER ID CHECK
    // ---------------------------------------------------------------

    if (userId == null) {
      print(
        'My Expense: User ID is null',
      );

      return;
    }

    // ---------------------------------------------------------------
    // BLOC CHECK
    // ---------------------------------------------------------------

    if (_myExpenseBloc == null) {
      print(
        'My Expense: MyExpenseBloc is not initialized',
      );

      return;
    }

    // ---------------------------------------------------------------
    // API EVENT
    // ---------------------------------------------------------------

    _myExpenseBloc!.add(
      GetMyExpensesEvent(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: 0,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXPENSE LIST
  // ---------------------------------------------------------------------------

  Widget _buildExpenseList(
    BuildContext context,
    List expenses,
  ) {
    final total = expenses.fold<double>(
      0,
      (sum, expense) {
        return sum +
            (double.tryParse(
                  expense.dailyTotal.toString(),
                ) ??
                0);
      },
    );

    return RefreshIndicator(
      color: const Color(0xFF2D6A4F),

      onRefresh: () => _loadExpenses(),

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          30,
        ),

        children: [
          // ---------------------------------------------------------------
          // SUMMARY
          // ---------------------------------------------------------------

          _buildSummaryCard(
            total: total,
            count: expenses.length,
          ),

          const SizedBox(height: 22),

          // ---------------------------------------------------------------
          // HISTORY HEADER
          // ---------------------------------------------------------------

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Expense History',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18231C),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${expenses.length} Records',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------------------
          // EXPENSE CARDS
          // ---------------------------------------------------------------

          ...List.generate(
            expenses.length,
            (index) {
              return MyExpenseCard(
                expense: expenses[index],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY CARD
  // ---------------------------------------------------------------------------

  Widget _buildSummaryCard({
    required double total,
    required int count,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B4332),
            Color(0xFF2D6A4F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332)
                .withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // -------------------------------------------------------------
          // TITLE ROW
          // -------------------------------------------------------------

          Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Color(0xFFD7E9DE),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '$count Entries',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------
          // TOTAL
          // -------------------------------------------------------------

          Text(
            '₹ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Recorded expense amount',
            style: TextStyle(
              color: Color(0xFFB7D8C4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildError(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE5ECE7),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ---------------------------------------------------------
              // ERROR ICON
              // ---------------------------------------------------------

              Container(
                width: 68,
                height: 68,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 32,
                  color: Color(0xFFC62828),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------
              // ERROR TITLE
              // ---------------------------------------------------------

              const Text(
                'No Record Found',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF26332B),
                ),
              ),

              const SizedBox(height: 8),

              // // ---------------------------------------------------------
              // // ERROR MESSAGE
              // // ---------------------------------------------------------

              // Text(
              //   message,
              //   textAlign: TextAlign.center,

              //   style: const TextStyle(
              //     fontSize: 12,
              //     color: Color(0xFF7A857E),
              //   ),
              // ),

              // const SizedBox(height: 20),

              // ---------------------------------------------------------
              // TRY AGAIN
              // ---------------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 46,

                child: ElevatedButton.icon(
                  onPressed: () => _loadExpenses(),

                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),

                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2D6A4F),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY
  // ---------------------------------------------------------------------------

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF2D6A4F),

      onRefresh: () => _loadExpenses(),

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          const SizedBox(height: 130),

          // ---------------------------------------------------------------
          // ICON
          // ---------------------------------------------------------------

          Center(
            child: Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F5ED),
                borderRadius: BorderRadius.circular(28),
              ),

              child: const Icon(
                Icons.receipt_long_rounded,
                size: 42,
                color: Color(0xFF2D6A4F),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // TITLE
          // ---------------------------------------------------------------

          const Center(
            child: Text(
              'No Expenses Found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF26332B),
              ),
            ),
          ),

          const SizedBox(height: 7),

          // ---------------------------------------------------------------
          // DESCRIPTION
          // ---------------------------------------------------------------

          const Center(
            child: Text(
              'Your expense records will appear here.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A857E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


