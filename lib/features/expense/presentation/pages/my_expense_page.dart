import 'package:demo/core/di/my_expense_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyExpenseBloc>(
      create: (_) => sl<MyExpenseBloc>(),
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadExpenses(context);
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F8F6),
            
            appBar: _buildAppBar(),
            body: BlocBuilder<MyExpenseBloc, MyExpenseState>(
              builder: (context, state) {
                if (state is MyExpenseInitial ||
                    state is MyExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2D6A4F),
                    ),
                  );
                }

                if (state is MyExpenseError) {
                  return _buildError(
                    context,
                    state.message,
                  );
                }

                if (state is MyExpenseEmpty) {
                  return _buildEmpty(context);
                }

                if (state is MyExpenseLoaded) {
                  return _buildExpenseList(
                    context,
                    state.expenses,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return 
  
       CustomAppBar(
          title: 'My Expense List',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
          // Normal refresh icon
          actionIcon: Icons.refresh_rounded,
         
         
        );
  }

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
      onRefresh: () => _loadExpenses(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          30,
        ),
        children: [
          _buildSummaryCard(
            total: total,
            count: expenses.length,
          ),

          const SizedBox(height: 22),

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
            color: const Color(0xFF1B4332).withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

              const Text(
                'Unable to load expenses',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF26332B),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7A857E),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _loadExpenses(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF2D6A4F),
      onRefresh: () => _loadExpenses(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 130),

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

  Future<void> _loadExpenses(BuildContext context) async {
    final userData =
        await SecureStorage.instance.getUserData();

    print('My Expense User Data: $userData');

    final userId = int.tryParse(
      userData?['user_id']?.toString() ?? '',
    );

    print('My Expense User ID: $userId');

    if (userId == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    context.read<MyExpenseBloc>().add(
          GetMyExpensesEvent(
            userId: userId,
            fromDate: '01-09-2026',
            toDate: '10-09-2026',
            startLimit: 0,
          ),
        );
  }
}