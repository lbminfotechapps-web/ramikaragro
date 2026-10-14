import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';

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

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADD / EDIT NAVIGATION
  // ============================================================

  Future<void> _openForm([ConsultantDoctor? doctor]) async {
    try {
      final bool? saved = await context.pushNamed<bool>(
        'consultantDoctorForm',
        extra: doctor,
      );

      if (!mounted) return;

      if (saved == true) {
        _refreshList();
      }
    } catch (error, stackTrace) {
      debugPrint('CONSULTANT NAVIGATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open Consultant Form: $error')),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  void _refreshList() {
    context.read<ConsultantBloc>().add(const LoadConsultants());
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<ConsultantDoctor> _filterDoctors(List<ConsultantDoctor> doctors) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return doctors;
    }

    return doctors.where((doctor) {
      final searchable = [
        doctor.doctorName,
        doctor.ownerName,
        doctor.mobile,
        doctor.address,
        doctor.stateName,
        doctor.districtName,
        doctor.talukaName,
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(String name) {
    final cleaned = name
        .replaceFirst(RegExp(r'^(dr\.?|doctor)\s+', caseSensitive: false), '')
        .trim();

    final words = cleaned
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int count) {
    final primary = context.appPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              size: 23,
              color: primary,
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
                  'Manage consultant information',
                  style: TextStyle(color: context.appSubText, fontSize: 11),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: context.appCard,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.appBorder),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(
                  'Total',
                  style: TextStyle(color: context.appSubText, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

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

        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,

        style: TextStyle(
          color: context.appInputText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),

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
                    size: 18,
                    color: context.appSubText,
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({required int total, required int filtered}) {
    return Row(
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

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context.appPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$filtered',
            style: TextStyle(
              color: context.appPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const Spacer(),

        if (filtered != total)
          Text(
            'of $total',
            style: TextStyle(color: context.appSubText, fontSize: 11),
          ),

        IconButton(
          tooltip: 'Refresh Consultants',
          onPressed: _refreshList,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minHeight: 35, minWidth: 35),
          icon: Icon(
            Icons.refresh_rounded,
            color: context.appPrimary,
            size: 19,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONSULTANT CARD
  // ============================================================

  Widget _buildConsultantCard(ConsultantDoctor doctor) {
    final primary = context.appPrimary;

    final location = [
      doctor.talukaName,
      doctor.districtName,
      doctor.stateName,
    ].where((value) => value.trim().isNotEmpty).join(', ');

    return Material(
      color: context.appCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openForm(doctor),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP ROW
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.09),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: context.appSubText,
                              size: 13,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                'Owner: ${doctor.ownerName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.appSubText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Container(
                  //   width: 31,
                  //   height: 31,
                  //   alignment: Alignment.center,
                  //   decoration: BoxDecoration(
                  //     color: primary.withValues(
                  //       alpha: 0.07,
                  //     ),
                  //     borderRadius: BorderRadius.circular(9),
                  //   ),
                  //   child: Icon(
                  //     Icons.edit_outlined,
                  //     color: primary,
                  //     size: 17,
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 10),

              Divider(height: 1, thickness: 1, color: context.appBorder),

              const SizedBox(height: 9),

              // ==================================================
              // PHONE / LOCATION
              // ==================================================
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: primary),

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
                          size: 14,
                          color: primary,
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
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final isSearching = _isSearching;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 66,
              width: 66,
              decoration: BoxDecoration(
                color: context.appPrimary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.medical_services_outlined,
                color: context.appPrimary,
                size: 30,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              isSearching
                  ? 'No Matching Consultants'
                  : 'No Consultants Added Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              isSearching
                  ? 'Try searching by name, mobile or location.'
                  : 'Add your first consultant doctor to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appSubText, fontSize: 11.5),
            ),

            const SizedBox(height: 12),

            if (isSearching)
              TextButton.icon(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear Search'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('Add Consultant'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appPrimary,
                  side: BorderSide(color: context.appPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(ConsultantState state) {
    final loading =
        state.status == ConsultantStatus.initial ||
        state.status == ConsultantStatus.loading;

    final doctors = state.doctors;
    final filteredDoctors = _filterDoctors(doctors);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Column(
            children: [
              _buildHeader(doctors.length),

              const SizedBox(height: 11),

              _buildSearchBar(),

              const SizedBox(height: 5),

              _buildSectionTitle(
                total: doctors.length,
                filtered: filteredDoctors.length,
              ),
            ],
          ),
        ),

        Expanded(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(color: context.appPrimary),
                )
              : state.status == ConsultantStatus.failure && doctors.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 33,
                          color: context.appError,
                        ),

                        const SizedBox(height: 9),

                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.appSubText,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextButton.icon(
                          onPressed: _refreshList,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : filteredDoctors.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: context.appPrimary,
                  onRefresh: () async {
                    // Refresh using current BLoC.
                    _refreshList();
                  },
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                    itemCount: filteredDoctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      return _buildConsultantCard(filteredDoctors[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM ADD BUTTON
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
