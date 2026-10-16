import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../bloc/team_expense_bloc.dart';
import '../bloc/team_expense_event.dart';
import '../bloc/team_expense_state.dart';
import '../widgets/team_expense_card.dart';

class TeamExpensePage extends StatelessWidget {
  const TeamExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamExpenseBloc>(
      create: (_) => sl<TeamExpenseBloc>(),
      child: const _TeamExpenseView(),
    );
  }
}

class _TeamExpenseView extends StatefulWidget {
  const _TeamExpenseView();

  @override
  State<_TeamExpenseView> createState() => _TeamExpenseViewState();
}

class _TeamExpenseViewState extends State<_TeamExpenseView> {
  int? userId;

  final TextEditingController searchController = TextEditingController();

  // String fromDate = '10-09-2026';
  // String toDate = '10-09-2026';

  String fromDate = '';
  String toDate = '';

  int startLimit = 0;

  static const int pageSize = 20;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    fromDate = _formatDate(today);
    toDate = _formatDate(today);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndExpenses();
    });
  }

  Future<void> _loadUserAndExpenses() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      final id = int.tryParse(userData?['user_id']?.toString() ?? '');

      if (id == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ID not found', style: AppTextStyles.body),
          ),
        );

        return;
      }

      userId = id;

      _loadExpenses();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load user data: $e',
            style: AppTextStyles.body,
          ),
        ),
      );
    }
  }

  void _loadExpenses() {
    if (userId == null) {
      return;
    }

    startLimit = 0;

    context.read<TeamExpenseBloc>().add(
      GetTeamExpensesEvent(
        userId: userId!,
        fromDate: fromDate,
        toDate: toDate,
        searchText: searchController.text.trim(),
        startLimit: 0,
        isLoadMore: false,
      ),
    );
  }

  void _search() {
    _loadExpenses();
  }

  void _loadMore() {
    if (userId == null) {
      return;
    }

    final currentState = context.read<TeamExpenseBloc>().state;

    if (currentState is! TeamExpenseLoaded) {
      return;
    }

    if (currentState.isLoadingMore || currentState.hasReachedEnd) {
      return;
    }

    startLimit += pageSize;

    context.read<TeamExpenseBloc>().add(
      GetTeamExpensesEvent(
        userId: userId!,
        fromDate: fromDate,
        toDate: toDate,
        searchText: searchController.text.trim(),
        startLimit: startLimit,
        isLoadMore: true,
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(fromDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      fromDate = _formatDate(selectedDate);
    });

    _loadExpenses();
  }

  Future<void> _selectToDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      toDate = _formatDate(selectedDate);
    });

    _loadExpenses();
  }

  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('-');

      if (parts.length != 3) {
        return null;
      }

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        title: 'Team Expense List',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        // Normal refresh icon
        actionIcon: Icons.refresh_rounded,
      ),

      body: BlocConsumer<TeamExpenseBloc, TeamExpenseState>(
        listener: (context, state) {
          if (state is TeamExpenseUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: AppTextStyles.body)),
            );
            _loadExpenses();
          } else if (state is TeamExpenseUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: AppTextStyles.body)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildFilterSection(),

              Expanded(child: _buildExpenseContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            style: AppTextStyles.input.copyWith(
              color: context.primaryTextColor,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _search();
            },
            decoration: InputDecoration(
              hintText: 'Search employee',
              hintStyle: AppTextStyles.inputHint.copyWith(
                color: context.secondaryTextColor,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.primaryColor,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                        _search();
                      },
                      icon: Icon(Icons.close_rounded, size: 20),
                    )
                  : IconButton(
                      onPressed: _search,
                      icon: Icon(
                        Icons.search_rounded,
                        color: context.primaryColor,
                      ),
                    ),
              filled: true,
              fillColor: context.appTheme.inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: context.primaryColor, width: 1.2),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _dateFilter(
                  title: 'From Date',
                  value: fromDate,
                  icon: Icons.calendar_today_outlined,
                  onTap: _selectFromDate,
                ),
              ),

              SizedBox(width: 10),

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
        ],
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.appTheme.inputBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            SizedBox(width: 2),
            Icon(icon, size: 18, color: context.primaryColor),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    value,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.primaryTextColor,
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

  Widget _buildExpenseContent(TeamExpenseState state) {
    if (state is TeamExpenseUpdateLoading) {
      return Stack(
        children: [
          AbsorbPointer(
            child: _buildExpenseContent(
              TeamExpenseLoaded(expenses: state.expenses),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(color: context.primaryColor),
          ),
        ],
      );
    }
    if (state is TeamExpenseUpdateSuccess) {
      return _buildExpenseContent(TeamExpenseLoaded(expenses: state.expenses));
    }
    if (state is TeamExpenseUpdateError) {
      return _buildExpenseContent(TeamExpenseLoaded(expenses: state.expenses));
    }
    if (state is TeamExpenseLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (state is TeamExpenseError) {
      return _buildError(state.message);
    }

    if (state is TeamExpenseEmpty) {
      return _buildEmpty();
    }

    if (state is TeamExpenseLoaded) {
      if (state.expenses.isEmpty) {
        return _buildEmpty();
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.vertical) {
            return false;
          }

          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 250) {
            if (!state.isLoadingMore && !state.hasReachedEnd) {
              _loadMore();
            }
          }

          return false;
        },
        child: RefreshIndicator(
          color: context.primaryColor,
          onRefresh: () async {
            _loadExpenses();

            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: state.expenses.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.expenses.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.primaryColor,
                    ),
                  ),
                );
              }

              final expense = state.expenses[index];

              return TeamExpenseCard(expense: expense, userId: userId!);
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        _loadExpenses();

        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.20),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: context.appColors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: context.backgroundColor,
              ),
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: Text(
              'No Expense Found',
              style: AppTextStyles.headingMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Text(
              'No team expense records are available\n'
              'for the selected date or search.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        _loadExpenses();

        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: context.appColors.errorContainer,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: context.appColors.onErrorContainer,
              ),
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: Text(
              'Something went wrong',
              style: AppTextStyles.headingMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadExpenses,
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
