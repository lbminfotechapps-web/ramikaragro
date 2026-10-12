import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import '../bloc/order_history_bloc.dart';
import '../bloc/order_history_event.dart';
import '../bloc/order_history_state.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController searchController = TextEditingController();

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  // =========================================================
  // FILTER
  // =========================================================

  String selectedStatus = '';

  bool _isFilterExpanded = false;

  int userId = 0;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    _loadUserAndOrders();
  }

  Future<void> _loadUserAndOrders() async {
    final userData = await SecureStorage.instance.getUserData();

    userId = int.tryParse(userData?['user_id']?.toString() ?? '') ?? 0;

    if (!mounted) return;

    context.read<OrderHistoryBloc>().add(GetOrderHistoryEvent(userId: userId));
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  // =========================================================
  // STATUS VALUE
  // =========================================================

  String _getStatusValue(String status) {
    switch (status) {
      case 'Pending':
        return '0';

      case 'Approved':
        return '1';

      case 'Partial Dispatch':
        return '2';

      case 'Dispatch':
        return '5';

      case 'Cancelled':
        return '3';

      default:
        return '';
    }
  }

  // =========================================================
  // STATUS NAME
  // =========================================================

  String _getStatusName(String status) {
    switch (status) {
      case '0':
        return 'Pending';

      case '1':
        return 'Approved';

      case '2':
        return 'Partial Dispatch';

      case '3':
        return 'Cancelled';

      case '5':
        return 'Dispatch';

      default:
        return 'Unknown';
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _searchOrders() {
    final searchText = searchController.text.trim();

    final fromDate = fromDateController.text.trim();

    final toDate = toDateController.text.trim();

    // From date selected but To date empty
    if (fromDate.isNotEmpty && toDate.isEmpty) {
      _showMessage('Please select To Date');
      return;
    }

    // To date selected but From date empty
    if (toDate.isNotEmpty && fromDate.isEmpty) {
      _showMessage('Please select From Date');
      return;
    }

    // Search validation
    if (searchText.isNotEmpty && searchText.length < 3) {
      _showMessage('Please enter minimum 3 characters');
      return;
    }

    // Date validation
    if (fromDate.isNotEmpty &&
        toDate.isNotEmpty &&
        _parseDate(fromDate).isAfter(_parseDate(toDate))) {
      _showMessage('From Date cannot be greater than To Date');
      return;
    }

    context.read<OrderHistoryBloc>().add(
      GetOrderHistoryEvent(
        userId: userId,
        searchText: searchText,
        status: selectedStatus,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );

    // Collapse filter after search
    setState(() {
      _isFilterExpanded = false;
    });
  }

  // =========================================================
  // RESET
  // =========================================================

  void _resetSearch() {
    searchController.clear();
    fromDateController.clear();
    toDateController.clear();

    setState(() {
      selectedStatus = '';
      _isFilterExpanded = false;
    });

    context.read<OrderHistoryBloc>().add(
      GetOrderHistoryEvent(userId: userId, isRefresh: true),
    );
  }

  // =========================================================
  // DATE PARSER
  // =========================================================

  DateTime _parseDate(String date) {
    final parts = date.split('-');

    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }

    return DateTime(1900);
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> _selectDate({required TextEditingController controller}) async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    final day = selectedDate.day.toString().padLeft(2, '0');

    final month = selectedDate.month.toString().padLeft(2, '0');

    controller.text = '$day-$month-${selectedDate.year}';

    setState(() {});
  }

  // =========================================================
  // APPROVE
  // =========================================================

  void _approveOrder(String orderId) {
    context.read<OrderHistoryBloc>().add(
      UpdateOrderStatusEvent(
        userId: userId,
        orderId: orderId,
        orderStatus: '1',
        remark: '',
      ),
    );
  }

  // =========================================================
  // CANCEL
  // =========================================================

  Future<void> _cancelOrder(String orderId) async {
    final remarkController = TextEditingController();

    final remark = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogContext.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          title: const Text('Cancel Order'),
          content: TextField(
            controller: remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter cancellation reason',
              filled: true,
              fillColor: context.appTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final remark = remarkController.text.trim();

                if (remark.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, remark);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.error,
                foregroundColor: context.appColors.onError,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    remarkController.dispose();

    if (remark == null || remark.isEmpty) {
      return;
    }

    if (!mounted) return;

    context.read<OrderHistoryBloc>().add(
      UpdateOrderStatusEvent(
        userId: userId,
        orderId: orderId,
        orderStatus: '3',
        remark: remark,
      ),
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        title: 'Order History',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        // Normal refresh icon
        actionIcon: Icons.refresh_rounded,
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
        listener: (context, state) {
          if (state is OrderStatusUpdated) {
            _showMessage(state.message);
          }

          if (state is OrderHistoryError) {
            _showMessage(state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchSection(),

              Expanded(child: _buildOrderList(state)),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // FILTER SECTION
  // =========================================================

  Widget _buildSearchSection() {
    final filterCount = _getFilterCount();

    return Card(
      color: context.cardBackgroundColor,
      margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
      elevation: 3,
      shadowColor: context.appColors.shadow.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          // =================================================
          // FILTER HEADER
          // =================================================
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // -----------------------------------------
                  // FILTER ICON
                  // -----------------------------------------
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: context.primaryColor,
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // -----------------------------------------
                  // TITLE
                  // -----------------------------------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: context.cardTextColor,
                              ),
                            ),

                            if (filterCount > 0) ...[
                              SizedBox(width: 7.w),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryColor,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  '$filterCount',
                                  style: TextStyle(
                                    color: context.onPrimaryColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 2.h),

                        Text(
                          _isFilterExpanded
                              ? 'Hide search options'
                              : filterCount == 0
                              ? 'Search and filter orders'
                              : 'Filters applied',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -----------------------------------------
                  // ARROW
                  // -----------------------------------------
                  AnimatedRotation(
                    turns: _isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.secondaryTextColor,
                      size: 26.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =================================================
          // EXPANDED FILTER
          // =================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isFilterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedFilters(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EXPANDED FILTER CONTENT
  // =========================================================

  Widget _buildExpandedFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
      child: Column(
        children: [
          Divider(height: 1, color: context.borderColor),

          SizedBox(height: 14.h),

          // =================================================
          // SEARCH
          // =================================================
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Search Dealer Name',

              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: context.appTheme.inputBackground,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.primaryColor, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // =================================================
          // STATUS
          // =================================================
          DropdownButtonFormField<String>(
            value: selectedStatus.isEmpty
                ? null
                : _getStatusName(selectedStatus),
            decoration: InputDecoration(
              labelText: 'Order Status',
              prefixIcon: const Icon(Icons.assignment_rounded),
              filled: true,
              fillColor: context.appTheme.inputBackground,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 4.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.primaryColor, width: 1.5),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Approved', child: Text('Approved')),
              DropdownMenuItem(
                value: 'Partial Dispatch',
                child: Text('Partial Dispatch'),
              ),
              DropdownMenuItem(value: 'Dispatch', child: Text('Dispatch')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = _getStatusValue(value ?? '');
              });
            },
          ),

          SizedBox(height: 12.h),

          // =================================================
          // DATE FILTERS
          // =================================================
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: fromDateController,
                  label: 'From Date',
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: _buildDateField(
                  controller: toDateController,
                  label: 'To Date',
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // =================================================
          // BUTTONS
          // =================================================
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetSearch,
                  icon: Icon(Icons.refresh_rounded, size: 19.sp),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    side: BorderSide(
                      color: context.primaryColor.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _searchOrders,
                  icon: Icon(Icons.search_rounded, size: 19.sp),
                  label: const Text('Search Orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DATE FIELD
  // =========================================================

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () {
        _selectDate(controller: controller);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month_rounded),
        filled: true,
        fillColor: context.appTheme.inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // =========================================================
  // ORDER LIST
  // =========================================================

  Widget _buildOrderList(OrderHistoryState state) {
    // -------------------------------------------------------
    // INITIAL
    // -------------------------------------------------------

    if (state is OrderHistoryInitial) {
      return const Center(child: Text('Search orders'));
    }

    // -------------------------------------------------------
    // LOADING
    // -------------------------------------------------------

    if (state is OrderHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // -------------------------------------------------------
    // EMPTY
    // -------------------------------------------------------

    if (state is OrderHistoryEmpty) {
      return Center(
        child: Text(
          'NO RECORDS FOUND',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.secondaryTextColor,
          ),
        ),
      );
    }

    // -------------------------------------------------------
    // ERROR
    // -------------------------------------------------------

    if (state is OrderHistoryError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 50.sp,
                color: context.appColors.error,
              ),

              SizedBox(height: 10.h),

              Text(state.message, textAlign: TextAlign.center),

              SizedBox(height: 10.h),

              ElevatedButton(
                onPressed: _searchOrders,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // -------------------------------------------------------
    // LOADED
    // -------------------------------------------------------

    if (state is OrderHistoryLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<OrderHistoryBloc>().add(
            GetOrderHistoryEvent(
              userId: userId,
              searchText: searchController.text.trim(),
              status: selectedStatus,
              fromDate: fromDateController.text.trim(),
              toDate: toDateController.text.trim(),
              isRefresh: true,
            ),
          );
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                state.hasMore &&
                !state.isLoadingMore) {
              context.read<OrderHistoryBloc>().add(
                const LoadMoreOrderHistoryEvent(),
              );
            }

            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 20.h),
            itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.orders.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final order = state.orders[index];

              return _buildOrderCard(order);
            },
          ),
        ),
      );
    }

    // -------------------------------------------------------
    // STATUS UPDATING
    // -------------------------------------------------------

    if (state is OrderStatusUpdating) {
      return ListView.builder(
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(state.orders[index]);
        },
      );
    }

    // -------------------------------------------------------
    // STATUS UPDATED
    // -------------------------------------------------------

    if (state is OrderStatusUpdated) {
      return ListView.builder(
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(state.orders[index]);
        },
      );
    }

    return const SizedBox();
  }

  // =========================================================
  // ORDER CARD
  // =========================================================

  Widget _buildOrderCard(dynamic order) {
    final isPending = order.status == '0';

    final isReportingEmployee =
        userId.toString() == order.reportingToId.toString();

    final canShowApproveCancel =
        isPending && isReportingEmployee && order.statusReportingEmp == '0';

    return Card(
      color: context.cardBackgroundColor,
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 3,
      shadowColor: context.appColors.shadow.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================
            Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: context.primaryColor,
                    size: 21.sp,
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order : ${order.orderNo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: context.cardTextColor,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        order.orderDate,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusChip(order.status),
              ],
            ),

            SizedBox(height: 12.h),

            // =================================================
            // ORDER INFORMATION
            // =================================================
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.appTheme.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  //  _infoRow('SR No', order.empId),
                  _infoRow('Employee', order.admName),

                  _infoRow('Dealer', order.outletName),

                  _infoRow('Godown', order.godownName),

                  _infoRow('Total Case Qty', order.totalQty),

                  _infoRow('Grand Total', order.grandTotal),

                  if (order.remark.isNotEmpty) _infoRow('Remark', order.remark),

                  if (order.cancelReason.isNotEmpty)
                    _infoRow('Cancel Reason', order.cancelReason),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // =================================================
            // DETAILS BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showOrderDetails(order);
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColor,
                  side: BorderSide(
                    color: context.primaryColor.withValues(alpha: 0.4),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),

            // =================================================
            // APPROVE / CANCEL
            // =================================================
            // if (canShowApproveCancel) ...[
            //   SizedBox(height: 8.h),

            //   Row(
            //     children: [
            //       Expanded(
            //         child: ElevatedButton.icon(
            //           onPressed: () {
            //             _approveOrder(order.orderId);
            //           },
            //           icon: const Icon(Icons.check_rounded),
            //           label: const Text('Approve'),
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.green,
            //             foregroundColor: Colors.white,
            //             elevation: 2,
            //             padding: EdgeInsets.symmetric(vertical: 11.h),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10.r),
            //             ),
            //           ),
            //         ),
            //       ),

            //       SizedBox(width: 10.w),

            //       Expanded(
            //         child: ElevatedButton.icon(
            //           onPressed: () {
            //             _cancelOrder(order.orderId);
            //           },
            //           icon: const Icon(Icons.close_rounded),
            //           label: const Text('Cancel'),
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.red,
            //             foregroundColor: Colors.white,
            //             elevation: 0,
            //             padding: EdgeInsets.symmetric(vertical: 11.h),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10.r),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FILTER COUNT
  // =========================================================

  int _getFilterCount() {
    int count = 0;

    if (searchController.text.trim().isNotEmpty) {
      count++;
    }

    if (selectedStatus.isNotEmpty) {
      count++;
    }

    if (fromDateController.text.trim().isNotEmpty) {
      count++;
    }

    if (toDateController.text.trim().isNotEmpty) {
      count++;
    }

    return count;
  }

  // =========================================================
  // INFO ROW
  // =========================================================

  Widget _infoRow(String title, String value) {
    if (value.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.secondaryTextColor,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.cardTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CHIP
  // =========================================================

  Widget _statusChip(String status) {
    String text;
    Color color;

    switch (status) {
      case '0':
        text = 'Pending';
        color = context.appWarning;
        break;

      case '1':
        text = 'Approved';
        color = context.appSuccess;
        break;

      case '2':
        text = 'Partial Dispatch';
        color = context.primaryColor;
        break;

      case '3':
        text = 'Cancelled';
        color = context.appColors.error;
        break;

      case '5':
        text = 'Dispatch';
        color = context.appColors.secondary;
        break;

      default:
        text = 'Unknown';
        color = context.secondaryTextColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  // =========================================================
  // ORDER DETAILS
  // =========================================================

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 0.80.sh,
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // =============================================
                // HANDLE
                // =============================================
                SizedBox(height: 10.h),

                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 14.h),

                // =============================================
                // HEADER
                // =============================================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: context.primaryColor,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Order :${order.orderNo}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: context.cardTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                const Divider(height: 1),

                // =============================================
                // PRODUCT LIST
                // =============================================
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(14.w),
                    itemCount: order.orderDetails.length,
                    itemBuilder: (context, index) {
                      final detail = order.orderDetails[index];

                      return _buildDetailCard(detail);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // DETAIL CARD
  // =========================================================

  Widget _buildDetailCard(dynamic detail) {
    return Card(
      color: context.cardBackgroundColor,
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 2,
      shadowColor: context.appColors.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 8.h),

            _infoRow('Packing', detail.packing),

            // _infoRow('Quantity', detail.productQty),
            _infoRow('Case Qty', detail.totalCaseQuantity),

            _infoRow('Pending', detail.pendingQty),

            _infoRow('Dispatch', detail.dispatchQty),

            _infoRow('Amount', detail.productAmt),
          ],
        ),
      ),
    );
  }
}
