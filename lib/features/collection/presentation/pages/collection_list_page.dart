import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';

// CHANGE PATH IF REQUIRED

// CHANGE PATH IF REQUIRED
import '../../data/models/dealer_search_model.dart';
import '../../domain/entities/dealer_search_entity.dart';

import '../../domain/entities/collection_list.dart';

import '../bloc/collection_list_bloc.dart';
import '../bloc/collection_list_event.dart';
import '../bloc/collection_list_state.dart';

// ============================================================================
// COLLECTION LIST PAGE
// ============================================================================

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  late final CollectionListBloc _bloc;

  String? _userId;
  bool _showFilter = false;
  // ==========================================================================
  // FILTER
  // ==========================================================================

  int _selectedMonth = DateTime.now().month;

  String _selectedStatus = 'All';

  /// null means All Dealers
  DealerSearchEntity? _selectedDealer;

  final int _pageSize = 20;

  // ==========================================================================
  // INIT
  // ==========================================================================

  void _toggleFilter() {
    setState(() {
      _showFilter = !_showFilter;
    });
  }

  @override
  void initState() {
    super.initState();

    _bloc = sl<CollectionListBloc>();

    _loadCollectionList();
  }

  // ==========================================================================
  // LOAD USER
  // ==========================================================================

  Future<void> _loadCollectionList() async {
    try {
      final secureStorage = sl<SecureStorage>();

      final userData = await secureStorage.getUserData();

      if (!mounted) {
        return;
      }

      if (userData == null || userData.isEmpty) {
        _showMessage('User data not found');

        return;
      }

      final String? userId = userData['user_id']?.toString();

      if (userId == null || userId.isEmpty) {
        _showMessage('User ID not found');

        return;
      }

      setState(() {
        _userId = userId;
      });

      _fetchCollectionList();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to get user information: $e');
    }
  }

  // ==========================================================================
  // COLLECTION API
  // ==========================================================================

  void _fetchCollectionList() {
    if (_userId == null || _userId!.isEmpty) {
      return;
    }

    final String dealerId = _selectedDealer?.outletId ?? '';

    debugPrint('=======================================');

    debugPrint('GET COLLECTION LIST');

    debugPrint('USER ID: $_userId');

    debugPrint('MONTH: $_selectedMonth');

    debugPrint('STATUS: $_selectedStatus');

    debugPrint(
      'DEALER ID: '
      '${dealerId.isEmpty ? 'ALL' : dealerId}',
    );

    debugPrint(
      'DEALER NAME: '
      '${_selectedDealer?.outletName ?? 'ALL'}',
    );

    debugPrint('=======================================');

    _bloc.add(
      GetCollectionListEvent(
        userId: _userId!,

        strMonth: _selectedMonth.toString(),

        strStatus: _selectedStatus,

        dealerId: dealerId,

        startLimit: 0,

        pageSize: _pageSize,
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(12),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================================
  // MONTH
  // ==========================================================================

  void _onMonthChanged(int? month) {
    if (month == null) {
      return;
    }

    setState(() {
      _selectedMonth = month;

      // Reset dealer
      _selectedDealer = null;
    });

    _fetchCollectionList();
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  void _onStatusChanged(String? status) {
    if (status == null) {
      return;
    }

    setState(() {
      _selectedStatus = status;

      // Reset dealer
      _selectedDealer = null;
    });

    _fetchCollectionList();
  }

  // ==========================================================================
  // DEALER
  // ==========================================================================

  void _onDealerSelected(DealerSearchEntity? dealer) {
    setState(() {
      _selectedDealer = dealer;
    });

    if (dealer == null) {
      debugPrint('SELECTED DEALER: ALL');

      return;
    }

    debugPrint('=======================================');

    debugPrint(
      'SELECTED DEALER ID: '
      '${dealer.outletId}',
    );

    debugPrint(
      'SELECTED DEALER NAME: '
      '${dealer.outletName}',
    );

    debugPrint(
      'SELECTED DEALER MOBILE: '
      '${dealer.outletMobile}',
    );

    debugPrint('=======================================');
  }

  // ==========================================================================
  // OPEN DEALER
  // ==========================================================================

  void _openDealerSearch() {
    if (_userId == null || _userId!.isEmpty) {
      _showMessage('User ID not found');

      return;
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return _DealerSearchSheet(
          userId: _userId!,

          selectedDealer: _selectedDealer,

          onSelected: (dealer) {
            _onDealerSelected(dealer);
          },
        );
      },
    );
  }

  // ==========================================================================
  // FILTER COLLECTION
  // ==========================================================================

  List<CollectionList> _getFilteredCollections(List<CollectionList> list) {
    // ALL DEALERS
    if (_selectedDealer == null) {
      return list;
    }

    final String selectedId = _selectedDealer!.outletId.trim();

    final String selectedName = _selectedDealer!.outletName
        .trim()
        .toLowerCase();

    return list.where((item) {
      // ====================================================================
      // PREFERRED: COMPARE DEALER ID
      // ====================================================================

      final String itemDealerId = item.dealerId.trim();

      if (selectedId.isNotEmpty && itemDealerId.isNotEmpty) {
        return itemDealerId == selectedId;
      }

      // ====================================================================
      // FALLBACK: COMPARE DEALER NAME
      // ====================================================================

      return item.outletName.trim().toLowerCase() == selectedName;
    }).toList();
  }

  // ==========================================================================
  // MONTH NAME
  // ==========================================================================

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

    return month >= 1 && month <= 12 ? months[month] : '';
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _bloc.close();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7F9),

        // ====================================================================
        // APP BAR
        // ====================================================================
        appBar: CustomAppBar(
          title: 'Collection List',

          showBackButton: true,

          onBackTap: () => context.go(AppRouter.home),

          actionIcon: Icons.refresh_rounded,

          onActionIconTap: _fetchCollectionList,
        ),

        // ====================================================================
        // BODY
        // ====================================================================
        body: BlocBuilder<CollectionListBloc, CollectionListState>(
          builder: (context, state) {
            final List<CollectionList> filteredList = _getFilteredCollections(
              state.collectionList,
            );

            return Column(
              children: [
                // ============================================================
                // FILTER
                // ============================================================
                _CompactFilter(
                  showFilter: _showFilter,

                  onToggle: _toggleFilter,

                  selectedMonth: _selectedMonth,

                  selectedStatus: _selectedStatus,

                  selectedDealer: _selectedDealer,

                  getMonthName: _getMonthName,

                  onMonthChanged: _onMonthChanged,

                  onStatusChanged: _onStatusChanged,

                  onDealerTap: _openDealerSearch,
                ),

                // ============================================================
                // RESULT COUNT
                // ============================================================
                if (state.status == CollectionListStatus.success)
                  _FilterResultInfo(
                    count: filteredList.length,

                    selectedDealer: _selectedDealer,
                  ),

                // ============================================================
                // LIST
                // ============================================================
                Expanded(
                  child: _buildList(state: state, filteredList: filteredList),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD LIST
  // ==========================================================================

  Widget _buildList({
    required CollectionListState state,

    required List<CollectionList> filteredList,
  }) {
    // =========================================================================
    // LOADING
    // =========================================================================

    if (state.status == CollectionListStatus.loading) {
      return const CustomLoader(showMessage: true);
    }

    // =========================================================================
    // FAILURE
    // =========================================================================

    if (state.status == CollectionListStatus.failure) {
      return _ErrorView(
        message: state.errorMessage,

        onRetry: _fetchCollectionList,
      );
    }

    // =========================================================================
    // EMPTY
    // =========================================================================

    if (state.status == CollectionListStatus.success &&
        state.collectionList.isEmpty) {
      return const _EmptyView();
    }

    // =========================================================================
    // FILTER EMPTY
    // =========================================================================

    if (state.status == CollectionListStatus.success && filteredList.isEmpty) {
      return _DealerEmptyView(dealer: _selectedDealer);
    }

    // =========================================================================
    // SUCCESS
    // =========================================================================

    if (state.status == CollectionListStatus.success) {
      return RefreshIndicator(
        color: const Color(0xff0F8A4B),

        onRefresh: () async {
          _fetchCollectionList();
        },

        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),

          itemCount: filteredList.length,

          itemBuilder: (context, index) {
            final item = filteredList[index];

            return CollectionListCard(key: ValueKey(item.id), collection: item);
          },
        ),
      );
    }

    return const SizedBox();
  }
}

// ============================================================================
// COMPACT FILTER
// ============================================================================

class _CompactFilter extends StatelessWidget {
  final bool showFilter;

  final VoidCallback onToggle;

  final int selectedMonth;

  final String selectedStatus;

  final DealerSearchEntity? selectedDealer;

  final String Function(int) getMonthName;

  final ValueChanged<int?> onMonthChanged;

  final ValueChanged<String?> onStatusChanged;

  final VoidCallback onDealerTap;

  const _CompactFilter({
    required this.showFilter,
    required this.onToggle,
    required this.selectedMonth,
    required this.selectedStatus,
    required this.selectedDealer,
    required this.getMonthName,
    required this.onMonthChanged,
    required this.onStatusChanged,
    required this.onDealerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: const BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          // ================================================================
          // FILTER HEADER
          // ================================================================
          Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: onToggle,

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),

                child: Row(
                  children: [
                    // ======================================================
                    // FILTER ICON
                    // ======================================================
                    Container(
                      height: 34,

                      width: 34,

                      decoration: BoxDecoration(
                        color: const Color(0xff0F8A4B).withOpacity(0.09),

                        borderRadius: BorderRadius.circular(9),
                      ),

                      child: const Icon(
                        Icons.tune_rounded,

                        size: 18,

                        color: Color(0xff0F8A4B),
                      ),
                    ),

                    const SizedBox(width: 9),

                    // ======================================================
                    // TITLE
                    // ======================================================
                    const Expanded(
                      child: Text(
                        'Filter Collections',

                        style: TextStyle(
                          fontSize: 14,

                          fontWeight: FontWeight.w700,

                          color: Color(0xff252A27),
                        ),
                      ),
                    ),

                    // ======================================================
                    // ACTIVE FILTER TEXT
                    // ======================================================

                    // if (!showFilter)
                    //   Flexible(
                    //     child:
                    //         Text(
                    //       _getFilterSummary(),

                    //       maxLines:
                    //           1,

                    //       overflow:
                    //           TextOverflow
                    //               .ellipsis,

                    //       style:
                    //           TextStyle(
                    //         fontSize:
                    //             10,

                    //         color:
                    //             Colors
                    //                 .grey
                    //                 .shade600,
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(width: 6),

                    // ======================================================
                    // ARROW
                    // ======================================================
                    AnimatedRotation(
                      turns: showFilter ? 0.5 : 0,

                      duration: const Duration(milliseconds: 250),

                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,

                        color: Color(0xff0F8A4B),

                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================================================================
          // ANIMATED FILTER BODY
          // ================================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),

            crossFadeState: showFilter
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            firstChild: const SizedBox(width: double.infinity, height: 0),

            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

              child: Column(
                children: [
                  // ========================================================
                  // DEALER
                  // ========================================================
                  _SearchableDealerField(
                    selectedDealer: selectedDealer,

                    onTap: onDealerTap,
                  ),

                  const SizedBox(height: 9),

                  // ========================================================
                  // MONTH + STATUS
                  // ========================================================
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown<int>(
                          value: selectedMonth,

                          icon: Icons.calendar_month_rounded,

                          items: List.generate(12, (index) {
                            final month = index + 1;

                            return DropdownMenuItem<int>(
                              value: month,

                              child: Text(
                                getMonthName(month),

                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),

                          onChanged: onMonthChanged,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _FilterDropdown<String>(
                          value: selectedStatus,

                          icon: Icons.filter_alt_rounded,

                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),

                            DropdownMenuItem(
                              value: 'Pending',

                              child: Text('Pending'),
                            ),

                            DropdownMenuItem(
                              value: 'Approved',

                              child: Text('Approved'),
                            ),

                            DropdownMenuItem(
                              value: 'Cancelled',

                              child: Text('Cancelled'),
                            ),
                          ],

                          onChanged: onStatusChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FILTER SUMMARY
  // ==========================================================================

  String _getFilterSummary() {
    final String dealerName = selectedDealer?.outletName ?? 'All Dealers';

    return '${getMonthName(selectedMonth)} • '
        '$selectedStatus • '
        '$dealerName';
  }
}

// ============================================================================
// SEARCHABLE DEALER FIELD
// ============================================================================

class _SearchableDealerField extends StatelessWidget {
  final DealerSearchEntity? selectedDealer;

  final VoidCallback onTap;

  const _SearchableDealerField({
    required this.selectedDealer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(11),

        child: Container(
          constraints: const BoxConstraints(minHeight: 56),

          decoration: BoxDecoration(
            color: const Color(0xffF7F9F8),

            borderRadius: BorderRadius.circular(11),

            border: Border.all(color: const Color(0xffE3E9E5)),
          ),

          child: Row(
            children: [
              Container(
                height: 36,

                width: 36,

                decoration: BoxDecoration(
                  color: const Color(0xff0F8A4B).withOpacity(0.08),

                  borderRadius: BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons.storefront_rounded,

                  color: Color(0xff0F8A4B),

                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Dealer',

                      style: TextStyle(
                        fontSize: 10,

                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      selectedDealer?.outletName ?? 'All Dealers',

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,

                        fontWeight: FontWeight.w600,

                        color: Color(0xff252A27),
                      ),
                    ),

                    if (selectedDealer != null &&
                        selectedDealer!.outletMobile.isNotEmpty) ...[
                      const SizedBox(height: 1),

                      Text(
                        selectedDealer!.outletMobile,

                        style: TextStyle(
                          fontSize: 9.5,

                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 34,

                width: 34,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(color: const Color(0xffE1E8E3)),
                ),

                child: const Icon(
                  Icons.search_rounded,

                  color: Color(0xff0F8A4B),

                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DEALER SEARCH SHEET
// ============================================================================

class _DealerSearchSheet extends StatefulWidget {
  final String userId;

  final DealerSearchEntity? selectedDealer;

  final ValueChanged<DealerSearchEntity?> onSelected;

  const _DealerSearchSheet({
    required this.userId,
    required this.selectedDealer,
    required this.onSelected,
  });

  @override
  State<_DealerSearchSheet> createState() => _DealerSearchSheetState();
}

class _DealerSearchSheetState extends State<_DealerSearchSheet> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<DealerSearchEntity> _dealers = [];

  bool _loading = false;

  String? _errorMessage;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _searchDealers('');
  }

  // ==========================================================================
  // SEARCH DEALER API
  // ==========================================================================

  Future<void> _searchDealers(String searchText) async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _errorMessage = null;
        });
      }

      debugPrint('========================================');

      debugPrint('SEARCH DEALER API');

      debugPrint('USER ID: ${widget.userId}');

      debugPrint('SEARCH TEXT: "$searchText"');

      // ============================================================
      // API CALL
      // ============================================================

      final Response response = await DioClient().client.post(
        ApiClient.getTalukaWiseOutletForOrderNew,
        data: FormData.fromMap({
          'userId': widget.userId,
          'searchText': searchText,
        }),
      );

      debugPrint(
        'DEALER RESPONSE: '
        '${response.data}',
      );

      debugPrint(
        'RESPONSE TYPE: '
        '${response.data.runtimeType}',
      );

      // ============================================================
      // CONVERT RESPONSE
      // ============================================================

      late Map<String, dynamic> responseJson;

      // API returned JSON object directly
      if (response.data is Map<String, dynamic>) {
        responseJson = response.data;
      }
      // API returned Map<dynamic, dynamic>
      else if (response.data is Map) {
        responseJson = Map<String, dynamic>.from(response.data as Map);
      }
      // API returned JSON as STRING
      else if (response.data is String) {
        final String responseString = response.data.toString().trim();

        if (responseString.isEmpty) {
          throw Exception('Empty dealer response');
        }

        final dynamic decoded = jsonDecode(responseString);

        if (decoded is! Map) {
          throw Exception('Invalid dealer response format');
        }

        responseJson = Map<String, dynamic>.from(decoded);
      } else {
        throw Exception('Invalid dealer response');
      }

      debugPrint(
        'PARSED RESPONSE: '
        '$responseJson',
      );

      // ============================================================
      // RESPONSE MODEL
      // ============================================================

      final DealerSearchResponseModel dealerResponse =
          DealerSearchResponseModel.fromJson(responseJson);

      debugPrint(
        'STATUS: '
        '${dealerResponse.status}',
      );

      debugPrint(
        'MESSAGE: '
        '${dealerResponse.message}',
      );

      // ============================================================
      // STATUS FALSE
      // ============================================================

      if (!dealerResponse.status) {
        if (!mounted) {
          return;
        }

        setState(() {
          _dealers = [];
          _loading = false;
          _errorMessage = null;
        });

        return;
      }

      // ============================================================
      // RESULT
      // ============================================================

      final List<DealerSearchEntity> dealers = dealerResponse.result
          .where(
            (dealer) =>
                dealer.outletId.isNotEmpty && dealer.outletName.isNotEmpty,
          )
          .toList();

      // ============================================================
      // SORT
      // ============================================================

      dealers.sort(
        (a, b) =>
            a.outletName.toLowerCase().compareTo(b.outletName.toLowerCase()),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _dealers = dealers;
        _loading = false;
      });

      debugPrint(
        'TOTAL DEALERS: '
        '${dealers.length}',
      );

      for (final dealer in dealers) {
        debugPrint(
          'DEALER => '
          '${dealer.outletId} | '
          '${dealer.outletName} | '
          '${dealer.outletMobile}',
        );
      }

      debugPrint('========================================');
    } on DioException catch (e) {
      debugPrint(
        'DEALER DIO ERROR: '
        '${e.response?.data}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _dealers = [];
        _errorMessage = 'Unable to load dealers';
      });
    } catch (e) {
      debugPrint('DEALER ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _dealers = [];
        _errorMessage = 'Unable to load dealers';
      });
    }
  }

  // ==========================================================================
  // SEARCH TEXT
  // ==========================================================================

  void _onSearchChanged(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchDealers(value.trim());
    });
  }

  // ==========================================================================
  // CLEAR
  // ==========================================================================

  void _clearSearch() {
    _searchController.clear();

    _debounce?.cancel();

    setState(() {});

    _searchDealers('');
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _debounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.82,

      child: Material(
        color: Colors.transparent,

        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),

          child: Column(
            children: [
              // ===============================================================
              // HANDLE
              // ===============================================================
              Container(
                margin: const EdgeInsets.only(top: 9),

                height: 4,

                width: 42,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,

                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // ===============================================================
              // HEADER
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 8, 8),

                child: Row(
                  children: [
                    Container(
                      height: 40,

                      width: 40,

                      decoration: BoxDecoration(
                        color: const Color(0xff0F8A4B).withOpacity(0.09),

                        borderRadius: BorderRadius.circular(11),
                      ),

                      child: const Icon(
                        Icons.storefront_rounded,

                        color: Color(0xff0F8A4B),

                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Select Dealer',

                            style: TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.w700,

                              color: Color(0xff252A27),
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            'Search dealer and select',

                            style: TextStyle(fontSize: 11, color: Colors.grey),
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

              // ===============================================================
              // SEARCH FIELD
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),

                child: TextField(
                  controller: _searchController,

                  autofocus: false,

                  textInputAction: TextInputAction.search,

                  onChanged: _onSearchChanged,

                  decoration: InputDecoration(
                    hintText: 'Search dealer name...',

                    hintStyle: TextStyle(
                      fontSize: 13,

                      color: Colors.grey.shade500,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,

                      color: Color(0xff0F8A4B),
                    ),

                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,

                            icon: const Icon(Icons.close_rounded, size: 19),
                          )
                        : null,

                    filled: true,

                    fillColor: const Color(0xffF7F9F8),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,

                      vertical: 13,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),

                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),

                      borderSide: const BorderSide(
                        color: Color(0xff0F8A4B),

                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // ===============================================================
              // ALL DEALERS
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),

                child: _DealerSearchItem(
                  outletName: 'All Dealers',

                  mobile: 'Show all collection records',

                  selected: widget.selectedDealer == null,

                  icon: Icons.groups_2_outlined,

                  onTap: () {
                    widget.onSelected(null);

                    Navigator.pop(context);
                  },
                ),
              ),

              // ===============================================================
              // RESULT
              // ===============================================================
              Expanded(child: _buildDealerResult()),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DEALER RESULT
  // ==========================================================================

  Widget _buildDealerResult() {
    // =========================================================================
    // LOADING
    // =========================================================================

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xff0F8A4B)),
      );
    }

    // =========================================================================
    // ERROR
    // =========================================================================

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                Icons.error_outline_rounded,

                size: 42,

                color: Colors.red.shade400,
              ),

              const SizedBox(height: 8),

              Text(_errorMessage!, textAlign: TextAlign.center),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  _searchDealers(_searchController.text.trim());
                },

                icon: const Icon(Icons.refresh_rounded),

                label: const Text('Retry'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F8A4B),

                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================================
    // EMPTY
    // =========================================================================

    if (_dealers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              height: 65,

              width: 65,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.search_off_rounded,

                size: 31,

                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'No dealer found',

              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 4),

            Text(
              'Try another dealer name.',

              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // =========================================================================
    // LIST
    // =========================================================================

    return Column(
      children: [
        // =====================================================================
        // COUNT
        // =====================================================================
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 4),

          child: Align(
            alignment: Alignment.centerLeft,

            child: Text(
              '${_dealers.length} dealer${_dealers.length == 1 ? '' : 's'} found',

              style: TextStyle(
                fontSize: 11,

                fontWeight: FontWeight.w500,

                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),

        // =====================================================================
        // DEALER LIST
        // =====================================================================
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.fromLTRB(10, 3, 10, 20),

            itemCount: _dealers.length,

            itemBuilder: (context, index) {
              final DealerSearchEntity dealer = _dealers[index];

              final bool selected =
                  widget.selectedDealer?.outletId == dealer.outletId;

              return _DealerSearchItem(
                outletName: dealer.outletName,

                mobile: dealer.outletMobile,

                selected: selected,

                icon: Icons.storefront_outlined,

                onTap: () {
                  debugPrint(
                    'SELECT DEALER => '
                    '${dealer.outletId} | '
                    '${dealer.outletName}',
                  );

                  widget.onSelected(dealer);

                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DEALER SEARCH ITEM
// ============================================================================

class _DealerSearchItem extends StatelessWidget {
  final String outletName;

  final String mobile;

  final bool selected;

  final IconData icon;

  final VoidCallback onTap;

  const _DealerSearchItem({
    required this.outletName,
    required this.mobile,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),

      // Material + InkWell fixes:
      //
      // ListTile background color or ink splashes
      // may be invisible.
      child: Material(
        color: selected ? const Color(0xffEAF6EF) : Colors.white,

        borderRadius: BorderRadius.circular(11),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(11),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),

              border: Border.all(
                color: selected
                    ? const Color(0xff0F8A4B)
                    : const Color(0xffE8ECE9),
              ),
            ),

            child: Row(
              children: [
                Container(
                  height: 40,

                  width: 40,

                  decoration: BoxDecoration(
                    color: const Color(0xff0F8A4B).withOpacity(0.08),

                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Icon(icon, size: 19, color: const Color(0xff0F8A4B)),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        outletName,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 13,

                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,

                          color: const Color(0xff252A27),
                        ),
                      ),

                      if (mobile.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),

                        Text(
                          mobile,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 10.5,

                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,

                    color: Color(0xff0F8A4B),

                    size: 22,
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,

                    color: Colors.grey.shade400,

                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FILTER RESULT INFO
// ============================================================================

class _FilterResultInfo extends StatelessWidget {
  final int count;

  final DealerSearchEntity? selectedDealer;

  const _FilterResultInfo({required this.count, required this.selectedDealer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(11, 7, 11, 3),

      color: const Color(0xffF5F7F9),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

            decoration: BoxDecoration(
              color: const Color(0xff0F8A4B).withOpacity(0.08),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.receipt_long_outlined,

                  size: 13,

                  color: Color(0xff0F8A4B),
                ),

                const SizedBox(width: 4),

                Text(
                  '$count collection${count == 1 ? '' : 's'}',

                  style: const TextStyle(
                    fontSize: 10.5,

                    fontWeight: FontWeight.w700,

                    color: Color(0xff0F8A4B),
                  ),
                ),
              ],
            ),
          ),

          if (selectedDealer != null) ...[
            const SizedBox(width: 8),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  Icon(
                    Icons.store_outlined,

                    size: 13,

                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 3),

                  Flexible(
                    child: Text(
                      selectedDealer!.outletName,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 10.5,

                        fontWeight: FontWeight.w600,

                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// FILTER DROPDOWN
// ============================================================================

class _FilterDropdown<T> extends StatelessWidget {
  final T value;

  final IconData icon;

  final List<DropdownMenuItem<T>> items;

  final ValueChanged<T?> onChanged;

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

      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),

      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: const Color(0xff0F8A4B)),

        filled: true,

        fillColor: const Color(0xffF7F9F8),

        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: const BorderSide(color: Color(0xff0F8A4B)),
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

class CollectionListCard extends StatefulWidget {
  final CollectionList collection;

  const CollectionListCard({super.key, required this.collection});

  @override
  State<CollectionListCard> createState() => _CollectionListCardState();
}

class _CollectionListCardState extends State<CollectionListCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.collection;

    final paymentMode = item.paymentMode.toUpperCase();

    final statusColor = _statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xffE7ECE9)),

        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),

            blurRadius: 8,

            offset: Offset(0, 2),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),

        child: Column(
          children: [
            Container(height: 3, color: statusColor),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ===========================================================
                  // DEALER + AMOUNT
                  // ===========================================================
                  Row(
                    children: [
                      Container(
                        height: 40,

                        width: 40,

                        decoration: BoxDecoration(
                          color: const Color(0xff0F8A4B).withOpacity(0.09),

                          borderRadius: BorderRadius.circular(11),
                        ),

                        child: const Icon(
                          Icons.storefront_rounded,

                          color: Color(0xff0F8A4B),

                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              item.outletName.isEmpty
                                  ? 'Unknown Dealer'
                                  : item.outletName,

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 15,

                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              item.paymentMode.isEmpty
                                  ? 'Payment'
                                  : item.paymentMode,

                              style: TextStyle(
                                fontSize: 11,

                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          Text(
                            '₹ ${item.paymentAmount}',

                            style: const TextStyle(
                              fontSize: 17,

                              fontWeight: FontWeight.w800,

                              color: Color(0xff0F8A4B),
                            ),
                          ),

                          const SizedBox(height: 3),

                          _StatusChip(status: item.status),
                        ],
                      ),
                    ],
                  ),

                  // ===========================================================
                  // REMARK
                  // ===========================================================
                  if (item.remark.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 9),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Icon(
                            Icons.notes_rounded,

                            size: 16,

                            color: Colors.grey.shade500,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              item.remark,

                              maxLines: _expanded ? null : 1,

                              overflow: _expanded
                                  ? null
                                  : TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 12,

                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // ===========================================================
                  // VIEW DETAILS
                  // ===========================================================
                  SizedBox(
                    height: 34,

                    width: double.infinity,

                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },

                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xff0F8A4B),

                        backgroundColor: const Color(0xffF2F8F4),

                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            _expanded ? 'Hide Details' : 'View Details',

                            style: const TextStyle(
                              fontSize: 12,

                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 3),

                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),

                            turns: _expanded ? 0.5 : 0,

                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,

                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===========================================================
                  // DETAILS
                  // ===========================================================
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),

                    curve: Curves.easeInOut,

                    child: _expanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 9),

                            child: _DetailsSection(
                              item: item,

                              paymentMode: paymentMode,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;

      case 'rejected':
      case 'cancelled':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }
}

// ============================================================================
// DETAILS SECTION
// ============================================================================

class _DetailsSection extends StatelessWidget {
  final CollectionList item;

  final String paymentMode;

  const _DetailsSection({required this.item, required this.paymentMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xffF7F9F8),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xffE3E9E5)),
      ),

      child: Column(
        children: [
          _DetailRow(
            icon: Icons.storefront_outlined,

            label: 'Dealer',

            value: item.outletName,
          ),

          _DetailRow(
            icon: Icons.payments_outlined,

            label: 'Payment Mode',

            value: item.paymentMode,
          ),

          _DetailRow(
            icon: Icons.currency_rupee_rounded,

            label: 'Amount',

            value: '₹ ${item.paymentAmount}',

            valueColor: const Color(0xff0F8A4B),
          ),

          _DetailRow(
            icon: Icons.calendar_today_outlined,

            label: 'Payment Date',

            value: item.paymentDate,
          ),

          _DetailRow(
            icon: Icons.flag_outlined,

            label: 'Status',

            value: item.status,
          ),

          if (paymentMode == 'RTGS' && item.rtgsNo.isNotEmpty)
            _DetailRow(
              icon: Icons.receipt_long_outlined,

              label: 'RTGS No.',

              value: item.rtgsNo,
            ),

          if (paymentMode == 'NEFT' && item.neftNo.isNotEmpty)
            _DetailRow(
              icon: Icons.receipt_long_outlined,

              label: 'NEFT No.',

              value: item.neftNo,
            ),

          if (paymentMode == 'CHEQUE') ...[
            if (item.chequeNo.isNotEmpty && item.chequeNo != '0')
              _DetailRow(
                icon: Icons.receipt_long_outlined,

                label: 'Cheque No.',

                value: item.chequeNo,
              ),

            if (item.chequeDate.isNotEmpty && item.chequeDate != '00-00-0000')
              _DetailRow(
                icon: Icons.calendar_today_outlined,

                label: 'Cheque Date',

                value: item.chequeDate,
              ),

            if (item.bankName.isNotEmpty)
              _DetailRow(
                icon: Icons.account_balance_outlined,

                label: 'Bank',

                value: item.bankName,
              ),

            if (item.depositBankName.isNotEmpty &&
                item.depositBankName != 'SELECT DEPOSIT BANK NAME')
              _DetailRow(
                icon: Icons.account_balance_rounded,

                label: 'Deposit Bank',

                value: item.depositBankName,
              ),

            if (item.branchName.isNotEmpty)
              _DetailRow(
                icon: Icons.location_city_outlined,

                label: 'Branch',

                value: item.branchName,
              ),
          ],

          if (item.chequePassingDate != null &&
              item.chequePassingDate!.isNotEmpty)
            _DetailRow(
              icon: Icons.event_available_outlined,

              label: 'Cheque Passing',

              value: item.chequePassingDate!,
            ),

          if (item.reason != null && item.reason!.isNotEmpty)
            _DetailRow(
              icon: Icons.warning_amber_rounded,

              label: 'Reason',

              value: item.reason!,
            ),

          if (item.remark.isNotEmpty)
            _DetailRow(
              icon: Icons.notes_outlined,

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

class _DetailRow extends StatelessWidget {
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
      padding: const EdgeInsets.only(bottom: 7),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),

          const SizedBox(width: 7),

          SizedBox(
            width: 88,

            child: Text(
              label,

              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              value,

              style: TextStyle(
                fontSize: 12,

                fontWeight: FontWeight.w600,

                color: valueColor ?? const Color(0xff252A27),
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus = status.toLowerCase();

    final bool isApproved = normalizedStatus == 'approved';

    final bool isRejected =
        normalizedStatus == 'rejected' || normalizedStatus == 'cancelled';

    final Color color = isApproved
        ? Colors.green.shade700
        : isRejected
        ? Colors.red.shade700
        : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),

      decoration: BoxDecoration(
        color: color.withOpacity(0.09),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status.isEmpty ? 'Unknown' : status,

        style: TextStyle(
          color: color,

          fontSize: 9.5,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// DEALER EMPTY
// ============================================================================

class _DealerEmptyView extends StatelessWidget {
  final DealerSearchEntity? dealer;

  const _DealerEmptyView({required this.dealer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 68,

              width: 68,

              decoration: BoxDecoration(
                color: const Color(0xff0F8A4B).withOpacity(0.08),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.storefront_outlined,

                size: 33,

                color: Color(0xff0F8A4B),
              ),
            ),

            const SizedBox(height: 13),

            const Text(
              'No collection found',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 5),

            Text(
              dealer == null
                  ? 'No collection records found.'
                  : 'No collection records found for ${dealer!.outletName}.',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.account_balance_wallet_outlined,

              size: 52,

              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 12),

            const Text(
              'No collection found',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 4),

            Text(
              'Try another month or status.',

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

class _ErrorView extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.error_outline_rounded,

              size: 48,

              color: Colors.red.shade400,
            ),

            const SizedBox(height: 10),

            const Text(
              'Something went wrong',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 5),

            Text(
              message.replaceFirst('Exception: ', ''),

              textAlign: TextAlign.center,

              maxLines: 3,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 36,

              child: ElevatedButton.icon(
                onPressed: onRetry,

                icon: const Icon(Icons.refresh_rounded, size: 17),

                label: const Text('Retry'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F8A4B),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
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
