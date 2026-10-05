import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/location_tracking/location_repository.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/device_info_util.dart';
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
  String? _currentLatitude;
  String? _currentLongitude;
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

    if (searchText.isNotEmpty && searchText.length < 3) return;
    _searchDebounce = Timer(const Duration(seconds: 2), () {
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
    if (!mounted) return;

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

    if (searchKey != _searchController.text.trim()) return;
    setState(() {
      _currentLatitude = position != null ? latitude : null;
      _currentLongitude = position != null ? longitude : null;
    });

    // Call dealer API
    context.read<DealerListBloc>().add(
      DealerListEvent(
        user_id: userId.toString(),
        latitude: latitude,
        longitude: longitude,
        searchText: searchKey,
        type: 'Dealer',
        startLimit: 0,
      ),
    );
  }

  Future<void> _submitDealerLocation(DealerListModel dealer) async {
    try {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('UPDATE DEALER LOCATION');
      debugPrint('========================================');

      // ============================================================
      // 1. DEALER ID
      // ============================================================

      final String dealerId = dealer.outletId?.toString().trim() ?? '';

      // if (dealerId.isEmpty || dealerId == '0') {
      //   _showError('Dealer ID is not available');
      //   return;
      // }

      // ============================================================
      // 2. GET USER ID
      // ============================================================

      final userData = await SecureStorage.instance.getUserData();

      final String userId = userData?['user_id']?.toString().trim() ?? '';

      // if (userId.isEmpty || userId == '0') {
      //   _showError('User ID is not available');
      //   return;
      // }

      // ============================================================
      // 3. GET FRESH CURRENT LOCATION
      // ============================================================

      final position = await LocationUtil.instance.getCurrentLocation();

      // if (position == null) {
      //   _showError(
      //     'Unable to get current location. Please try again.',
      //   );
      //   return;
      // }

      final String latitude = position!.latitude.toString();

      final String longitude = position.longitude.toString();

      final String accuracy = position.accuracy.toString();

      debugPrint('Current Latitude  : $latitude');
      debugPrint('Current Longitude : $longitude');
      debugPrint('Accuracy          : $accuracy');

      // ============================================================

      final String networkLatitude = latitude;
      final String networkLongitude = longitude;

      final String gpsLatitude = latitude;
      final String gpsLongitude = longitude;

      // ============================================================
      // 5. GET ADDRESS
      // ============================================================

      String geoAddress = '';

      try {
        geoAddress = await LocationUtil.instance.getAddress(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        debugPrint('GET ADDRESS ERROR: $e');
      }

      // ============================================================
      // 6. DEVICE INFORMATION
      // ============================================================

      String strNetworkInfo = '';
      String strBatteryInfo = '';

      try {
        strNetworkInfo = await DeviceInfoUtil.instance.getNetworkInfo();
      } catch (e) {
        debugPrint('NETWORK INFO ERROR: $e');
      }

      try {
        strBatteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();
      } catch (e) {
        debugPrint('BATTERY INFO ERROR: $e');
      }

      // ============================================================
      // 7. LOCATION HISTORY
      // ============================================================

      String locationHistoryString = '';

      try {
        final int parsedUserId = int.tryParse(userId) ?? 0;

        if (parsedUserId > 0) {
          final locationRepository = sl<LocationRepository>();

          final locations = await locationRepository.getAllLocations(
            parsedUserId,
          );

          final List<Map<String, dynamic>> history = locations.map((location) {
            return {
              'latitude': location.latitude,
              'longitude': location.longitude,
              'time': location.capturedAt,
              'accuracy': location.accuracy,
              'provider': location.provider,
              'address': location.geoAddress,
              'distance': location.distance,
            };
          }).toList();

          locationHistoryString = jsonEncode(history);
        }
      } catch (e) {
        debugPrint('LOCATION HISTORY ERROR: $e');
      }

      // ============================================================
      // 8. PRINT FINAL DATA
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('DEALER LOCATION FINAL DATA');
      debugPrint('========================================');

      debugPrint('Dealer ID          : $dealerId');
      debugPrint('User ID            : $userId');

      debugPrint('Latitude           : $latitude');
      debugPrint('Longitude          : $longitude');

      debugPrint('Network Latitude   : $networkLatitude');
      debugPrint('Network Longitude  : $networkLongitude');

      debugPrint('GPS Latitude       : $gpsLatitude');
      debugPrint('GPS Longitude      : $gpsLongitude');

      debugPrint('Geo Address        : $geoAddress');

      debugPrint('Network Info       : $strNetworkInfo');
      debugPrint('Battery Info       : $strBatteryInfo');

      debugPrint('Location History   : $locationHistoryString');

      debugPrint('========================================');

      if (!mounted) return;

      // ============================================================
      // 9. CALL BLOC
      // ============================================================

      context.read<DealerListBloc>().add(
        AddDealerLocation(
          dealerId: dealerId,
          userId: userId,

          locationHistoryString: locationHistoryString,

          latitude: latitude,
          longitude: longitude,

          networkLatitude: networkLatitude,
          networkLongitude: networkLongitude,

          gpsLatitude: gpsLatitude,
          gpsLongitude: gpsLongitude,

          geoAddress: geoAddress,

          mobileInfo: '',
          mobileImei: '',

          networkInfo: strNetworkInfo,
          batteryInfo: strBatteryInfo,
        ),
      );

      debugPrint('ADD DEALER LOCATION EVENT SENT');
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('UPDATE DEALER LOCATION ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      // _showError(
      //   'Unable to update dealer location. Please try again.',
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: 'Dealer List',
          showBackButton: true,
          onBackTap: () => context.go('/home'),
        ),

        body: Column(
          children: [
            _buildSearchBar(),
            _buildLocationRow(),

            Expanded(
              child: BlocConsumer<DealerListBloc, DealerListState>(
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
                  // ============================================================
                  // ADD DEALER LOCATION SUCCESS
                  // ============================================================

                  if (state.status ==
                      DealerListStatus.addDealerLocationSuccess) {
                    debugPrint('DEALER LOCATION UPDATED SUCCESSFULLY');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dealer location updated successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Refresh dealer list after location update
                    _loadDealers(searchKey: _searchController.text.trim());
                  }

                  //
                },
                builder: (context, state) {
                  if (_isInitialLoading ||
                      state.status == DealerListStatus.loading) {
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
                                _loadDealers(
                                  searchKey: _searchController.text.trim(),
                                );
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _searchText.isEmpty
                                    ? 'Your dealers'
                                    : 'Search results',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: Color(0xFF203C32),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1E9DF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${dealers.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B5D4A),
                                ),
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    104,
                                  ),
                                  itemCount: dealers.length,
                                  itemBuilder: (context, index) {
                                    final dealer = dealers[index];

                                    return _DealerListItem(
                                      dealer: dealer,
                                      onLocationTap: () {
                                        _submitDealerLocation(dealer);
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          onPressed: () {
            context.push('/dealrFollowUpAdd');
          },
          tooltip: 'Add dealer follow-up',
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Dealer'),
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    final latitude = double.tryParse(_currentLatitude ?? '');
    final longitude = double.tryParse(_currentLongitude ?? '');
    final hasLocation = latitude != null && longitude != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDCE8DF)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.my_location_rounded,
              size: 13,
              color: Color(0xFF3B5D4A),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                hasLocation
                    ? 'Lat ${latitude.toStringAsFixed(5)}   |   Lng ${longitude.toStringAsFixed(5)}'
                    : 'Location unavailable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B5D4A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      decoration: const BoxDecoration(
        // color: Color(0xFF123D32),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),

      // child: TextField(
      //   controller: _searchController,
      //   textInputAction: TextInputAction.search,
      //   style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      //   decoration: InputDecoration(
      //     hintText: 'Search name or mobile number',
      //     hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      //     filled: true,
      //     fillColor: Colors.white,
      //     prefixIcon: const Icon(
      //       Icons.search_rounded,
      //       color: AppColors.primaryLight,
      //     ),
      //     suffixIcon: _searchController.text.isNotEmpty
      //         ? IconButton(
      //             tooltip: 'Clear search',
      //             icon: const Icon(Icons.close_rounded, size: 20),
      //             onPressed: _searchController.clear,
      //           )
      //         : null,
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(16),
      //       borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
      //     ),
      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(16),
      //       borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(16),
      //       borderSide: const BorderSide(color: AppColors.primaryLight),
      //     ),
      //     contentPadding: const EdgeInsets.symmetric(
      //       horizontal: 16,
      //       vertical: 16,
      //     ),
      //   ),
      // ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Search name or mobile number',
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryLight,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: _searchController.clear,
                )
              : null,

          helperText:
              'Search after 3 characters. After searching wait for 2 sec..!',
          helperStyle: const TextStyle(
            fontSize: 10,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E8E2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryLight),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
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
            'No Dealers Found..!',
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
  final VoidCallback onLocationTap;

  const _DealerListItem({required this.dealer, required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    final name = dealer.outletName.trim();
    final mobile = dealer.outletPersonMobile?.trim() ?? '';
    final person = dealer.outletPerson.trim();
    final latitude = double.tryParse(dealer.latitude ?? '0') ?? 0;
    final longitude = double.tryParse(dealer.longitude ?? '0') ?? 0;
    final locationNotAvailable = latitude == 0 && longitude == 0;
    final outletDistance = double.tryParse(dealer.outletDistance ?? '');
    final definedRadius = double.tryParse(dealer.definedRadius ?? '');
    final showPin =
        outletDistance != null &&
        definedRadius != null &&
        outletDistance < definedRadius;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06123D32),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAF2EC), width: 3),
                ),
                child: Center(
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Unknown dealer' : name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18231C),
                      ),
                    ),
                  
                    const SizedBox(height: 4),

                   
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            // 'Lat: ${dealer.latitude}  Long: ${dealer.longitude}',
                            'Lat: ${dealer.latitude}  Long: ${dealer.longitude}  (${dealer.outletDistance})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0F1EF)),
          ),


         
            _DealerDetail(
              icon: Icons.phone_outlined,
              label: 'Mobile Number',
              text: mobile.isEmpty
                  ? 'Not available'
                  : mobile,
              onTap: mobile.isEmpty
                  ? null
                  : () {
                      callFarmer(mobile);
                    },
            ),
           


          const SizedBox(height: 8),
          _DealerDetail(
            icon: Icons.location_on_outlined,
            label: 'Address',
            text: dealer.outletAddress.trim().isEmpty
                ? 'Address not available'
                : dealer.outletAddress.trim(),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final call = _ActivityInfo(
                icon: Icons.phone_callback_outlined,
                title: 'Last Call',
                dateTime: dealer.lastDateTime,
              );
              final visit = _ActivityInfo(
                icon: Icons.calendar_today_outlined,
                title: 'Last Visit',
                dateTime: dealer.lastVisitDateTime,
              );
              if (constraints.maxWidth < 240 ||
                  MediaQuery.textScalerOf(context).scale(11) > 18) {
                return Column(
                  children: [call, const SizedBox(height: 6), visit],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: call),
                  const SizedBox(width: 8),
                  Expanded(child: visit),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (locationNotAvailable || showPin)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: locationNotAvailable
                        ? onLocationTap
                        : () {
                            context.push('/dealerpin', extra: dealer.outletId);
                          },
                    icon: Icon(
                      locationNotAvailable
                          ? Icons.add_location_alt_outlined
                          : Icons.push_pin_outlined,
                      size: 15,
                    ),
                    label: Text(locationNotAvailable ? 'LOC' : 'Pin'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: shape,
                    ),
                  ),
                ),
              if (locationNotAvailable || showPin) const SizedBox(width: 6),
              Expanded(
                child: FilledButton.icon(
                  onPressed: mobile.isEmpty
                      ? null
                      : () {
                          if (mobile.isNotEmpty) {
                            callFarmer(mobile);
                            DealerCallEvent(dealer.outletId, mobile);
                          } else {
                            debugPrint('Phone number is missing');
                          }
                        },
                  icon: const Icon(Icons.call_outlined, size: 15),
                  label: const Text('Call'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF123D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: shape,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                tooltip: 'Edit dealer',
                onPressed: () {
                  context.push('/dealerUpdate', extra: dealer);
                },
                icon: const Icon(Icons.edit_outlined, size: 17),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(38, 36),
                  shape: shape,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class _DealerDetail extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String text;
//   const _DealerDetail({
//     required this.icon,
//     required this.label,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 28,
//           height: 28,
//           decoration: BoxDecoration(
//             color: const Color(0xFFEDF5EF),
//             borderRadius: BorderRadius.circular(7),
//           ),
//           child: Icon(icon, size: 15, color: AppColors.primary),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 9,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 text,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   height: 1.25,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF18231C),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


class _DealerDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final VoidCallback? onTap;

  const _DealerDetail({
    required this.icon,
    required this.label,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5EF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: onTap != null
                        ? AppColors.primary
                        : const Color(0xFF18231C),
                    decoration: onTap != null
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? dateTime;
  const _ActivityInfo({
    required this.icon,
    required this.title,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final raw = dateTime?.trim() ?? '';
    final missing = raw.isEmpty || raw.startsWith('0000-00-00');
    final parsed = missing ? null : DateTime.tryParse(raw);
    final value = missing
        ? 'Not recorded'
        : parsed == null
        ? raw
        : DateFormat('dd MMM yyyy').format(parsed);
    final time = parsed != null && raw.contains(RegExp(r'[T ]\d{2}:\d{2}'))
        ? DateFormat('h:mm a').format(parsed)
        : null;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                if (time != null)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
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
