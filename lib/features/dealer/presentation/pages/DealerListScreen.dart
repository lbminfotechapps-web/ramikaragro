import 'dart:async';

import 'package:demo/features/dealer/data/models/DealerListModel.dart';
import 'package:demo/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:demo/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:demo/features/dealer/presentation/bloc/dealerlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/DealerListModel.dart';
import '../bloc/dealerlist_bloc.dart';

class DealerListScreen extends StatefulWidget {
  const DealerListScreen({super.key});

  @override
  State<DealerListScreen> createState() => _DealerListScreenState();
}

class _DealerListScreenState extends State<DealerListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    // Initial API call
    _loadDealers();

    // Listen for search changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // SEARCH CHANGE
  // =========================================================

  void _onSearchChanged() {
    final searchText = _searchController.text.trim();

    setState(() {
      _searchText = searchText;
    });

    // Cancel previous timer
    _searchDebounce?.cancel();

    // Wait 500 ms before calling API
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _loadDealers(
          searchText: searchText,
        );
      },
    );
  }

  // =========================================================
  // LOAD DEALERS
  // =========================================================

  void _loadDealers({
    String? searchText,
  }) {
    final search = searchText ?? _searchController.text.trim();

    context.read<DealerListBloc>().add(
          DealerListEvent(
            user_id: '4',
            latitude: '19.9675697',
            longitude: '73.7774614',
            searchText: search,
            type: 'Dealer',
          ),
        );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Dealer List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: BlocBuilder<DealerListBloc, DealerListState>(
        builder: (context, state) {
          // -------------------------------------------------
          // LOADING
          // -------------------------------------------------

          if (state.status == DealerListStatus.loading) {
            return Column(
              children: [
                _buildSearchBar(),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }

          // -------------------------------------------------
          // FAILURE
          // -------------------------------------------------

          if (state.status == DealerListStatus.failure) {
            return Column(
              children: [
                _buildSearchBar(),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.redAccent,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            state.errorMessage ??
                                'Something went wrong',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              _loadDealers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // -------------------------------------------------
          // API RESPONSE
          // -------------------------------------------------

          final dealers = state.dealerList;

          // -------------------------------------------------
          // MAIN CONTENT
          // -------------------------------------------------

          return Column(
            children: [
              // =================================================
              // SEARCH BAR
              // =================================================

              _buildSearchBar(),

              // =================================================
              // DEALER COUNT
              // =================================================

              if (dealers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    3,
                    16,
                    4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${dealers.length} Dealers',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // =================================================
              // LIST
              // =================================================

              Expanded(
                child: dealers.isEmpty
                    ? _buildEmptyView()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadDealers();
                        },
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            6,
                            12,
                            20,
                          ),
                          itemCount: dealers.length,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final dealer = dealers[index];

                            return _DealerListItem(
                              dealer: dealer,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),

      // =====================================================
      // FLOATING BUTTON
      // =====================================================

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF087A2F),
        onPressed: () {
          _loadDealers();
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by name, mobile...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),

                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),

                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 19,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,

                  border: InputBorder.none,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // =================================================
          // FILTER BUTTON
          // =================================================

        
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY VIEW
  // =========================================================

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchText.isNotEmpty
                ? Icons.search_off
                : Icons.store_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            _searchText.isNotEmpty
                ? 'No dealers found'
                : 'NO DEALERS FOUND',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (_searchText.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Try another search',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// DEALER CARD
// =================================================================

class _DealerListItem extends StatelessWidget {
  final DealerListModel dealer;

  const _DealerListItem({
    required this.dealer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===================================================
          // TOP DEALER INFORMATION
          // ===================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              8,
              8,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =================================================
                // DEALER INITIAL
                // =================================================

                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE7F2E9),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dealer.outletName.isEmpty
                          ? '?'
                          : dealer.outletName[0]
                              .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF087A2F),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // NAME + MOBILE + ADDRESS
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dealer.outletName.isEmpty
                                  ? 'Unknown Dealer'
                                  : dealer.outletName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // ACTIVE
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFE8F7EC),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Container(
                                  height: 6,
                                  width: 6,
                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Color(0xFF00B83D),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        Color(0xFF087A2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // MOBILE
                      if ((dealer.outletPersonMobile ??
                              '')
                          .isNotEmpty)
                        Text(
                          dealer.outletPersonMobile!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),

                      const SizedBox(height: 2),

                      // ADDRESS
                      Text(
                        dealer.outletAddress.isEmpty
                            ? 'Address not available'
                            : dealer.outletAddress,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // MORE BUTTON
                // =================================================

                // IconButton(
                //   padding: EdgeInsets.zero,
                //   constraints:
                //       const BoxConstraints(),
                //   onPressed: () {
                //     // _showDealerMenu(
                //     //   context,
                //     //   dealer,
                //     // );
                //   },
                //   icon: const Icon(
                //     Icons.more_vert,
                //     size: 20,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),

          // ===================================================
          // LAST CALL / LAST VISIT
          // ===================================================

          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 9,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // LAST CALL
                Expanded(
                  child: _ActivityInfo(
                    icon: Icons.phone,
                    iconColor:
                        const Color(0xFF087A2F),
                    title: 'Last Call',
                    value: _displayDate(
                      dealer.lastDateTime,
                    ),
                    subtitle: 'Today',
                  ),
                ),

                Container(
                  height: 38,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                // LAST VISIT
                Expanded(
                  child: _ActivityInfo(
                    icon: Icons.calendar_month,
                    iconColor:
                        const Color(0xFF087A2F),
                    title: 'Last Visit',
                    value: _displayDate(
                      dealer.lastVisitDateTime,
                    ),
                    subtitle: 'Today',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ===================================================
          // BOTTOM ACTION BAR
          // ===================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              0,
              8,
              9,
            ),
            child: Row(
              children: [
                // PIN
                _CircleActionButton(
                  icon: Icons.push_pin,
                  onTap: () {
                    context.go('/farmerpin', extra: dealer.outletId);
                  },
                ),

                const SizedBox(width: 6),

                // CALL NOW
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _callDealer(dealer);
                      },
                      icon: const Icon(
                        Icons.phone,
                        size: 17,
                      ),
                      label: const Text(
                        'Call Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF087A2F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // INFO
                _CircleActionButton(
                  icon: Icons.info_outline,
                  onTap: () {
                    _showDealerDetails(
                      context,
                      dealer,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DISPLAY DATE
  // ===========================================================

  String _displayDate(String? dateTime) {
    if (dateTime == null ||
        dateTime.trim().isEmpty ||
        dateTime == '0000-00-00') {
      return '--';
    }

    return dateTime;
  }

  // ===========================================================
  // CALL DEALER
  // ===========================================================

  void _callDealer(DealerListModel dealer) {
    final mobile =
        dealer.outletPersonMobile ??
        dealer.outletMobile ??
        '';

    if (mobile.isEmpty) {
      debugPrint(
        'Dealer mobile number not available',
      );
      return;
    }

    debugPrint(
      'Calling dealer: $mobile',
    );

    // Add url_launcher here if required.
  }

  // ===========================================================
  // MENU
  // ===========================================================

  // void _showDealerMenu(
  //   BuildContext context,
  //   DealerListModel dealer,
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(20),
  //       ),
  //     ),
  //     builder: (context) {
  //       return SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.info_outline,
  //               ),
  //               title: const Text(
  //                 'Dealer Details',
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);

  //                 _showDealerDetails(
  //                   context,
  //                   dealer,
  //                 );
  //               },
  //             ),

  //             ListTile(
  //               leading: const Icon(
  //                 Icons.location_on_outlined,
  //               ),
  //               title: const Text(
  //                 'View Location',
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),

  //             ListTile(
  //               leading: const Icon(
  //                 Icons.phone_outlined,
  //               ),
  //               title: const Text(
  //                 'Call Dealer',
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);

  //                 _callDealer(dealer);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // ===========================================================
  // DEALER DETAILS
  // ===========================================================

  void _showDealerDetails(
    BuildContext context,
    DealerListModel dealer,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  dealer.outletName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _DetailRow(
                  label: 'Person',
                  value: dealer.outletPerson,
                ),

                _DetailRow(
                  label: 'Mobile',
                  value:
                      dealer.outletPersonMobile ??
                          '--',
                ),

                _DetailRow(
                  label: 'Address',
                  value:
                      dealer.outletAddress,
                ),

                _DetailRow(
                  label: 'Type',
                  value:
                      dealer.outletType ?? '--',
                ),

                _DetailRow(
                  label: 'Distance',
                  value:
                      dealer.outletDistance ?? '--',
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =================================================================
// ACTIVITY INFO
// =================================================================

class _ActivityInfo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _ActivityInfo({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFE1F2E5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF087A2F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// CIRCLE ACTION BUTTON
// =================================================================

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: const Color(0xFF087A2F),
        ),
      ),
    );
  }
}

// =================================================================
// DETAIL ROW
// =================================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}