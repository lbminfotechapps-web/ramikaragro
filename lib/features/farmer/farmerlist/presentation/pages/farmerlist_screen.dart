import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

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
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CustomAppBar(
        title: 'Farmer List',
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF20382D),
        ),
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
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                child: Row(
                  children: [
                    SizedBox(height: 14.h),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: _FarmerSearchAnimation(
                              controller: _searchController,
                              builder: (context, index) => TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,

                                decoration: InputDecoration(
                                  hint: AnimatedSwitcher(
                                    duration: Duration(
                                      milliseconds:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? 0
                                          : 400,
                                    ),
                                    layoutBuilder: (child, previous) => Stack(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      children: [...previous, ?child],
                                    ),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.35),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        ),
                                    child: Text(
                                      index == 0
                                          ? 'Search farmer name'
                                          : 'Search with mobile no',
                                      key: ValueKey(index),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),

                                  prefixIcon: AnimatedSwitcher(
                                    duration: Duration(
                                      milliseconds:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? 0
                                          : 400,
                                    ),
                                    child: Icon(
                                      _searchController.text.isNotEmpty ||
                                              index == 0
                                          ? Icons.search_rounded
                                          : Icons.phone_android_rounded,
                                      key: ValueKey(
                                        _searchController.text.isNotEmpty
                                            ? 0
                                            : index,
                                      ),
                                      color: Colors.grey.shade600,
                                    ),
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

                          const SizedBox(height: 4),

                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              'Search after 3 characters. After searching wait for 2 sec..!',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
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

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          context.push('/farmerregistration');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add farmer'),
      ),
    );
  }
}

class _FarmerListItem extends StatelessWidget {
  final FarmerlistModel farmer;

  const _FarmerListItem({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final name = farmer.farmerName.trim();
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
                child: Image.asset(
                  'assets/images/farmer.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Unknown farmer' : name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18231C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.agriculture_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Farmer',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
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

          // _FarmerDetail(
          //   icon: Icons.phone_outlined,
          //   label: 'Mobile Number',
          //   text: farmer.farmerPhone.isEmpty
          //       ? 'Not available'
          //       : farmer.farmerPhone,
          // ),
          _FarmerDetail(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            text: farmer.farmerPhone.isEmpty
                ? 'Not available'
                : farmer.farmerPhone,
            onTap: farmer.farmerPhone.isEmpty
                ? null
                : () {
                    callFarmer(farmer.farmerPhone);

                    FarmerCallEvent(farmer.farmerId, farmer.farmerPhone);
                  },
          ),

          const SizedBox(height: 8),
          _FarmerDetail(
            icon: Icons.location_on_outlined,
            label: 'Address',
            text: farmer.farmerAddress.trim().isEmpty
                ? 'Address not available'
                : farmer.farmerAddress.trim(),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final call = _ActivityInfo(
                icon: Icons.phone_callback_outlined,
                title: 'Last Call',
                dateTime: farmer.lastDateTime,
              );
              final visit = _ActivityInfo(
                icon: Icons.calendar_today_outlined,
                title: 'Last Visit',
                dateTime: farmer.lastVisitDateTime,
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
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/farmerpin', extra: farmer.farmerId);
                  },
                  icon: const Icon(Icons.push_pin_outlined, size: 15),
                  label: const Text('Pin'),
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
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (farmer.farmerPhone.isNotEmpty) {
                      callFarmer(farmer.farmerPhone);
                      FarmerCallEvent(farmer.farmerId, farmer.farmerPhone);
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
                tooltip: 'Edit farmer',
                onPressed: () {
                  context.push('/farmerEdit', extra: farmer);
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

class _FarmerDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final VoidCallback? onTap;

  const _FarmerDetail({
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
            child: Icon(icon, size: 15, color: AppColors.primary),
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

class _FarmerSearchAnimation extends StatefulWidget {
  final TextEditingController controller;
  final Widget Function(BuildContext, int) builder;
  const _FarmerSearchAnimation({
    required this.controller,
    required this.builder,
  });

  @override
  State<_FarmerSearchAnimation> createState() => _FarmerSearchAnimationState();
}

class _FarmerSearchAnimationState extends State<_FarmerSearchAnimation> {
  Timer? _timer;
  int _index = 0;
  double _dragDistance = 0;

  void _advance() {
    if (!mounted ||
        widget.controller.text.isNotEmpty ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    setState(() => _index = 1 - _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _advance());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onHorizontalDragStart: widget.controller.text.isEmpty
        ? (_) => _dragDistance = 0
        : null,
    onHorizontalDragUpdate: widget.controller.text.isEmpty
        ? (details) => _dragDistance += details.delta.dx
        : null,
    onHorizontalDragEnd: widget.controller.text.isEmpty
        ? (details) {
            if (_dragDistance.abs() >= 24 ||
                (details.primaryVelocity ?? 0).abs() > 100) {
              _advance();
            }
            _dragDistance = 0;
          }
        : null,
    child: widget.builder(context, _index),
  );
}
