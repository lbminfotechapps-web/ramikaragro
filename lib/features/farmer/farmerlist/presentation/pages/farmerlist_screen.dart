import 'dart:async';
import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';

import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';
import 'package:solufine/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:solufine/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
import 'package:solufine/features/farmer/farmerlist/presentation/bloc/farmerlist_event.dart';
import 'package:solufine/features/farmer/farmerlist/presentation/bloc/farmerlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

class FarmerlistScreen extends StatefulWidget {
  const FarmerlistScreen({super.key});

  @override
  State<FarmerlistScreen> createState() => _FarmerlistScreenState();
}

class _FarmerlistScreenState extends State<FarmerlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  final ScrollController _scrollController = ScrollController();
  int _startLimit = 0;
  static const int _pageSize = 20;

  bool _isLoadingMore = false;
  bool _hasMore = true;

  String _currentSearchKey = '';

  String userId = '';
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _loadFarmers(searchKey: '', startLimit: 0, isLoadMore: false);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFarmers({
    String searchKey = '',
    int startLimit = 0,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore && (_isLoadingMore || !_hasMore)) {
      return;
    }
    final userData = await SecureStorage.instance.getUserData();
    int? userId = int.tryParse(userData?['user_id']?.toString() ?? '');
    if (userId == null) {
      debugPrint('ERROR: Invalid user_id: ${userData?['user_id']}');
      return;
    }
    if (isLoadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      _startLimit = startLimit;
      _hasMore = true;
    }
    debugPrint('================================');
    debugPrint('LOAD FARMERS');
    debugPrint('================================');
    debugPrint('User ID: $userId');
    debugPrint('Search: $searchKey');
    debugPrint('Start Limit: $startLimit');
    debugPrint('Load More: $isLoadMore');
    debugPrint('================================');
    if (!mounted) return;
    context.read<FarmerListBloc>().add(
      FarmerListEvent(
        user_id: userId,
        startLimit: startLimit,
        searchText: searchKey,
      ),
    );
  }

  void _searchFarmers(String value) {
    _searchTimer?.cancel();

    final searchKey = value.trim();

    _searchTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;

      _currentSearchKey = searchKey;

      _startLimit = 0;
      _hasMore = true;

      _loadFarmers(
        searchKey: _currentSearchKey,
        startLimit: 0,
        isLoadMore: false,
      );
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      if (_isLoadingMore || !_hasMore) {
        return;
      }

      final nextLimit = _startLimit + 20;
      _startLimit = nextLimit;

      _loadFarmers(
        searchKey: _currentSearchKey,
        startLimit: nextLimit,
        isLoadMore: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.gradientStartColor;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: 'Farmer List',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: BlocBuilder<FarmerListBloc, FarmerListState>(
        builder: (context, state) {
          if (state.status == FarmerlistStatus.loading) {
            return const CustomLoader();
          }

          if (state.status == FarmerlistStatus.failure) {
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
                        _loadFarmers(searchKey: _searchController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    SizedBox(height: 14.h),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search farmer...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchTimer?.cancel();

                                      _searchController.clear();

                                      setState(() {
                                        _startLimit = 0;
                                        _hasMore = true;
                                      });

                                      _loadFarmers(
                                        searchKey: '',
                                        startLimit: 0,
                                        isLoadMore: false,
                                      );
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            _searchFarmers(value);
                          },
                          onSubmitted: (value) {
                            _searchTimer?.cancel();
                            _startLimit = 0;
                            _hasMore = true;
                            _loadFarmers(
                              searchKey: value.trim(),
                              startLimit: 0,
                              isLoadMore: false,
                            );
                          },
                        ),
                      ),
                    ),

                    // const SizedBox(width: 10),

                    // Container(
                    //   width: 48,
                    //   height: 48,
                    //   decoration: BoxDecoration(
                    //     color: primaryColor,
                    //     borderRadius: BorderRadius.circular(14),
                    //   ),
                    //   child: IconButton(
                    //     onPressed: () {
                    //       _showFilterBottomSheet(context);
                    //     },
                    //     icon: const Icon(Icons.tune, color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Farmers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.farmerList.length} Records',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: state.farmerList.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          _loadFarmers(
                            searchKey: _searchController.text.trim(),
                          );
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 180),
                            Center(
                              child: Text(
                                'NO RECORDS FOUND',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadFarmers(
                            searchKey: _searchController.text.trim(),
                          );
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount:
                              state.farmerList.length +
                              (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.farmerList.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final farmer = state.farmerList[index];

                            return _FarmerListItem(farmer: farmer);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          context.push('/farmerregistration');
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

class _FarmerListItem extends StatelessWidget {
  final FarmerlistModel farmer;

  const _FarmerListItem({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.gradientStartColor;

    return Card(
      color: const Color(0xFFF7FBF7),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Container(
                      color: primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.agriculture,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farmer.farmerName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // STATUS PILL (Top Right)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "Active",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // PHONE NUMBER ROW
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            farmer.farmerPhone,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // ADDRESS
                      Text(
                        farmer.farmerAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 12),

            Row(
              children: [
                // LAST CALL
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_callback_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Call',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              farmer.lastDateTime ?? '10 : 30 AM',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(height: 35, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 12),

                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Visit',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              farmer.lastVisitDateTime ?? '11 : 15 AM',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: primaryColor, // Deep green wrapper container
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PIN BUTTON WITH WHITE CIRCLE BACKGROUND
                  InkWell(
                    onTap: () {
                      // print('farmer pin clickkkk');
                      context.push('/farmerpin', extra: farmer.farmerId);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.push_pin_outlined,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ),

                  // MAIN CALL NOW BUTTON (White Pill Background)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (farmer.farmerPhone.isNotEmpty) {
                              callFarmer(farmer.farmerPhone);
                              FarmerCallEvent(
                                farmer.farmerId,
                                farmer.farmerPhone,
                              );
                            } else {
                              debugPrint('Phone number is missing');
                            }
                          },
                          icon: Icon(
                            Icons.call_outlined,
                            size: 16,
                            color: primaryColor,
                          ),
                          label: Text(
                            'Call Now',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      context.push('/farmerEdit', extra: farmer);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: primaryColor,
                        size: 18,
                      ),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

Future<void> FarmerCallEvent(String fldFarmerId, String fldMobileNo) async {
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

        "strType": "Farmer",

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
