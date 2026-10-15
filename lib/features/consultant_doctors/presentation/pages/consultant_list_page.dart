import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/consultant_doctor.dart';
import '../bloc/consultant_bloc.dart';

class ConsultantListPage extends StatefulWidget {
  const ConsultantListPage({super.key});

  @override
  State<ConsultantListPage> createState() => _ConsultantListPageState();
}

class _ConsultantListPageState extends State<ConsultantListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _userId = '';
  String _pageError = '';
  bool _initializing = true;

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  // ========================================================
  // INIT
  // ========================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeList();
      }
    });
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ========================================================
  // FETCH LOGGED IN USER ID
  // ========================================================

  Future<String> _getUserId() async {
    final userData = await SecureStorage.instance.getUserData();

    return (userData?['user_id'] ?? userData?['userId'] ?? '')
        .toString()
        .trim();
  }

  // ========================================================
  // INITIAL LOAD
  // ========================================================

  Future<void> _initializeList() async {
    if (!mounted) return;

    setState(() {
      _initializing = true;
      _pageError = '';
    });

    try {
      final userId = await _getUserId();

      if (!mounted) return;

      if (userId.isEmpty || userId == '0') {
        setState(() {
          _initializing = false;
          _pageError = 'Please log in again.';
        });
        return;
      }

      _userId = userId;

      debugPrint('CONSULTANT USER ID: $_userId');

      setState(() {
        _initializing = false;
      });

      context.read<ConsultantBloc>().add(LoadConsultants(userId: _userId));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _initializing = false;
        _pageError = error.toString();
      });
    }
  }

  // ========================================================
  // REFRESH
  // ========================================================

  void _refreshList() {
    if (_userId.isEmpty) {
      _initializeList();
      return;
    }

    context.read<ConsultantBloc>().add(LoadConsultants(userId: _userId));
  }

  Future<void> _pullToRefresh() async {
    if (_userId.isEmpty) {
      await _initializeList();
      return;
    }

    final bloc = context.read<ConsultantBloc>();

    final nextResult = bloc.stream.firstWhere(
      (state) =>
          state.status == ConsultantStatus.success ||
          state.status == ConsultantStatus.failure,
    );

    bloc.add(LoadConsultants(userId: _userId));

    await nextResult;
  }

  // ========================================================
  // ADD / EDIT NAVIGATION
  // ========================================================

  Future<void> _openForm([ConsultantDoctor? doctor]) async {
    try {
      final saved = await context.pushNamed<bool>(
        'consultantDoctorForm',
        extra: doctor,
      );

      if (!mounted) return;

      if (saved == true) {
        _refreshList();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open Consultant Form: $error')),
      );
    }
  }

  // ========================================================
  // CLIENT-SIDE SEARCH OVER API RESULTS
  // ========================================================

  List<ConsultantDoctor> _filterDoctors(List<ConsultantDoctor> doctors) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return doctors;

    return doctors.where((doctor) {
      final searchable = [
        doctor.doctorName,
        doctor.ownerName,
        doctor.mobile,
        doctor.address,
        doctor.stateName,
        doctor.districtName,
        doctor.talukaName,
        doctor.remark,
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  String _initials(String name) {
    final words = name
        .replaceFirst(RegExp(r'^(dr\.?|doctor)\s+', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'DR';

    if (words.length == 1) {
      final word = words.first;

      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  // ========================================================
  // HEADER
  // ========================================================

  Widget _buildHeader(int count) {
    final primary = context.appPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              color: primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Network',
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Consultants from server',
                  style: TextStyle(color: context.appSubText, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: context.appCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.appBorder),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(color: context.appSubText, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // SEARCH
  // ========================================================

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: context.appInputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: context.appInputText, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search doctor, owner, mobile...',
          hintStyle: TextStyle(color: context.appSubText, fontSize: 12),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.appPrimary,
            size: 20,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  onPressed: _searchController.clear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.appSubText,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ========================================================
  // CONSULTANT CARD
  // ========================================================

  Widget _buildConsultantCard(ConsultantDoctor doctor) {
    final primary = context.appPrimary;

    final location = [
      doctor.talukaName,
      doctor.districtName,
      doctor.stateName,
    ].where((text) => text.trim().isNotEmpty).join(', ');

    return Material(
      color: context.appCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openForm(doctor),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 43,
                    width: 43,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _initials(doctor.doctorName),
                      style: TextStyle(
                        color: primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Owner: ${doctor.ownerName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appSubText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.appSubText,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(height: 1, color: context.appBorder),
              const SizedBox(height: 9),

              Row(
                children: [
                  Icon(Icons.phone_outlined, color: primary, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    doctor.mobile,
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: primary,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location.isEmpty ? 'Location not set' : location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: context.appSubText,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (doctor.remark.trim().isNotEmpty) ...[
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    doctor.remark,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.appSubText, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================
  // MESSAGE / EMPTY / ERROR
  // ========================================================

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onAction,
    String actionLabel = 'Refresh',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: context.appPrimary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appSubText, fontSize: 12),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // CONTENT
  // ========================================================

  Widget _buildContent(ConsultantState state) {
    final doctors = state.doctors;
    final filteredDoctors = _filterDoctors(doctors);

    final loading =
        _initializing ||
        state.status == ConsultantStatus.initial ||
        state.status == ConsultantStatus.loading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Column(
            children: [
              _buildHeader(doctors.length),
              const SizedBox(height: 11),
              _buildSearchBar(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'All Consultants',
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredDoctors.length}',
                    style: TextStyle(
                      color: context.appPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh Consultants',
                    onPressed: _refreshList,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: context.appPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _pageError.isNotEmpty
              ? _buildMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load consultants',
                  description: _pageError,
                  onAction: _initializeList,
                  actionLabel: 'Try Again',
                )
              : loading
              ? Center(
                  child: CircularProgressIndicator(color: context.appPrimary),
                )
              : state.status == ConsultantStatus.failure
              ? _buildMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Doctor API Error',
                  description: state.message,
                  onAction: _refreshList,
                  actionLabel: 'Try Again',
                )
              : filteredDoctors.isEmpty
              ? _buildMessage(
                  icon: _isSearching
                      ? Icons.search_off_rounded
                      : Icons.medical_services_outlined,
                  title: _isSearching
                      ? 'No Matching Consultants'
                      : 'No Consultants Found',
                  description: _isSearching
                      ? 'Try a different search.'
                      : 'No records returned by the server.',
                  onAction: _isSearching
                      ? _searchController.clear
                      : _refreshList,
                  actionLabel: _isSearching ? 'Clear Search' : 'Refresh',
                )
              : RefreshIndicator(
                  color: context.appPrimary,
                  onRefresh: _pullToRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 2, 14, 16),
                    itemCount: filteredDoctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      return _buildConsultantCard(filteredDoctors[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ========================================================
  // BOTTOM ADD BUTTON
  // ========================================================

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 11),
        decoration: BoxDecoration(
          color: context.appCard,
          border: Border(top: BorderSide(color: context.appBorder)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SizedBox(
              width: double.infinity,
              height: 47,
              child: ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Add Consultant Doctor',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(AppRouter.home),
        ),
        title: 'Consultant Doctors',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        actionIcon: Icons.refresh_rounded,
        onActionIconTap: _refreshList,
      ),

      
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: BlocBuilder<ConsultantBloc, ConsultantState>(
              builder: (context, state) {
                return _buildContent(state);
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }
}
