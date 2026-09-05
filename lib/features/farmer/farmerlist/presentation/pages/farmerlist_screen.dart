import 'dart:async';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/theme/app_theme.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_event.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const platform = MethodChannel('phone_dialer');

Future<void> callFarmer(String phone) async {
  try {
    await platform.invokeMethod('openDialer', {'phone': phone});
  } on PlatformException catch (e) {
    debugPrint('Error opening dialer: ${e.message}');
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

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD FARMERS
  // ============================================================
  void _loadFarmers({String searchKey = ''}) {
    final bool isSearching = searchKey.trim().isNotEmpty;

    final int startLimit = isSearching ? 0 : 20;

    context.read<FarmerListBloc>().add(
      FarmerListEvent(
        user_id: 4,
        currentLat: '19.96778917556256',
        currentLong: '73.77769130315075',
        startLimit: startLimit,
        searchText: searchKey,
      ),
    );
  }

  // ============================================================
  // SEARCH FARMERS
  // ============================================================
  void _searchFarmers(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadFarmers(searchKey: value.trim());
    });
  }

  // ============================================================
  // FILTER BOTTOM SHEET
  // ============================================================
  void _showFilterBottomSheet(BuildContext context) {
    final primaryColor = AppColors.gradientStartColor;

    String selectedFilter = 'All';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Filter Farmers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // FILTER TITLE
                  const Text(
                    'Farmer Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  // FILTER OPTIONS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: selectedFilter == 'All',
                        primaryColor: primaryColor,
                        onTap: () {
                          setModalState(() {
                            selectedFilter = 'All';
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Active',
                        selected: selectedFilter == 'Active',
                        primaryColor: primaryColor,
                        onTap: () {
                          setModalState(() {
                            selectedFilter = 'Active';
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Inactive',
                        selected: selectedFilter == 'Inactive',
                        primaryColor: primaryColor,
                        onTap: () {
                          setModalState(() {
                            selectedFilter = 'Inactive';
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // APPLY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        // TODO:
                        // Pass selectedFilter to your API
                        // if your FarmerListEvent supports it.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.gradientStartColor;

    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Farmer List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            context.go(AppRouter.home);
          },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: BlocBuilder<FarmerListBloc, FarmerListState>(
        builder: (context, state) {
          // ====================================================
          // LOADING
          // ====================================================
          if (state.status == FarmerlistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ====================================================
          // FAILURE
          // ====================================================
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

          // ====================================================
          // SUCCESS
          // ====================================================
          return Column(
            children: [
              // =================================================
              // SEARCH + FILTER
              // =================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    // SEARCH
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
                                      _searchController.clear();

                                      setState(() {});

                                      _loadFarmers();
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

                            _loadFarmers(searchKey: value.trim());
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // FILTER BUTTON
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                        icon: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // FARMER HEADER
              // =================================================
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

              // =================================================
              // FARMER LIST
              // =================================================
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
                          itemCount: state.farmerList.length,
                          itemBuilder: (context, index) {
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

      // ========================================================
      // ADD FARMER
      // ========================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          // TODO: Open Add Farmer screen
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

// =================================================================
// FARMER CARD (Matched to Design Reference)
// =================================================================

class _FarmerListItem extends StatelessWidget {
  final FarmerlistModel farmer;

  const _FarmerListItem({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.gradientStartColor;

    return Card(
      color: const Color(
        0xFFF7FBF7,
      ), // Soft tinted background matching reference card
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // TOP SECTION: AVATAR + NAME/PHONE/ADDRESS + STATUS
            // ===================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AVATAR IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Image.asset(
                      'assets/icons/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, color: primaryColor),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // NAME, PHONE & ADDRESS DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farmer.farmerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
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
                            farmer.farmerPhone ?? '9865473214',
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
                        farmer.farmerAddress ?? 'Address not available',
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

            // ===================================================
            // MIDDLE SECTION: LAST CALL & LAST VISIT STATS
            // ===================================================
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Call',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            farmer.lastDateTime ?? '10 : 30 AM',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // VERTICAL DIVIDER
                Container(height: 35, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 12),

                // LAST VISIT
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Visit',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            farmer.lastVisitDateTime ?? '11 : 15 AM',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===================================================
            // BOTTOM ACTION BAR (Pill Container with White Circular Buttons)
            // ===================================================
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
                      context.go('/farmerpin');
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
                            if (farmer.farmerPhone != null &&
                                farmer.farmerPhone!.isNotEmpty) {
                              callFarmer(farmer.farmerPhone!);
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

                  // EDIT BUTTON WITH WHITE CIRCLE BACKGROUND
                  InkWell(
                    onTap: () {
                      // TODO: Edit action
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

// =================================================================
// FILTER CHIP
// =================================================================

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
