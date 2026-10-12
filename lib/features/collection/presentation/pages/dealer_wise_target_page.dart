import 'package:solufine/core/di/collection_target_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';
import 'package:solufine/features/collection/domain/entities/target_date_entity.dart';
import 'package:solufine/features/collection/presentation/bloc/dealer_target_bloc.dart';
import 'package:solufine/features/collection/presentation/bloc/dealer_target_event.dart';
import 'package:solufine/features/collection/presentation/bloc/dealer_target_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/features/selfcollectionassign/domain/entities/dealer_entity.dart';
import 'package:solufine/features/selfcollectionassign/domain/entities/collection_type_entity.dart';
import 'package:solufine/features/selfcollectionassign/domain/usecases/get_dealer_list.dart';
import 'package:solufine/features/selfcollectionassign/domain/usecases/get_collection_type.dart';

class DealerWiseTargetPage extends StatefulWidget {
  const DealerWiseTargetPage({super.key});

  @override
  State<DealerWiseTargetPage> createState() => _DealerWiseTargetPageState();
}

class _DealerWiseTargetPageState extends State<DealerWiseTargetPage> {
  late final DealerTargetBloc bloc;

  String userId = '';
  List<DealerEntity> _dealers = [];
  List<CollectionTypeEntity> _collectionTypes = [];
  String? _selectedDealerId;
  String? _selectedCollectionTypeId;
  bool _loadingOptions = true;
  String? _optionsError;

