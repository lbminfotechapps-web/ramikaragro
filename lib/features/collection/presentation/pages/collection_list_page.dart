
import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/collection_list.dart';
import '../bloc/collection_list_bloc.dart';
import '../bloc/collection_list_event.dart';
import '../bloc/collection_list_state.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() =>
      _CollectionListPageState();
}

class _CollectionListPageState
    extends State<CollectionListPage> {
  late final CollectionListBloc _bloc;

  String? _userId;

  int _selectedMonth = DateTime.now().month;
  String _selectedStatus = 'Pending';

  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();

    _bloc = sl<CollectionListBloc>();

    _loadCollectionList();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadCollectionList() async {
    try {
      final secureStorage = sl<SecureStorage>();

      final userData =
          await secureStorage.getUserData();

      if (!mounted) return;

      if (userData == null || userData.isEmpty) {
        _showMessage('User data not found');
        return;
      }

      final userId =
          userData['user_id']?.toString();

      if (userId == null || userId.isEmpty) {
        _showMessage('User ID not found');
        return;
      }

      setState(() {
        _userId = userId;
      });

      _fetchCollectionList();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to get user information: $e',
      );
    }
  }

  // ============================================================
  // API
  // ============================================================

  void _fetchCollectionList() {
    if (_userId == null ||
        _userId!.isEmpty) {
      return;
    }

    debugPrint(
      'GET COLLECTION LIST '
      'userId=$_userId '
      'month=$_selectedMonth '
      'status=$_selectedStatus',
    );

    _bloc.add(
      GetCollectionListEvent(
        userId: _userId!,
        strMonth:
            _selectedMonth.toString(),
        strStatus: _selectedStatus,
        startLimit: 0,
        pageSize: _pageSize,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(12),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // MONTH
  // ============================================================

  void _onMonthChanged(int? month) {
    if (month == null) return;

    setState(() {
      _selectedMonth = month;
    });

    _fetchCollectionList();
  }

  // ============================================================
  // STATUS
  // ============================================================

  void _onStatusChanged(String? status) {
    if (status == null) return;

    setState(() {
      _selectedStatus = status;
    });

    _fetchCollectionList();
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return month >= 1 && month <= 12
        ? months[month]
        : '';
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor:
            const Color(0xffF5F7F9),

      appBar: CustomAppBar(
          title: 'Collection List',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
          // Normal refresh icon
          actionIcon: Icons.refresh_rounded,
          // Disable click while refreshing
          onActionIconTap: _fetchCollectionList,
         
        ),

        body: Column(
          children: [
            // ==================================================
            // COMPACT FILTER
            // ==================================================

            _CompactFilter(
              selectedMonth:
                  _selectedMonth,
              selectedStatus:
                  _selectedStatus,
              getMonthName:
                  _getMonthName,
              onMonthChanged:
                  _onMonthChanged,
              onStatusChanged:
                  _onStatusChanged,
            ),

            // ==================================================
            // LIST
            // ==================================================

            Expanded(
              child: BlocBuilder<
                  CollectionListBloc,
                  CollectionListState>(
                builder:
                    (context, state) {
                  if (state.status ==
                      CollectionListStatus
                          .loading) {
                      return const CustomLoader(
              showMessage: true,
              message: 'Authentication....',
            );
                  }

                  if (state.status ==
                      CollectionListStatus
                          .failure) {
                    return _ErrorView(
                      message:
                          state.errorMessage,
                      onRetry:
                          _fetchCollectionList,
                    );
                  }

                  if (state.status ==
                          CollectionListStatus
                              .success &&
                      state.collectionList
                          .isEmpty) {
                    return const _EmptyView();
                  }

                  if (state.status ==
                      CollectionListStatus
                          .success) {
                    return RefreshIndicator(
                      color:
                          const Color(
                        0xff0F8A4B,
                      ),
                      onRefresh: () async {
                        _fetchCollectionList();
                      },
                      child:
                          ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          10,
                          8,
                          10,
                          20,
                        ),
                        itemCount: state
                            .collectionList
                            .length,
                        itemBuilder:
                            (context, index) {
                          return CollectionListCard(
                            key: ValueKey(
                              state
                                  .collectionList[
                                      index]
                                  .id,
                            ),
                            collection: state
                                .collectionList[
                                    index],
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPACT FILTER
// ============================================================================

class _CompactFilter
    extends StatelessWidget {
  final int selectedMonth;
  final String selectedStatus;

  final String Function(int)
      getMonthName;

  final ValueChanged<int?>
      onMonthChanged;

  final ValueChanged<String?>
      onStatusChanged;

  const _CompactFilter({
    required this.selectedMonth,
    required this.selectedStatus,
    required this.getMonthName,
    required this.onMonthChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        8,
      ),
      color: Colors.white,

      child: Row(
        children: [
          Expanded(
            child:
                _FilterDropdown<int>(
              value: selectedMonth,
              icon: Icons
                  .calendar_month_rounded,
              items: List.generate(
                12,
                (index) {
                  final month =
                      index + 1;

                  return DropdownMenuItem<
                      int>(
                    value: month,
                    child: Text(
                      getMonthName(
                        month,
                      ),
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  );
                },
              ),
              onChanged:
                  onMonthChanged,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child:
                _FilterDropdown<String>(
              value: selectedStatus,
              icon: Icons
                  .filter_alt_rounded,
              items: const [
                DropdownMenuItem(
                  value: 'Pending',
                  child:
                      Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'Approved',
                  child:
                      Text('Approved'),
                ),
                DropdownMenuItem(
                  value: 'Rejected',
                  child:
                      Text('Rejected'),
                ),
              ],
              onChanged:
                  onStatusChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FILTER DROPDOWN
// ============================================================================

class _FilterDropdown<T>
    extends StatelessWidget {
  final T value;
  final IconData icon;
  final List<DropdownMenuItem<T>>
      items;
  final ValueChanged<T?>
      onChanged;

  const _FilterDropdown({
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isDense: true,
      isExpanded: true,

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
      ),

      decoration:
          InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 18,
          color:
              const Color(0xff0F8A4B),
        ),

        filled: true,
        fillColor:
            const Color(0xffF7F9F8),

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 8,
          vertical: 8,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          borderSide: BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xff0F8A4B),
          ),
        ),
      ),

      items: items,
      onChanged: onChanged,
    );
  }
}

// ============================================================================
// COLLECTION CARD
// ============================================================================

class CollectionListCard
    extends StatefulWidget {
  final CollectionList collection;

  const CollectionListCard({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionListCard>
      createState() =>
          _CollectionListCardState();
}

class _CollectionListCardState
    extends State<CollectionListCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.collection;

    final paymentMode =
        item.paymentMode
            .toUpperCase();

    final statusColor =
        _statusColor(item.status);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              const Color(0xffE7ECE9),
        ),

        boxShadow: const [
          BoxShadow(
            color:
                Color(0x09000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),

        child: Column(
          children: [
            // ==================================================
            // STATUS LINE
            // ==================================================

            Container(
              height: 3,
              color: statusColor,
            ),

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                12,
                11,
                12,
                10,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==========================================
                  // DEALER + AMOUNT
                  // ==========================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,

                    children: [
                      Container(
                        height: 40,
                        width: 40,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xff0F8A4B,
                          ).withOpacity(
                            0.09,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .storefront_rounded,
                          color:
                              Color(
                            0xff0F8A4B,
                          ),
                          size: 21,
                        ),
                      ),

                      const SizedBox(
                        width: 9,
                      ),

                      // DEALER
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              item.outletName
                                      .isEmpty
                                  ? 'Unknown Dealer'
                                  : item
                                      .outletName,

                              maxLines: 1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                              height: 2,
                            ),

                            Text(
                              item.paymentMode
                                      .isEmpty
                                  ? 'Payment'
                                  : item
                                      .paymentMode,

                              style:
                                  TextStyle(
                                fontSize: 11,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      // AMOUNT
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,

                        children: [
                          Text(
                            '₹ ${item.paymentAmount}',

                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  Color(
                                0xff0F8A4B,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          _StatusChip(
                            status:
                                item.status,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ==========================================
                  // REMARK
                  // ==========================================

                  if (item.remark
                      .isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        top: 9,
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Icon(
                            Icons
                                .notes_rounded,
                            size: 16,
                            color: Colors
                                .grey
                                .shade500,
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          Expanded(
                            child: Text(
                              item.remark,

                              maxLines:
                                  _expanded
                                      ? null
                                      : 1,

                              overflow:
                                  _expanded
                                      ? null
                                      : TextOverflow
                                          .ellipsis,

                              style:
                                  TextStyle(
                                fontSize: 12,
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==========================================
                  // VIEW DETAILS
                  // ==========================================

                  SizedBox(
                    height: 34,
                    width:
                        double.infinity,

                    child:
                        TextButton(
                      onPressed: () {
                        setState(() {
                          _expanded =
                              !_expanded;
                        });
                      },

                      style:
                          TextButton.styleFrom(
                        foregroundColor:
                            const Color(
                          0xff0F8A4B,
                        ),

                        backgroundColor:
                            const Color(
                          0xffF2F8F4,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                        ),

                        padding:
                            EdgeInsets.zero,
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            _expanded
                                ? 'Hide Details'
                                : 'View Details',

                            style:
                                const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          AnimatedRotation(
                            duration:
                                const Duration(
                              milliseconds:
                                  200,
                            ),

                            turns:
                                _expanded
                                    ? 0.5
                                    : 0,

                            child:
                                const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // EXPANDED DETAILS
                  // ==========================================

                  AnimatedSize(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),

                    curve:
                        Curves.easeInOut,

                    child: _expanded
                        ? Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              top: 9,
                            ),

                            child:
                                _DetailsSection(
                              item: item,
                              paymentMode:
                                  paymentMode,
                            ),
                          )
                        : const SizedBox
                            .shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(
      String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }
}

// ============================================================================
// DETAILS SECTION
// ============================================================================

class _DetailsSection
    extends StatelessWidget {
  final CollectionList item;
  final String paymentMode;

  const _DetailsSection({
    required this.item,
    required this.paymentMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color:
            const Color(0xffF7F9F8),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color:
              const Color(0xffE3E9E5),
        ),
      ),

      child: Column(
        children: [
          // ==================================================
          // GENERAL
          // ==================================================

          // _DetailRow(
          //   icon: Icons.tag_rounded,
          //   label: 'Collection ID',
          //   value: item.id,
          // ),

          // _DetailRow(
          //   icon:
          //       Icons.person_outline_rounded,
          //   label: 'User ID',
          //   value: item.userId,
          // ),

          // _DetailRow(
          //   icon:
          //       Icons.store_outlined,
          //   label: 'Dealer ID',
          //   value: item.dealerId,
          // ),

          _DetailRow(
            icon:
                Icons.storefront_outlined,
            label: 'Dealer',
            value: item.outletName,
          ),

          _DetailRow(
            icon:
                Icons.payments_outlined,
            label: 'Payment Mode',
            value:
                item.paymentMode,
          ),

          _DetailRow(
            icon:
                Icons.currency_rupee_rounded,
            label: 'Amount',
            value:
                '₹ ${item.paymentAmount}',
            valueColor:
                const Color(
              0xff0F8A4B,
            ),
          ),

          _DetailRow(
            icon:
                Icons.calendar_today_outlined,
            label: 'Payment Date',
            value:
                item.paymentDate,
          ),

          _DetailRow(
            icon:
                Icons.flag_outlined,
            label: 'Status',
            value: item.status,
          ),

          // ==================================================
          // RTGS
          // ==================================================

          if (paymentMode == 'RTGS' &&
              item.rtgsNo.isNotEmpty)
            _DetailRow(
              icon:
                  Icons.receipt_long_outlined,
              label: 'RTGS No.',
              value: item.rtgsNo,
            ),

          // ==================================================
          // NEFT
          // ==================================================

          if (paymentMode == 'NEFT' &&
              item.neftNo.isNotEmpty)
            _DetailRow(
              icon:
                  Icons.receipt_long_outlined,
              label: 'NEFT No.',
              value: item.neftNo,
            ),

          // ==================================================
          // CHEQUE
          // ==================================================

          if (paymentMode == 'CHEQUE') ...[
            if (item.chequeNo.isNotEmpty &&
                item.chequeNo != '0')
              _DetailRow(
                icon:
                    Icons.receipt_long_outlined,
                label: 'Cheque No.',
                value:
                    item.chequeNo,
              ),

            if (item.chequeDate
                    .isNotEmpty &&
                item.chequeDate !=
                    '00-00-0000')
              _DetailRow(
                icon:
                    Icons.calendar_today_outlined,
                label: 'Cheque Date',
                value:
                    item.chequeDate,
              ),

            if (item.bankName.isNotEmpty)
              _DetailRow(
                icon:
                    Icons.account_balance_outlined,
                label: 'Bank',
                value:
                    item.bankName,
              ),

            if (item.depositBankName
                    .isNotEmpty &&
                item.depositBankName !=
                    'SELECT DEPOSIT BANK NAME')
              _DetailRow(
                icon:
                    Icons.account_balance_rounded,
                label: 'Deposit Bank',
                value: item
                    .depositBankName,
              ),

            if (item.branchName.isNotEmpty)
              _DetailRow(
                icon:
                    Icons.location_city_outlined,
                label: 'Branch',
                value:
                    item.branchName,
              ),
          ],

          // ==================================================
          // CHEQUE PASSING
          // ==================================================

          if (item.chequePassingDate !=
                  null &&
              item.chequePassingDate!
                  .isNotEmpty)
            _DetailRow(
              icon:
                  Icons.event_available_outlined,
              label:
                  'Cheque Passing',
              value:
                  item.chequePassingDate!,
            ),

          // ==================================================
          // REASON
          // ==================================================

          if (item.reason != null &&
              item.reason!.isNotEmpty)
            _DetailRow(
              icon:
                  Icons.warning_amber_rounded,
              label: 'Reason',
              value: item.reason!,
            ),

          // ==================================================
          // REMARK
          // ==================================================

          if (item.remark.isNotEmpty)
            _DetailRow(
              icon:
                  Icons.notes_outlined,
              label: 'Remark',
              value: item.remark,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 16,
            color:
                Colors.grey.shade600,
          ),

          const SizedBox(
            width: 7,
          ),

          SizedBox(
            width: 88,

            child: Text(
              label,

              style: TextStyle(
                fontSize: 11,
                color: Colors
                    .grey
                    .shade600,
              ),
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          Expanded(
            child: Text(
              value,

              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    valueColor ??
                        const Color(
                          0xff252A27,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _StatusChip
    extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved =
        status.toLowerCase() ==
            'approved';

    final isRejected =
        status.toLowerCase() ==
            'rejected';

    final Color color =
        isApproved
            ? Colors.green.shade700
            : isRejected
                ? Colors.red.shade700
                : Colors.orange.shade800;

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 7,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(0.09),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        status.isEmpty
            ? 'Unknown'
            : status,

        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyView
    extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .account_balance_wallet_outlined,
              size: 52,
              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'No collection found',

              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              'Try another month or status.',

              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .error_outline_rounded,
              size: 48,
              color:
                  Colors.red.shade400,
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Something went wrong',

              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              message.replaceFirst(
                'Exception: ',
                '',
              ),

              textAlign:
                  TextAlign.center,

              maxLines: 3,

              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 36,

              child:
                  ElevatedButton.icon(
                onPressed: onRetry,

                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                ),

                label: const Text(
                  'Retry',
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xff0F8A4B,
                  ),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      9,
                    ),
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

