
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/followup_entity.dart';
import '../bloc/followup_bloc.dart';
import '../bloc/followup_event.dart';
import '../bloc/followup_state.dart';

class FollowupPage extends StatefulWidget {
  const FollowupPage({
    super.key,
  });

  @override
  State<FollowupPage> createState() => _FollowupPageState();
}

class _FollowupPageState extends State<FollowupPage> {
  // ===========================================================================
  // VARIABLES
  // ===========================================================================
  // DateTime fromDate = DateTime(2026, 1, 1);
  // DateTime toDate = DateTime(2026, 9, 17);

  DateTime fromDate = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,
);

DateTime toDate = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,
);

  String selectedType = 'Dealer';

  String userId = '';

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _initializePage();
  }

  // ===========================================================================
  // INITIALIZE
  // ===========================================================================

  Future<void> _initializePage() async {
    final userData = await SecureStorage.instance.getUserData();

    if (!mounted) return;

    final String id =
        userData?['user_id']?.toString() ?? '';

    if (id.isEmpty) return;

    setState(() {
      userId = id;
    });

    _loadFollowup();
  }

  // ===========================================================================
  // DATE FORMAT
  // ===========================================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _formatShortDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ===========================================================================
  // API
  // ===========================================================================

  void _loadFollowup() {
    if (userId.isEmpty) return;

    context.read<FollowupBloc>().add(
          GetUpcomingFollowupEvent(
            fromDate: _formatDate(fromDate),
            toDate: _formatDate(toDate),
            type: selectedType,
            userId: userId,
          ),
        );
  }

  // ===========================================================================
  // TYPE CHANGE
  // ===========================================================================

  void _changeType(String type) {
    if (selectedType == type) return;

    setState(() {
      selectedType = type;
    });

    // Automatically load new list.
    _loadFollowup();
  }

  // ===========================================================================
  // DATE PICKER THEME
  // ===========================================================================

  ThemeData _datePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.textPrimary,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textDark,
      ),
    );
  }

  // ===========================================================================
  // FROM DATE
  // ===========================================================================

  Future<void> _selectFromDate() async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: _datePickerTheme(context),
          child: child!,
        );
      },
    );

    if (result == null) return;

    setState(() {
      fromDate = result;

      if (fromDate.isAfter(toDate)) {
        toDate = fromDate;
      }
    });

    _loadFollowup();
  }

  // ===========================================================================
  // TO DATE
  // ===========================================================================

  Future<void> _selectToDate() async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: _datePickerTheme(context),
          child: child!,
        );
      },
    );

    if (result == null) return;

    setState(() {
      toDate = result;
    });

    _loadFollowup();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
      title: 'Upcoming Followup List',
      showBackButton: true,
      onBackTap: () => context.go(AppRouter.home),
      ),

      body: Column(
        children: [
          _buildTopHeader(),

          _buildFilterSection(),

          Expanded(
            child: BlocBuilder<FollowupBloc, FollowupState>(
              builder: (context, state) {
                // -------------------------------------------------------------
                // LOADING
                // -------------------------------------------------------------

                if (state is FollowupLoading) {
                  return _buildLoading();
                }

                // -------------------------------------------------------------
                // ERROR
                // -------------------------------------------------------------

                if (state is FollowupError) {
                  return _buildErrorState(
                    state.message,
                  );
                }

                // -------------------------------------------------------------
                // EMPTY
                // -------------------------------------------------------------

                if (state is FollowupEmpty) {
                  return _buildEmptyState();
                }

                // -------------------------------------------------------------
                // SUCCESS
                // -------------------------------------------------------------

                if (state is FollowupSuccess) {
                  return _buildFollowupList(
                    state.followups,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP HEADER
  // ===========================================================================

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.darkGreen,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // ICON
          // -------------------------------------------------------------------

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.white.withOpacity(0.10),
              ),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          // -------------------------------------------------------------------
          // TITLE
          // -------------------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Followups',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_formatShortDate(fromDate)}  •  '
                  '${_formatShortDate(toDate)}',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // COUNT
          // -------------------------------------------------------------------

          BlocBuilder<FollowupBloc, FollowupState>(
            builder: (context, state) {
              if (state is FollowupSuccess) {
                return _buildCountBadge(
                  state.followups.length,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COUNT BADGE
  // ===========================================================================

  Widget _buildCountBadge(int count) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 54,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 1),

          const Text(
            'TOTAL',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER SECTION
  // ===========================================================================

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        8,
      ),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // =================================================================
          // FROM + TO + SEARCH
          // =================================================================

          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  title: 'FROM',
                  date: fromDate,
                  icon: Icons.calendar_month_rounded,
                  onTap: _selectFromDate,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _buildDateBox(
                  title: 'TO',
                  date: toDate,
                  icon: Icons.event_rounded,
                  onTap: _selectToDate,
                ),
              ),

              const SizedBox(width: 7),

              _buildSearchButton(),
            ],
          ),

          const SizedBox(height: 10),

          // =================================================================
          // DEALER / FARMER
          // =================================================================

          _buildTypeSelector(),
        ],
      ),
    );
  }

  // ===========================================================================
  // DATE BOX
  // ===========================================================================

  Widget _buildDateBox({
    required String title,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAF8),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.white,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: AppColors.primaryGreen,
                ),
              ),

              const SizedBox(width: 6),

              // Date
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 7.5,
                        color: Color(0xFF849087),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _formatShortDate(date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TYPE SELECTOR
  // ===========================================================================

  Widget _buildTypeSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE4EAE5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              title: 'Dealer',
              icon: Icons.storefront_rounded,
            ),
          ),

          Expanded(
            child: _buildTypeOption(
              title: 'Farmer',
              icon: Icons.agriculture_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPE OPTION
  // ===========================================================================

  Widget _buildTypeOption({
    required String title,
    required IconData icon,
  }) {
    final bool selected =
        selectedType == title;

    return GestureDetector(
      onTap: () {
        _changeType(title);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        AppColors.primaryGreen.withOpacity(0.20),
                    blurRadius: 7,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.white.withOpacity(0.16)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 15,
                color: selected
                    ? AppColors.white
                    : const Color(0xFF69766E),
              ),
            ),

            const SizedBox(width: 5),

            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppColors.white
                    : const Color(0xFF69766E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SEARCH BUTTON
  // ===========================================================================

  Widget _buildSearchButton() {
    final bool enabled =
        userId.isNotEmpty;

    return Material(
      color: enabled
          ? AppColors.primaryGreen
          : AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: enabled
            ? _loadFollowup
            : null,
        borderRadius:
            BorderRadius.circular(13),
        child: const SizedBox(
          width: 48,
          height: 52,
          child: Icon(
            Icons.search_rounded,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LIST
  // ===========================================================================

  Widget _buildFollowupList(
    List<FollowupEntity> followups,
  ) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        _loadFollowup();
      },
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          12,
          5,
          12,
          25,
        ),
        itemCount: followups.length,
        itemBuilder: (context, index) {
          return _buildFollowupCard(
            followups[index],
            index,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // FOLLOWUP CARD
  // ===========================================================================

  Widget _buildFollowupCard(
    FollowupEntity item,
    int index,
  ) {
    final bool isPhone =
        item.followupType.toLowerCase() ==
            'phone';

    final bool hasFollowupDate =
        item.followupDate.isNotEmpty &&
        item.followupDate != item.date;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EBE6),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // LEFT TYPE INDICATOR
              // ---------------------------------------------------------------

              Container(
                width: 4,
                color: isPhone
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen,
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    11,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(item),

                      const SizedBox(height: 11),

                      _buildDateTimeRow(
                        item,
                        hasFollowupDate,
                      ),

                      // if (item.remark.isNotEmpty) ...[
                      //   const SizedBox(height: 9),
                      //   _buildRemark(
                      //     item.remark,
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CARD HEADER
  // ===========================================================================

  Widget _buildCardHeader(
    FollowupEntity item,
  ) {
    final bool isPhone =
        item.followupType.toLowerCase() ==
            'phone';

    return Row(
      children: [
        // ---------------------------------------------------------------------
        // ICON
        // ---------------------------------------------------------------------

        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPhone
                  ? const [
                      AppColors.white,
                      AppColors.white,
                    ]
                  : const [
                      AppColors.white,
                      AppColors.white,
                    ],
            ),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            isPhone
                ? Icons.phone_in_talk_rounded
                : Icons.storefront_rounded,
            color: isPhone
                ? AppColors.primaryGreen
                : AppColors.primaryGreen,
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        // ---------------------------------------------------------------------
        // NAME
        // ---------------------------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                item.name.isEmpty
                    ? 'Unknown'
                    : item.name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),

                  const SizedBox(width: 4),

                  Flexible(
                    child: Text(
                      item.type.isEmpty
                          ? 'Followup'
                          : item.type,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color:
                            Colors.grey.shade600,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ---------------------------------------------------------------------
        // TYPE CHIP
        // ---------------------------------------------------------------------

        if (item.time.isNotEmpty)
          _buildStatusChip(
            item.time,
            isPhone,
          ),
      ],
    );
  }


  // ===========================================================================
  // STATUS CHIP
  // ===========================================================================

  Widget _buildStatusChip(
    String type,
    bool isPhone,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isPhone
            ? AppColors.white
            : AppColors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isPhone
              ? AppColors.white
              : const Color(0xFFFFE8B8),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            isPhone
                ? Icons.timer
                : Icons.location_on_outlined,
            size: 12,
            color: isPhone
                ? const Color(0xFF178A45)
                : const Color(0xFFB76B00),
          ),

          const SizedBox(width: 4),

          Text(
            type,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isPhone
                  ? const Color(0xFF178A45)
                  : const Color(0xFFB76B00),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DATE + TIME
  // ===========================================================================

  Widget _buildDateTimeRow(
    FollowupEntity item,
    bool hasFollowupDate,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F7),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEDF1ED),
        ),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // DATE
          // -------------------------------------------------------------------

          _buildInfoItem(
            icon: Icons.calendar_today_rounded,
            label: 'DATE',
            value: item.date,
          ),

          Container(
            width: 1,
            height: 29,
            margin:
                const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            color:
                const Color(0xFFE1E6E2),
          ),

          // -------------------------------------------------------------------
          // TIME
          // -------------------------------------------------------------------

          _buildInfoItem(
            icon:
                Icons.mobile_friendly,
            label: 'Mobile',
            value: item.mobileNo,
          ),

          // -------------------------------------------------------------------
          // FOLLOWUP DATE
          // -------------------------------------------------------------------

          if (hasFollowupDate) ...[
            const SizedBox(width: 8),

            Container(
              width: 1,
              height: 29,
              color:
                  const Color(0xFFE1E6E2),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildNextDate(
                item.followupDate,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ITEM
  // ===========================================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primaryGreen,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 7.5,
                    color:
                        Color(0xFF89958C),
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty
                      ? '--'
                      : value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color:
                        Color(0xFF26332A),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NEXT FOLLOWUP DATE
  // ===========================================================================

  Widget _buildNextDate(
    String date,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFE8F7ED),
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_repeat_rounded,
            size: 13,
            color: AppColors.primaryGreen,
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              date,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.primaryGreen,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoading() {
    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        5,
        12,
        20,
      ),
      itemCount: 5,
      itemBuilder: (_, index) {
        return Container(
          height: 145,
          margin:
              const EdgeInsets.only(
            bottom: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFFE7ECE8),
            ),
          ),
          child: const Center(
            child: SizedBox(
              width: 23,
              height: 23,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Widget _buildErrorState(
    String message,
  ) {
    return _buildStateContent(
      icon: Icons.cloud_off_rounded,
      iconColor: Colors.red,
      title: 'Unable to load followups',
      subtitle: message,
      buttonText: 'Try Again',
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmptyState() {
    return _buildStateContent(
      icon: Icons.event_available_rounded,
      iconColor: AppColors.primaryGreen,
      title: 'No followups found',
      subtitle:
          'No $selectedType followups are available for the selected date range.',
      buttonText: 'Refresh',
    );
  }

  // ===========================================================================
  // EMPTY / ERROR CONTENT
  // ===========================================================================

  Widget _buildStateContent({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // -----------------------------------------------------------------
            // ICON
            // -----------------------------------------------------------------

            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color:
                    iconColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 37,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 17),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color:
                    Color(0xFF1D2921),
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 7),

            // -----------------------------------------------------------------
            // SUBTITLE
            // -----------------------------------------------------------------

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color:
                    Color(0xFF7B867F),
              ),
            ),

            const SizedBox(height: 19),

            // -----------------------------------------------------------------
            // BUTTON
            // -----------------------------------------------------------------

            Material(
              color: AppColors.primaryGreen,
              borderRadius:
                  BorderRadius.circular(12),
              child: InkWell(
                onTap: _loadFollowup,
                borderRadius:
                    BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.white,
                        size: 17,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        buttonText,
                        style:
                            const TextStyle(
                          color: AppColors.white,
                          fontSize: 11.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
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

