import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/distpatchistory/presentation/widget/dispatch_card.dart';
import 'package:solufine/features/distpatchistory/presentation/widget/dispatch_detail_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';

class DispatchPage extends StatefulWidget {
  const DispatchPage({super.key});

  @override
  State<DispatchPage> createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  int userId = 0;

  String selectedStatus = '';

  bool isFilterExpanded = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadUser();

    scrollController.addListener(_scrollListener);
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUser() async {
    final userData = await SecureStorage.instance.getUserData();

    userId =
        int.tryParse(
          userData?['user_id']?.toString() ?? '0',
        ) ??
        0;

    if (!mounted) return;

    context.read<DispatchBloc>().add(
      GetDispatchListEvent(
        userId: userId,
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  void _scrollListener() {
    if (!scrollController.hasClients) {
      return;
    }

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300) {
      context.read<DispatchBloc>().add(
        const LoadMoreDispatchEvent(),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7F9),

      appBar: CustomAppBar(
        title: 'Dispatch History',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        actionIcon: Icons.refresh_rounded,
      ),

      body: BlocConsumer<DispatchBloc, DispatchState>(
        listener: (context, state) {
          if (state is DispatchError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },

        builder: (context, state) {
          return Column(
            children: [
              _buildFilter(),

              Expanded(
                child: _buildBody(state),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        12.w,
        10.h,
        12.w,
        5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () {
              setState(() {
                isFilterExpanded = !isFilterExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 13.h,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.gradientStartColor.withOpacity(
                        0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.darkPrimaryColor,
                      size: 19.sp,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Text(
                      'Search & Filter',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Icon(
                    isFilterExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(
              milliseconds: 200,
            ),
            crossFadeState: isFilterExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildExpandedFilters(),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPANDED FILTERS
  // ============================================================

  Widget _buildExpandedFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        5.w,
        5.h,
        14.w,
        14.h,
      ),
      child: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================

          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search dealer Name',
              hintText: 'Search dealer Name',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  10.r,
                ),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          SizedBox(height: 5.h),

          // ======================================================
          // STATUS
          // ======================================================

          DropdownButtonFormField<String>(
            value: selectedStatus.isEmpty
                ? null
                : selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(
                Icons.flag_outlined,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  10.r,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: '0',
                child: Text('Pending'),
              ),
              DropdownMenuItem(
                value: '1',
                child: Text('Approved'),
              ),
              DropdownMenuItem(
                value: '2',
                child: Text(
                  'Partially Dispatched',
                ),
              ),
              DropdownMenuItem(
                value: '3',
                child: Text('Cancelled'),
              ),
              DropdownMenuItem(
                value: '4',
                child: Text('Hold'),
              ),
              DropdownMenuItem(
                value: '5',
                child: Text('Dispatched'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value ?? '';
              });
            },
          ),

          SizedBox(height: 10.h),

          // ======================================================
          // DATE FILTERS
          // ======================================================

          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller: fromDateController,
                  label: 'From Date',
                  onTap: () => _selectDate(true),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: _dateField(
                  controller: toDateController,
                  label: 'To Date',
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ======================================================
          // RESET / SEARCH BUTTONS
          // ======================================================

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(
                    Icons.search,
                  ),
                  label: const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(DispatchState state) {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (state is DispatchLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (state is DispatchEmpty) {
      return _buildEmpty();
    }

    // ==========================================================
    // DATA LOADED
    // ==========================================================

    if (state is DispatchLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<DispatchBloc>().add(
            GetDispatchListEvent(
              userId: userId,
              searchText: searchController.text.trim(),
              status: selectedStatus,
              fromDate: fromDateController.text,
              toDate: toDateController.text,
              isRefresh: true,
            ),
          );
        },

        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            12.w,
            6.h,
            12.w,
            20.h,
          ),
          itemCount:
              state.dispatchList.length +
              (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Pagination loader
            if (index == state.dispatchList.length) {
              return Padding(
                padding: EdgeInsets.all(16.h),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final dispatch =
                state.dispatchList[index];

            return DispatchCard(
              dispatch: dispatch,

              // ==================================================
              // OPEN DETAILS
              // ==================================================
              onDetails: () {
                _showDetails(dispatch);
              },
            );
          },
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state is DispatchError) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
            ),

            SizedBox(height: 10.h),

            const Text(
              'Something went wrong',
            ),

            SizedBox(height: 10.h),

            ElevatedButton(
              onPressed: () {
                context.read<DispatchBloc>().add(
                  GetDispatchListEvent(
                    userId: userId,
                    searchText:
                        searchController.text.trim(),
                    status: selectedStatus,
                    fromDate:
                        fromDateController.text,
                    toDate:
                        toDateController.text,
                    isRefresh: true,
                  ),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 70.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 12.h),

          Text(
            'NO RECORDS FOUND',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate(
    bool isFromDate,
  ) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked == null) return;

    final formatted =
        '${picked.day.toString().padLeft(2, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.year}';

    setState(() {
      if (isFromDate) {
        fromDateController.text = formatted;
      } else {
        toDateController.text = formatted;
      }
    });
  }

  // ============================================================
  // RESET FILTER
  // ============================================================

  void _resetFilters() {
    searchController.clear();
    fromDateController.clear();
    toDateController.clear();

    setState(() {
      selectedStatus = '';
      isFilterExpanded = false;
    });

    context.read<DispatchBloc>().add(
      GetDispatchListEvent(
        userId: userId,
        isRefresh: true,
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _search() {
    final search =
        searchController.text.trim();

    if (search.isNotEmpty &&
        search.length < 3) {
      _showMessage(
        'Please enter minimum 3 characters',
      );
      return;
    }

    final from =
        fromDateController.text.trim();

    final to =
        toDateController.text.trim();

    if (from.isNotEmpty && to.isEmpty) {
      _showMessage(
        'Please select To Date',
      );
      return;
    }

    if (to.isNotEmpty && from.isEmpty) {
      _showMessage(
        'Please select From Date',
      );
      return;
    }

    if (from.isNotEmpty &&
        to.isNotEmpty) {
      final fromDate = _parseDate(from);
      final toDate = _parseDate(to);

      if (fromDate != null &&
          toDate != null &&
          fromDate.isAfter(toDate)) {
        _showMessage(
          'From Date cannot be greater than To Date',
        );
        return;
      }
    }

    setState(() {
      isFilterExpanded = false;
    });

    context.read<DispatchBloc>().add(
      GetDispatchListEvent(
        userId: userId,
        searchText: search,
        status: selectedStatus,
        fromDate: from,
        toDate: to,
        isRefresh: true,
      ),
    );
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(String value) {
    try {
      // Your selected date is DD-MM-YYYY.
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

  // ============================================================
  // SHOW DISPATCH DETAILS
  // ============================================================

  void _showDetails(dynamic dispatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),

          child: Column(
            children: [
              SizedBox(height: 10.h),

              // ==================================================
              // HANDLE
              // ==================================================

              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: EdgeInsets.all(15.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dispatch Details',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ORDER INFORMATION
              //
              // IMPORTANT:
              // This is OUTSIDE ListView.builder.
              // Therefore Order No and Order Date display once.
              // ==================================================

              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _dispatchHeaderRow(
                      title: 'Order No',
                      value:
                          dispatch.orderNo
                              ?.toString() ??
                          '',
                    ),

                    _dispatchHeaderRow(
                      title: 'Order Date',
                      value:
                          dispatch.orderDate
                              ?.toString() ??
                          '',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ==================================================
              // DIVIDER
              // ==================================================

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
                child: Divider(
                  height: 1.h,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
              ),

              SizedBox(height: 5.h),

              // ==================================================
              // PRODUCT LIST
              //
              // ONLY PRODUCTS ARE INSIDE LOOP
              // ==================================================

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                  ),
                  itemCount:
                      dispatch.dispatchDetails.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final detail =
                        dispatch
                            .dispatchDetails[index];

                    return DispatchDetailCard(
                      detail: detail,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ORDER HEADER ROW
  // ============================================================

  Widget _dispatchHeaderRow({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 3.h,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // TITLE
          // ======================================================

          Expanded(
            flex: 50,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          // ======================================================
          // COLON
          // ======================================================

          SizedBox(
            width: 15.w,
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
              ),
            ),
          ),

          // ======================================================
          // VALUE
          // ======================================================

          Expanded(
            flex: 50,
            child: Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
              ),
              child: Text(
                value.trim().isEmpty
                    ? '-'
                    : value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color:
                      Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}