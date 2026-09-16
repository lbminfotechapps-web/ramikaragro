import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
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

  final TextEditingController searchController =
      TextEditingController();

  String fromDate = '10-09-2026';
  String toDate = '10-09-2026';

  int startLimit = 0;

  static const int pageSize = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndExpenses();
    });
  }

  Future<void> _loadUserAndExpenses() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      final id = int.tryParse(
        userData?['user_id']?.toString() ?? '',
      );

      if (id == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found'),
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

    final currentState =
        context.read<TeamExpenseBloc>().state;

    if (currentState is! TeamExpenseLoaded) {
      return;
    }

    if (currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
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
    final DateTime? selectedDate =
        await showDatePicker(
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
    final DateTime? selectedDate =
        await showDatePicker(
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
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

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
      backgroundColor: const Color(0xFFF6F9F7),
     
       appBar:CustomAppBar(
          title: 'Team Expense List',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
          // Normal refresh icon
          actionIcon: Icons.refresh_rounded,
         
         
        ),

      body: BlocBuilder<TeamExpenseBloc, TeamExpenseState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildFilterSection(),

              Expanded(
                child: _buildExpenseContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
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
      child: Column(
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _search();
            },
            decoration: InputDecoration(
              hintText: 'Search employee',
              hintStyle: const TextStyle(
                color: Color(0xFF98A29C),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF2D6A4F),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                        _search();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                      ),
                    )
                  : IconButton(
                      onPressed: _search,
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2D6A4F),
                      ),
                    ),
              filled: true,
              fillColor: const Color(0xFFF5F8F6),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF2D6A4F),
                  width: 1.2,
                ),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(height: 12),

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

              const SizedBox(width: 10),

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
            const SizedBox(width: 2),
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF2D6A4F),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseContent(
    TeamExpenseState state,
  ) {
    if (state is TeamExpenseLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D6A4F),
        ),
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
          if (notification.metrics.axis !=
              Axis.vertical) {
            return false;
          }

          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 250) {
            if (!state.isLoadingMore &&
                !state.hasReachedEnd) {
              _loadMore();
            }
          }

          return false;
        },
        child: RefreshIndicator(
          color: const Color(0xFF2D6A4F),
          onRefresh: () async {
            _loadExpenses();

            await Future.delayed(
              const Duration(milliseconds: 500),
            );
          },
          child: ListView.builder(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              30,
            ),
            itemCount: state.expenses.length +
                (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >=
                  state.expenses.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                );
              }

              final expense =
                  state.expenses[index];

             
              return TeamExpenseCard(
                expense: expense,
                userId: userId!,
              );

            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: const Color(0xFF2D6A4F),
      onRefresh: () async {
        _loadExpenses();

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.20,
          ),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5ED),
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: Color(0xFF2D6A4F),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'No Expense Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF263229),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'No team expense records are available\n'
              'for the selected date or search.',
              textAlign: TextAlign.center,
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

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: const Color(0xFF2D6A4F),
      onRefresh: () async {
        _loadExpenses();

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.18,
          ),
          Center(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius:
                    BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF263229),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A857E),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadExpenses,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}