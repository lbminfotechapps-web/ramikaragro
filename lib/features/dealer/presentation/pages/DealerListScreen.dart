import 'dart:async';
import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/location_util.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';
import 'package:solufine/features/dealer/data/models/DealerListModel.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DealerListScreen extends StatefulWidget {
  const DealerListScreen({super.key});

  @override
  State<DealerListScreen> createState() => _DealerListScreenState();
}

class _DealerListScreenState extends State<DealerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialLoading = true;
  Timer? _searchDebounce;

  String _searchText = '';
  bool _isLoadingMore = false;
  bool _hasMore = true;
  @override
  void initState() {
    super.initState();

    _loadDealers(searchKey: '', startLimit: 0, isLoadMore: false);

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
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadDealers(searchKey: searchText);
    });
  }

  void _loadDealers({
    String searchKey = '',
    int startLimit = 0,
    bool isLoadMore = false,
  }) async {
    // Prevent duplicate load-more calls
    if (isLoadMore && (_isLoadingMore || !_hasMore)) {
      return;
    }

    // Get user ID
    final userData = await SecureStorage.instance.getUserData();

    final int? userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      debugPrint('ERROR: Invalid user_id: ${userData?['user_id']}');
      return;
    }

    // Handle pagination
    if (isLoadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      // _startLimit = startLimit;
      _hasMore = true;
    }

    debugPrint('================================');
    debugPrint('LOAD DEALERS');
    debugPrint('================================');
    debugPrint('User ID: $userId');
    debugPrint('Search: $searchKey');
    debugPrint('Start Limit: $startLimit');
    debugPrint('Load More: $isLoadMore');
    debugPrint('================================');

    // Get current location
    String latitude = '';
    String longitude = '';

    final position = await LocationUtil.instance.getCurrentLocation();

    if (position != null) {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    }

    debugPrint('Latitude: $latitude');
    debugPrint('Longitude: $longitude');

    if (!mounted) return;

    // Call dealer API
    context.read<DealerListBloc>().add(
      DealerListEvent(
        user_id: userId.toString(),
        latitude: latitude,
        longitude: longitude,
        searchText: searchKey,
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

      appBar: CustomAppBar(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderColor),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.person_2_outlined,
              color: AppColors.textColor,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: 'Dealer List',

        showBackButton: false,
        onLogOutTap: () {
          // Handle notification tap
        },
      ),

      body: BlocConsumer<DealerListBloc, DealerListState>(
        listener: (context, state) {
          if (state.status == DealerListStatus.success ||
              state.status == DealerListStatus.failure) {
            if (mounted) {
              setState(() {
                _isInitialLoading = false;
                _isLoadingMore = false;
              });
            }
          }
        },
        builder: (context, state) {
          if (_isInitialLoading || state.status == DealerListStatus.loading) {
            return const CustomLoader();
          }

          if (state.status == DealerListStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _loadDealers(searchKey: _searchController.text.trim());
                        // _loadFarmers(searchKey: _searchController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dealers = state.dealerList;

          return Column(
            children: [
              _buildSearchBar(),

              if (dealers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 3, 16, 4),
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

              Expanded(
                child: dealers.isEmpty
                    ? _buildEmptyView()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadDealers();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
                          itemCount: dealers.length,
                          itemBuilder: (context, index) {
                            final dealer = dealers[index];

                            return _DealerListItem(dealer: dealer);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          context.push('/dealrFollowUpAdd');
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
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

                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 19),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchText.isNotEmpty ? Icons.search_off : Icons.store_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            _searchText.isNotEmpty ? 'No dealers found' : 'NO DEALERS FOUND',
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
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _DealerListItem extends StatelessWidget {
  final DealerListModel dealer;

  const _DealerListItem({required this.dealer});

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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE7F2E9),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      dealer.outletName.isEmpty
                          ? '?'
                          : dealer.outletName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF087A2F),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dealer.outletName.isEmpty
                                  ? 'Unknown Dealer'
                                  : dealer.outletName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 6,
                                  width: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00B83D),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF087A2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // MOBILE
                      if ((dealer.outletPersonMobile ?? '').isNotEmpty)
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
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
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
                    iconColor: const Color(0xFF087A2F),
                    title: 'Last Call',
                    value: _displayDate(dealer.lastDateTime),
                    subtitle: '',
                  ),
                ),

                Container(height: 38, width: 1, color: Colors.grey.shade300),

                // LAST VISIT
                Expanded(
                  child: _ActivityInfo(
                    icon: Icons.calendar_month,
                    iconColor: const Color(0xFF087A2F),
                    title: 'Last Visit',
                    value: _displayDate(dealer.lastVisitDateTime),
                    subtitle: '',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 9),
            child: Row(
              children: [
                // PIN
                //  Text( dealer.outletId),
                _CircleActionButton(
                  icon: Icons.push_pin,
                  onTap: () {
                    context.push('/dealerpin', extra: dealer.outletId);
                    print("dealerId33${dealer.outletId}");
                  },
                ),

                const SizedBox(width: 6),

                // CALL NOW
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final mobile = dealer.outletPersonMobile;
                        print("Mobile No :--- > ${mobile}");
                        if (mobile != null && mobile.isNotEmpty) {
                          callFarmer(mobile);
                          DealerCallEvent(dealer.outletId, mobile);
                        } else {
                          debugPrint('Phone number is missing');
                        }
                      },
                      icon: const Icon(Icons.phone, size: 17),
                      label: const Text(
                        'Call Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF087A2F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                _CircleActionButton(
                  icon: Icons.edit_outlined,
                  onTap: () {
                    context.push('/dealerUpdate', extra: dealer);
                    //  _showDealerDetails(context, dealer);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayDate(String? dateTime) {
    if (dateTime == null ||
        dateTime.trim().isEmpty ||
        dateTime == '0000-00-00') {
      return '--';
    }

    return dateTime;
  }

  void _callDealer(DealerListModel dealer) {
    final mobile = dealer.outletPersonMobile ?? dealer.outletMobile ?? '';

    if (mobile.isEmpty) {
      debugPrint('Dealer mobile number not available');
      return;
    }

    debugPrint('Calling dealer: $mobile');

    // Add url_launcher here if required.
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
          child: Icon(icon, color: iconColor, size: 18),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
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
                style: const TextStyle(fontSize: 8, color: Color(0xFF087A2F)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

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
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 17, color: const Color(0xFF087A2F)),
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

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> DealerCallEvent(String fldFarmerId, String fldMobileNo) async {
  final url = ApiClient.baseUrl + ApiClient.famerCallApi;
  final userData = await SecureStorage.instance.getUserData();

  final id = userData?['user_id']?.toString();

  try {
    final response = await http.post(
      Uri.parse(url),

      body: {
        "strUserId": id.toString(),

        "strCallToId": fldFarmerId,

        "strMobNo": fldMobileNo,

        "strType": "Dealer",

        "strTime": getCurrentTime(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == true) {
        debugPrint("Call Event Success");
      }
    }
  } catch (e) {
    debugPrint("Call Event Error: $e");
  }
}

String getCurrentTime() {
  final now = DateTime.now();

  int hour = now.hour;

  final minute = now.minute;

  String period = "AM";

  if (hour >= 12) {
    period = "PM";

    if (hour > 12) {
      hour -= 12;
    }
  }

  if (hour == 0) {
    hour = 12;
  }

  final formattedHour = hour.toString().padLeft(2, '0');

  final formattedMinute = minute.toString().padLeft(2, '0');

  return "$formattedHour:"
      "$formattedMinute "
      "$period";
}

Future<void> callFarmer(String phone) async {
  final phoneUri = Uri(scheme: 'tel', path: phone);

  if (!await canLaunchUrl(phoneUri)) {
    debugPrint('Unable to open dialer for phone number: $phone');
    return;
  }

  final launched = await launchUrl(
    phoneUri,
    mode: LaunchMode.externalApplication,
  );

  if (!launched) {
    debugPrint('Failed to open dialer for phone number: $phone');
  }
}
