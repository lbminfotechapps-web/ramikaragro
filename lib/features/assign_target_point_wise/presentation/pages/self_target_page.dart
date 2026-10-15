import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:solufine/core/di/self_target_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import 'package:solufine/features/assign_target_point_wise/domain/entities/target_group_entity.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_bloc.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_event.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_state.dart';

class SelfTargetPage extends StatefulWidget {
  const SelfTargetPage({super.key});

  @override
  State<SelfTargetPage> createState() => _SelfTargetPageState();
}

class _SelfTargetPageState extends State<SelfTargetPage> {
  // ============================================================
  // BLOC
  // ============================================================

  late SelfTargetBloc bloc;

  // ============================================================
  // USER
  // ============================================================

  String userId = '';

  bool isLoadingUser = true;

  // ============================================================
  // POINT
  // ============================================================

  final TextEditingController pointController = TextEditingController();

  final FocusNode pointFocusNode = FocusNode();

  // ============================================================
  // MONTH
  // ============================================================

  late List<TargetMonth> months;

  TargetMonth? selectedMonth;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    bloc = sl<SelfTargetBloc>();

    months = _generateMonths();

    selectedMonth = months.first;

    _loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      if (!mounted) {
        return;
      }

      final String loadedUserId = userData?['user_id']?.toString() ?? '';

      setState(() {
        userId = loadedUserId;
        isLoadingUser = false;
      });

      debugPrint('========================================');

      debugPrint('SELF TARGET');

      debugPrint('USER ID = $userId');

      debugPrint(
        'DEFAULT MONTH = '
        '${selectedMonth?.apiValue}',
      );

      debugPrint('========================================');

      if (userId.trim().isEmpty) {
        _showMessage('User information not found');

        return;
      }

      // ========================================================
      // SET DEFAULT MONTH IN BLOC
      // ========================================================

      if (selectedMonth != null) {
        bloc.add(ChangeSelfTargetMonthEvent(month: selectedMonth!.apiValue));
      }

      // ========================================================
      // LOAD PRODUCT GROUP
      // ========================================================