  Future<void> _loadOptions() async {
    final id = int.tryParse(userId);
    if (id == null || id <= 0) {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
          _optionsError = 'User ID not found';
        });
      }
      return;
    }
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });
    try {
      await Future.wait<void>([
        sl<GetDealerList>()(userId: id).then((response) {
          if (!response.status) throw Exception(response.message);
          if (mounted) _dealers = response.dealers;
        }),
        sl<GetCollectionType>()().then((response) {
          if (!response.status) throw Exception(response.message);
          if (mounted) _collectionTypes = response.collectionTypes;
        }),
      ]);
    } catch (e) {
      if (mounted) _optionsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  void _reloadTarget() {
    final date = bloc.state.selectedDate;
    if (date == null || bloc.state.datesStatus != TargetDatesStatus.success)
      return;
    bloc.add(
      SelectTargetDateEvent(
        selectedDate: date,
        userId: userId,
        outletId: _selectedDealerId ?? '',
        collectionTypeId: _selectedCollectionTypeId ?? '',
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    bloc = sl<DealerTargetBloc>();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final userData = await SecureStorage.instance.getUserData();
      if (!mounted) return;

      userId = userData?['user_id']?.toString() ?? '';
      _loadOptions();

      debugPrint('TARGET SCREEN USER ID: $userId');

      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User ID not found')));
        }

        return;
      }

      bloc.add(
        LoadTargetDatesEvent(
          userId: userId,
          outletId: _selectedDealerId ?? '',
          collectionTypeId: _selectedCollectionTypeId ?? '',
        ),
      );
    } catch (e) {
      debugPrint('USER ID ERROR: $e');

      if (mounted) {
        setState(() {
          _loadingOptions = false;
          _optionsError = 'Unable to load user information';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load user information')),
        );
      }
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: context.backgroundColor,

        appBar: CustomAppBar(
      
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 19,
            color: context.appThemeData.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              context.go(AppRouter.home);
            },
          ),
          title: 'Target & Achievement ',
          subtitle: 'Collection Wise',
        ),

        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildOptions(),

              Expanded(
                child: BlocBuilder<DealerTargetBloc, DealerTargetState>(
                  builder: (context, state) {
                    if (state.datesStatus == TargetDatesStatus.loading) {
                      return CustomLoader(color: context.primaryColor);
                    }

                    if (state.datesStatus == TargetDatesStatus.failure) {
                      return _buildMessage(
                        state.message ?? 'Unable to load target dates',
                      );
                    }

                    if (state.targetDates.isEmpty) {
                      return _buildMessage('No target dates found');
                    }

                    return RefreshIndicator(
                      color: context.primaryColor,
                      onRefresh: () async {
                        if (userId.isEmpty) {
                          return;
                        }

                        bloc.add(
                          LoadTargetDatesEvent(
                            userId: userId,
                            outletId: _selectedDealerId ?? '',
                            collectionTypeId: _selectedCollectionTypeId ?? '',
                          ),
                        );

                        await bloc.stream.firstWhere(
                          (state) =>
                              state.datesStatus != TargetDatesStatus.loading,
                        );
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        children: [
                          _buildMonthDropdown(state),

                          const SizedBox(height: 12),

                          _buildTargetContent(state),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  InputDecoration _optionDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.secondaryTextColor, fontSize: 13),
      prefixIcon: Icon(icon, color: context.primaryColor, size: 20),
      filled: true,
      fillColor: context.appTheme.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.borderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildOptions() {
    if (_loadingOptions) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(color: context.primaryColor),
      );
    }
    if (_optionsError != null) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(_optionsError!),
            TextButton(onPressed: _loadOptions, child: Text('Retry')),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: context.primaryColor, size: 19),
              SizedBox(width: 8),
              Text(
                'Collection details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // DropdownButtonFormField<String>(
          //   initialValue: _selectedDealerId,
          //   isExpanded: true,
          //   borderRadius: BorderRadius.circular(16),
          //   dropdownColor: Colors.white,
          //   icon: const Icon(Icons.expand_more_rounded, color: primaryGreen),
          //   style: const TextStyle(
          //     color: darkGreen,
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //   ),
          //   decoration: _optionDecoration('Dealer', Icons.storefront_outlined),
          //   hint: Text(_dealers.isEmpty ? 'No dealers found' : 'Select dealer'),
          //   items: _dealers
          //       .map(
          //         (dealer) => DropdownMenuItem(
          //           value: dealer.outletId,
          //           child: Text(
          //             dealer.outletName+' - (${dealer.outletMobile})',
          //             overflow: TextOverflow.ellipsis,
          //             style: const TextStyle(fontSize: 13),
          //           ),
          //         ),
          //       )
          //       .toList(),
          //   onChanged: _dealers.isEmpty
          //       ? null
          //       : (value) {
          //           setState(() => _selectedDealerId = value);
          //           _reloadTarget();
          //         },
          // ),
          DropdownButtonFormField<String>(
            initialValue: _selectedDealerId,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            dropdownColor: context.cardBackgroundColor,
            icon: Icon(Icons.expand_more_rounded, color: context.primaryColor),
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _optionDecoration('Dealer', Icons.storefront_outlined),
            hint: Text(_dealers.isEmpty ? 'No dealers found' : 'Select dealer'),

            // Dealer dropdown items
            items: _dealers.map((dealer) {
              final bool isAll = dealer.outletId.toString() == '0';

              final String dealerName = dealer.outletName.toString();
              final String mobileNumber = dealer.outletMobile.toString().trim();

              String displayName;

              if (isAll) {
                // If outlet ID is 0, show only All
                displayName = 'All';
              } else if (mobileNumber.isEmpty || mobileNumber == 'null') {
                // If mobile number is empty, show only dealer name
                displayName = dealerName;
              } else {
                // Show dealer name with mobile number
                displayName = '$dealerName - ($mobileNumber)';
              }

              return DropdownMenuItem<String>(
                value: dealer.outletId,
                child: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),

            // Dealer selection
            onChanged: _dealers.isEmpty
                ? null
                : (String? value) {
                    if (value == null) return;

                    setState(() {
                      _selectedDealerId = value;
                    });

                    // Reload target based on selected dealer
                    _reloadTarget();
                  },
          ),

          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCollectionTypeId,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            dropdownColor: context.cardBackgroundColor,
            icon: Icon(Icons.expand_more_rounded, color: context.primaryColor),
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _optionDecoration(
              'Collection type',
              Icons.category_outlined,
            ),
            hint: Text(
              _collectionTypes.isEmpty
                  ? 'No collection types found'
                  : 'Select collection type',
            ),
            items: _collectionTypes
                .map(
                  (type) => DropdownMenuItem(
                    value: type.collectionTypeId,
                    child: Text(
                      type.collectionType,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _collectionTypes.isEmpty
                ? null
                : (value) {
                    setState(() => _selectedCollectionTypeId = value);
                    _reloadTarget();
                  },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MONTH DROPDOWN
  // =========================================================

  Widget _buildMonthDropdown(DealerTargetState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: context.primaryColor,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TargetDateEntity>(
                value: state.selectedDate,
                dropdownColor: context.cardBackgroundColor,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.secondaryTextColor,
                ),
                hint: Text(
                  'Select Month',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.secondaryTextColor,
                  ),
                ),
                items: state.targetDates
                    .map(
                      (date) => DropdownMenuItem<TargetDateEntity>(
                        value: date,
                        child: Text(
                          date.monthName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.primaryTextColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  bloc.add(
                    SelectTargetDateEvent(
                      selectedDate: value,
                      userId: userId,
                      outletId: _selectedDealerId ?? '',
                      collectionTypeId: _selectedCollectionTypeId ?? '',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TARGET CONTENT
  // =========================================================

  Widget _buildTargetContent(DealerTargetState state) {
    if (state.targetStatus == CollectionTargetStatus.loading) {
      return CustomLoader(color: context.primaryColor);
    }

    if (state.targetStatus == CollectionTargetStatus.failure) {
      return _buildMessage(state.message ?? 'No record found');
    }

    if (_selectedDealerId == null || _selectedCollectionTypeId == null) {
      return _buildMessage(
        'Select a dealer and collection type to view targets.',
      );
    }

    final target = state.target;

    if (target == null) {
      return _buildMessage('No record found');
    }

    return Column(
      children: [
        _buildSummaryCards(target),

        const SizedBox(height: 12),

        _buildChartCard(target),
      ],
    );
  }

  // =========================================================
  // SUMMARY CARDS
  // =========================================================

  Widget _buildSummaryCards(dynamic target) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Target in Rs.',
                value: target.totalTarget,
                icon: Icons.flag_outlined,
                color: context.appColors.secondary,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildStatCard(
                title: 'Achieved in Rs.',
                value: target.totalAchieved,
                icon: Icons.check_circle_outline,
                color: context.primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending in Rs.',
                value: target.totalPending,
                icon: Icons.pending_actions_outlined,
                color: context.appColors.tertiary,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildStatCard(
                title: 'Achievement',
                value: '${target.percentage}%',
                icon: Icons.percent_rounded,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CHART CARD
  // =========================================================

  Widget _buildChartCard(dynamic target) {
    final double total = double.tryParse(target.totalTarget.toString()) ?? 0;

    final double achieved =
        double.tryParse(target.totalAchieved.toString()) ?? 0;

    double achievedPercent = 0;

    if (total > 0) {
      achievedPercent = (achieved / total) * 100;
    }

    achievedPercent = achievedPercent.clamp(0, 100);

    final double pendingPercent = 100 - achievedPercent;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // TITLE
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.donut_large_outlined,
                  color: context.primaryColor,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Target vs collection',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // CHART
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 56,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: [
                      if (pendingPercent > 0)
                        PieChartSectionData(
                          value: pendingPercent,
                          title: '',
                          radius: 72,
                          color: context.appColors.tertiary,
                          showTitle: false,
                        ),

                      if (achievedPercent > 0)
                        PieChartSectionData(
                          value: achievedPercent,
                          title: '',
                          radius: 72,
                          color: context.primaryColor,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),

                // CENTER VALUE
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // '${achievedPercent.toStringAsFixed(0)}%',
                      '${achievedPercent.toStringAsFixed(2)}%',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.primaryTextColor,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Achieved',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // LEGEND
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: context.primaryColor,
                  title: 'Collection',
                  value: '${achievedPercent.toStringAsFixed(0)}%',
                ),
              ),

              Expanded(
                child: _buildLegendItem(
                  color: context.appColors.tertiary,
                  title: 'Pending Target',
                  value: '${pendingPercent.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LEGEND ITEM
  // =========================================================

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),

              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 34,
                color: context.primaryColor,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
