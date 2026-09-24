import 'dart:async';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/features/salesreturnhistory/presentation/widget/sales_return_history_card.dart';
import 'package:solufine/features/salesreturnhistory/presentation/widget/sales_return_history_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../bloc/sales_return_history_bloc.dart';
import '../bloc/sales_return_history_event.dart';
import '../bloc/sales_return_history_state.dart';
import '../../domain/entities/sales_return_history_entity.dart';

class SalesReturnHistoryPage extends StatefulWidget {
  const SalesReturnHistoryPage({super.key});

  @override
  State<SalesReturnHistoryPage> createState() => _SalesReturnHistoryPageState();
}

class _SalesReturnHistoryPageState extends State<SalesReturnHistoryPage> {
  final TextEditingController dealerController = TextEditingController();

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String userId = '';

  String selectedDealerId = '';

  String selectedStatus = 'Select Status';

  bool showFilter = false;

  int startLimit = 0;

  static const int pageSize = 20;

  Timer? dealerSearchTimer;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = await SecureStorage.instance.getUserData();

    userId = userData!['user_id']?.toString() ?? '';

    if (!mounted) return;

    _loadHistory();
  }

  void _loadHistory() {
    context.read<SalesReturnHistoryBloc>().add(
      LoadSalesReturnHistoryEvent(
        userId: userId,
        outletId: selectedDealerId,
        fromDate: fromDateController.text.trim(),
        toDate: toDateController.text.trim(),
        startLimit: startLimit,
        status: _statusValue(),
      ),
    );
  }

  String _statusValue() {
    switch (selectedStatus) {
      case 'Pending':
        return '0';

      case 'Approved':
        return '1';

      case 'Cancelled':
        return '3';

      default:
        return '';
    }
  }

  void _search() {
    startLimit = 0;
    _loadHistory();
  }

  void _reset() {
    dealerController.clear();
    fromDateController.clear();
    toDateController.clear();

    selectedDealerId = '';
    selectedStatus = 'Select Status';

    startLimit = 0;

    setState(() {});

    _loadHistory();
  }

  void _searchDealer(String text) {
    dealerSearchTimer?.cancel();

    dealerSearchTimer = Timer(const Duration(milliseconds: 800), () {
      if (text.trim().length < 3) {
        context.read<SalesReturnHistoryBloc>().add(ClearDealerSearchEvent());
        return;
      }

      context.read<SalesReturnHistoryBloc>().add(
        SearchSalesReturnDealerEvent(userId: userId, searchText: text.trim()),
      );
    });
  }

  Future<void> _selectFromDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    fromDateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    setState(() {});
  }

  Future<void> _selectToDate() async {
    if (fromDateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please Enter From Date.!')));

      return;
    }

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    toDateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    setState(() {});
  }

  void _loadNextPage(SalesReturnHistoryState state) {
    if (state.isPaginationLoading || state.hasReachedEnd) {
      return;
    }

    startLimit += pageSize;

    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7F9),

      appBar: CustomAppBar(
        title: 'Sales Return History',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        // Normal refresh icon
        actionIcon: Icons.refresh_rounded,
      ),
      body: BlocConsumer<SalesReturnHistoryBloc, SalesReturnHistoryState>(
        listener: (context, state) {
          if (state.status == SalesReturnHistoryStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              startLimit = 0;

              _loadHistory();

              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  _loadNextPage(state);
                }

                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildFilter()),

                  if (state.status == SalesReturnHistoryStatus.loading &&
                      state.salesReturns.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.salesReturns.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No Record Found',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.salesReturns.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final item = state.salesReturns[index];

                          return SalesReturnHistoryCard(
                            item: item,
                            index: index,
                            onViewDetails: () {
                              _openDetails(item);
                            },
                          );
                        },
                        childCount:
                            state.salesReturns.length +
                            (state.isPaginationLoading ? 1 : 0),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.darkPrimaryColor,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Search & Filter',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      showFilter
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 15.h),
                child:
                    BlocBuilder<
                      SalesReturnHistoryBloc,
                      SalesReturnHistoryState
                    >(
                      builder: (context, state) {
                        return SalesReturnHistoryFilter(
                          dealerController: dealerController,
                          fromDateController: fromDateController,
                          toDateController: toDateController,
                          selectedStatus: selectedStatus,
                          onStatusChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                          onFromDate: _selectFromDate,
                          onToDate: _selectToDate,
                          onSearch: _search,
                          onReset: _reset,
                          onDealerChanged: _searchDealer,
                          dealerSuggestions: state.dealers
                              .map((e) => e.fldOutletName)
                              .toList(),
                          onDealerSelected: _onDealerSelected,
                        );
                      },
                    ),
              ),
              crossFadeState: showFilter
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  void _onDealerSelected(String dealerName) {
    final bloc = context.read<SalesReturnHistoryBloc>();

    final dealer = bloc.state.dealers
        .where((e) => e.fldOutletName == dealerName)
        .firstOrNull;

    if (dealer == null) return;

    selectedDealerId = dealer.fldOutletId;

    dealerController.text = dealer.fldOutletName;

    startLimit = 0;

    _loadHistory();
  }

  void _openDetails(SalesReturnHistoryEntity item) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sales Return Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Sales Return No', item.fldSalesReturnNo),
                  _detailRow('Dispatch Date', item.fldSalesReturnDate),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 4),
                  if (item.salesReturnDetails.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No product details found')),
                    )
                  else
                    ...item.salesReturnDetails.map(
                      (detail) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow('Product Name', detail.fldProductName),

                              _detailRow('No Of Case : ', detail.fldQtyInPkt),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(' : '),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dealerSearchTimer?.cancel();

    dealerController.dispose();
    fromDateController.dispose();
    toDateController.dispose();

    super.dispose();
  }
}