      bloc.add(const GetSelfTargetEvent());
    } catch (e) {
      debugPrint('SELF TARGET USER ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingUser = false;
      });

      _showMessage('Unable to load user information');
    }
  }

  // ============================================================
  // MONTHS
  // ============================================================

  List<TargetMonth> _generateMonths() {
    final DateTime now = DateTime.now();

    final List<TargetMonth> list = [];

    for (int index = 0; index < 4; index++) {
      final DateTime date = DateTime(now.year, now.month + index, 1);

      list.add(
        TargetMonth(
          apiValue: '${date.year}-${date.month.toString().padLeft(2, '0')}',

          displayName: '${_monthName(date.month)} ${date.year}',
        ),
      );
    }

    return list;
  }

  String _monthName(int month) {
    const List<String> names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return names[month - 1];
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    pointController.dispose();

    pointFocusNode.dispose();

    bloc.close();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // USER
    // ----------------------------------------------------------

    if (userId.trim().isEmpty) {
      _showMessage('User information not available');

      return;
    }

    // ----------------------------------------------------------
    // MONTH
    // ----------------------------------------------------------

    if (selectedMonth == null) {
      _showMessage('Please select target month');

      return;
    }

    // ----------------------------------------------------------
    // POINT
    // ----------------------------------------------------------

    final String point = pointController.text.trim();

    if (point.isEmpty) {
      _showMessage('Please enter your target point');

      pointFocusNode.requestFocus();

      return;
    }

    final double? value = double.tryParse(point);

    if (value == null || value <= 0) {
      _showMessage('Please enter valid target point');

      pointFocusNode.requestFocus();

      return;
    }

    debugPrint('========================================');

    debugPrint('SUBMIT SELF TARGET');

    debugPrint('USER ID = $userId');

    debugPrint('MONTH = ${selectedMonth!.apiValue}');

    debugPrint('POINTS = $point');

    debugPrint('========================================');

    bloc.add(
      SubmitSelfTargetEvent(
        userId: userId,
        month: selectedMonth!.apiValue,
        groupId: "",
        points: point,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: context.appColors.error,

          margin: const EdgeInsets.all(12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          content: Text(
            message,

            style: AppTextStyles.button.copyWith(
              color: context.appColors.onError,
            ),
          ),
        ),
      );
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 18),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 68,
                height: 68,

                decoration: BoxDecoration(
                  color: context.appColors.primaryContainer,

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.check_circle_rounded,

                  color: context.primaryColor,

                  size: 46,
                ),
              ),

              SizedBox(height: 14),

              Text(
                'Target Submitted',

                textAlign: TextAlign.center,

                style: AppTextStyles.sectionTitle.copyWith(
                  color: context.primaryTextColor,
                ),
              ),

              SizedBox(height: 6),

              Text(
                message,

                textAlign: TextAlign.center,

                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.4,

                  color: context.secondaryTextColor,
                ),
              ),

              SizedBox(height: 18),

              // SizedBox(
              //   width:
              //       double.infinity,

              //   height: 44,

              //   child:
              //       ElevatedButton(
              //     onPressed:
              //         () {
              //       Navigator.pop(
              //         dialogContext,
              //       );
              //     },

              //     style:
              //         ElevatedButton
              //             .styleFrom(
              //       backgroundColor:
              //           const Color(
              //         0xFF166534,
              //       ),

              //       foregroundColor:
              //           Colors.white,

              //       elevation: 0,

              //       shape:
              //           RoundedRectangleBorder(
              //         borderRadius:
              //             BorderRadius.circular(
              //           12,
              //         ),
              //       ),
              //     ),

              //     child:
              //         const Text(
              //       'Done',

              //       style:
              //           TextStyle(
              //         fontWeight:
              //             FontWeight.w700,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(
                width: double.infinity,
                height: 44,

                child: ElevatedButton(
                  onPressed: () {
                    // Close success dialog
                    Navigator.pop(dialogContext);

                    // Go to Home
                    context.go(AppRouter.home);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,

                    foregroundColor: context.onPrimaryColor,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text('Done', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFailureDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.appColors.shadow.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.85, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.shadow.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ERROR ICON
                  // Container(
                  //   width: 82,
                  //   height: 82,
                  //   decoration: const BoxDecoration(
                  //     color: Color(
                  //       0xFFFFECEC,
                  //     ),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: Center(
                  //     child: Container(
                  //       width: 58,
                  //       height: 58,
                  //       decoration: const BoxDecoration(
                  //         color: Color(
                  //           0xFFDC2626,
                  //         ),
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: const Icon(
                  //         Icons.close_rounded,
                  //         color: Colors.white,
                  //         size: 34,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 20),

                  Text(
                    'Target Already Added',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),

                  SizedBox(height: 8),

                  // API MESSAGE
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                      color: context.secondaryTextColor,
                    ),
                  ),

                  SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.error,
                        foregroundColor: context.appColors.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 19),
                          SizedBox(width: 7),
                          Text(
                            'Try Next Month',
                            style: AppTextStyles.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,

      child: BlocConsumer<SelfTargetBloc, SelfTargetState>(
        listener: (context, state) {
          // ====================================================
          // SUCCESS
          // ====================================================

          if (state.status == SelfTargetStatus.submitSuccess) {
            _showSuccessDialog(
              state.message.trim().isEmpty
                  ? 'Self Target Submitted Successfully.'
                  : state.message,
            );

            return;
          }

          // ====================================================
          // FAILURE
          // ====================================================

          if (state.status == SelfTargetStatus.failure) {
            _showFailureDialog(
              state.message.trim().isEmpty
                  ? 'Something went wrong. Please try again.'
                  : state.message,
            );

            return;
          }
        },

        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.backgroundColor,

            appBar: CustomAppBar(
              title: 'Self Assign Target ',
              subtitle: 'Point Wise Sales',

              showBackButton: true,

              onBackTap: () {
                Navigator.pop(context);
              },
            ),

            body: _buildBody(state),

            bottomNavigationBar: _buildSubmitButton(state),
          );
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(SelfTargetState state) {
    if (isLoadingUser) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (state.status == SelfTargetStatus.loading && state.groups.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    return RefreshIndicator(
      color: context.primaryColor,

      onRefresh: () async {
        bloc.add(const GetSelfTargetEvent());
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(12, 10, 12, 82),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HERO
            // ==================================================
            _buildHeroCard(),

            SizedBox(height: 10),

            // ==================================================
            // PRODUCT GROUP FIRST
            // ==================================================
            _buildGroupSection(state),

            SizedBox(height: 10),

            // ==================================================
            // MONTH BELOW GROUP
            // ==================================================
            _buildMonthCard(),

            SizedBox(height: 8),

            // ==================================================
            // POINT BELOW MONTH
            // ==================================================
            _buildPointCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO - COMPACT
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(
        color: context.primaryColor,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: .14),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: .15),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.track_changes_rounded,

              color: context.onPrimaryColor,

              size: 23,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Self Target',

                  style: AppTextStyles.cardTitle.copyWith(
                    color: context.onPrimaryColor,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Review group points and assign your monthly target.',

                  style: AppTextStyles.caption.copyWith(
                    color: context.onPrimaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETE PRODUCT GROUP SECTION
  // ============================================================

  Widget _buildGroupSection(SelfTargetState state) {
    double totalPoints = 0;

    for (final group in state.groups) {
      totalPoints += group.groupPointsValue;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: context.borderColor),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .02),

            blurRadius: 8,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // HEADER
          // ====================================================
          Row(
            children: [
              Container(
                height: 34,
                width: 34,

                decoration: BoxDecoration(
                  color: context.primaryColor.withAlpha(150),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  Icons.category_rounded,

                  size: 18,

                  color: context.backgroundColor,
                ),
              ),

              SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Product Groups',

                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),

                    Text(
                      'Group-wise point details',

                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

                decoration: BoxDecoration(
                  color: context.primaryColor.withAlpha(150),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  //'${_formatPoint(totalPoints)} Amt/Pts',
                  'Amt/Pts',

                  style: AppTextStyles.badge.copyWith(
                    color: context.backgroundColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 9),

          if (state.groups.isEmpty)
            _buildEmpty()
          else
            ...state.groups.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == state.groups.length - 1 ? 0 : 6,
                ),

                child: _buildCompactGroupCard(group: entry.value),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT GROUP CARD
  // ============================================================

  Widget _buildCompactGroupCard({required TargetGroupEntity group}) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: context.borderColor),
      ),

      child: Row(
        children: [
          // GROUP LETTER
          Container(
            height: 36,
            width: 36,

            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Text(
              group.groupType,

              style: AppTextStyles.cardTitle.copyWith(
                color: context.onPrimaryColor,
              ),
            ),
          ),

          SizedBox(width: 9),

          // GROUP TITLE
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '${group.groupType}',

                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),

                SizedBox(height: 1),
              ],
            ),
          ),

          // POINT VALUE
          Container(
            constraints: const BoxConstraints(minWidth: 72),

            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

            decoration: BoxDecoration(
              color:context.primaryColor.withAlpha(150),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  _formatPoint(group.groupPointsValue),

                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.backgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH CARD - COMPACT
  // ============================================================

  Widget _buildMonthCard() {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: context.borderColor),
      ),

      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: context.primaryColor.withAlpha(150),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.calendar_month_rounded,

              color: context.backgroundColor,

              size: 19,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            flex: 2,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text('Target Month', style: AppTextStyles.labelLarge),

                Text(
                  'Select month',

                  style: AppTextStyles.helperText.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          Expanded(
            flex: 3,

            child: DropdownButtonFormField<TargetMonth>(
              value: selectedMonth,
              dropdownColor: context.cardBackgroundColor,
              style: AppTextStyles.input.copyWith(
                color: context.primaryTextColor,
              ),

              isExpanded: true,

              icon: Icon(
                Icons.keyboard_arrow_down_rounded,

                size: 20,

                color: context.primaryColor,
              ),

              decoration: InputDecoration(
                filled: true,

                fillColor: context.appTheme.inputBackground,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 9,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: BorderSide(color: context.borderColor),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: BorderSide(color: context.primaryColor),
                ),
              ),

              items: months.map((month) {
                return DropdownMenuItem<TargetMonth>(
                  value: month,

                  child: Text(
                    month.displayName,

                    overflow: TextOverflow.ellipsis,

                    style: AppTextStyles.labelSmall,
                  ),
                );
              }).toList(),

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedMonth = value;
                });

                bloc.add(ChangeSelfTargetMonthEvent(month: value.apiValue));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // POINT CARD - COMPACT
  // ============================================================

  Widget _buildPointCard() {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: context.primaryColor.withAlpha(150),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: context.borderColor),
      ),

      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: context.primaryColor,
              border: Border.all(color: context.backgroundColor),
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.edit_note_rounded,

              color: context.onPrimaryColor,

              size: 22,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Enter Your Point',

                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.backgroundColor,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'Monthly target',

                  style: AppTextStyles.helperText.copyWith(
                    color: context.backgroundColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          SizedBox(
            width: 145,

            child: TextFormField(
              controller: pointController,

              focusNode: pointFocusNode,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],

              textAlign: TextAlign.center,

              style: AppTextStyles.input.copyWith(
                color: context.primaryTextColor,
              ),

              decoration: InputDecoration(
                hintText: '0',

                suffixText: 'Pts',

                suffixStyle: AppTextStyles.labelSmall.copyWith(
                  color: context.primaryColor,
                ),

                filled: true,

                fillColor: context.appTheme.inputBackground,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: BorderSide(color: context.borderColor),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: BorderSide(
                    color: context.primaryColor,

                    width: 1.4,
                  ),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 22),

      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 30,
            color: context.secondaryTextColor,
          ),

          SizedBox(height: 5),

          Text(
            'No product groups available',

            style: AppTextStyles.labelSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton(SelfTargetState state) {
    final bool loading = state.status == SelfTargetStatus.submitting;

    return SafeArea(
      top: false,

      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),

        decoration: BoxDecoration(
          color: context.cardBackgroundColor,

          border: Border(top: BorderSide(color: context.borderColor)),

          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow.withValues(alpha: .045),

              blurRadius: 10,

              offset: const Offset(0, -2),
            ),
          ],
        ),

        child: SizedBox(
          height: 47,

          width: double.infinity,

          child: ElevatedButton(
            onPressed: loading ? null : _submit,

            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,

              foregroundColor: context.onPrimaryColor,

              disabledBackgroundColor: context.appColors.onSurface.withValues(
                alpha: 0.12,
              ),

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),

            child: loading
                ? SizedBox(
                    width: 20,

                    height: 20,

                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,

                      color: context.onPrimaryColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.task_alt_rounded, size: 19),

                      SizedBox(width: 7),

                      Text('Submit Target', style: AppTextStyles.button),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT POINT
  // ============================================================

  String _formatPoint(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}

// =============================================================================
// TARGET MONTH
// =============================================================================

class TargetMonth {
  final String apiValue;

  final String displayName;

  const TargetMonth({required this.apiValue, required this.displayName});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TargetMonth &&
            runtimeType == other.runtimeType &&
            apiValue == other.apiValue;
  }

  @override
  int get hashCode => apiValue.hashCode;
}
