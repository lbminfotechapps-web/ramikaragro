import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:solufine/core/di/self_target_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import 'package:solufine/features/assign_target_point_wise/domain/entities/target_group_entity.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_bloc.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_event.dart';
import 'package:solufine/features/assign_target_point_wise/presentation/bloc/self_target_state.dart';

class SelfTargetPage extends StatefulWidget {
  const SelfTargetPage({
    super.key,
  });

  @override
  State<SelfTargetPage> createState() =>
      _SelfTargetPageState();
}

class _SelfTargetPageState
    extends State<SelfTargetPage> {
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

  final TextEditingController pointController =
      TextEditingController();

  final FocusNode pointFocusNode =
      FocusNode();

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
      final userData =
          await SecureStorage.instance.getUserData();

      if (!mounted) {
        return;
      }

      final String loadedUserId =
          userData?['user_id']?.toString() ?? '';

      setState(() {
        userId = loadedUserId;
        isLoadingUser = false;
      });

      debugPrint(
        '========================================',
      );

      debugPrint(
        'SELF TARGET',
      );

      debugPrint(
        'USER ID = $userId',
      );

      debugPrint(
        'DEFAULT MONTH = '
        '${selectedMonth?.apiValue}',
      );

      debugPrint(
        '========================================',
      );

      if (userId.trim().isEmpty) {
        _showMessage(
          'User information not found',
        );

        return;
      }

      // ========================================================
      // SET DEFAULT MONTH IN BLOC
      // ========================================================

      if (selectedMonth != null) {
        bloc.add(
          ChangeSelfTargetMonthEvent(
            month: selectedMonth!.apiValue,
          ),
        );
      }

      // ========================================================
      // LOAD PRODUCT GROUP
      // ========================================================

      bloc.add(
        const GetSelfTargetEvent(),
      );
    } catch (e) {
      debugPrint(
        'SELF TARGET USER ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingUser = false;
      });

      _showMessage(
        'Unable to load user information',
      );
    }
  }

  // ============================================================
  // MONTHS
  // ============================================================

  List<TargetMonth> _generateMonths() {
    final DateTime now =
        DateTime.now();

    final List<TargetMonth> list = [];

    for (int index = 0;
        index < 4;
        index++) {
      final DateTime date =
          DateTime(
        now.year,
        now.month + index,
        1,
      );

      list.add(
        TargetMonth(
          apiValue:
              '${date.year}-${date.month.toString().padLeft(2, '0')}',

          displayName:
              '${_monthName(date.month)} ${date.year}',
        ),
      );
    }

    return list;
  }

  String _monthName(
    int month,
  ) {
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
      _showMessage(
        'User information not available',
      );

      return;
    }

    // ----------------------------------------------------------
    // MONTH
    // ----------------------------------------------------------

    if (selectedMonth == null) {
      _showMessage(
        'Please select target month',
      );

      return;
    }

    // ----------------------------------------------------------
    // POINT
    // ----------------------------------------------------------

    final String point =
        pointController.text.trim();

    if (point.isEmpty) {
      _showMessage(
        'Please enter your target point',
      );

      pointFocusNode.requestFocus();

      return;
    }

    final double? value =
        double.tryParse(
      point,
    );

    if (value == null ||
        value <= 0) {
      _showMessage(
        'Please enter valid target point',
      );

      pointFocusNode.requestFocus();

      return;
    }

    debugPrint(
      '========================================',
    );

    debugPrint(
      'SUBMIT SELF TARGET',
    );

    debugPrint(
      'USER ID = $userId',
    );

    debugPrint(
      'MONTH = ${selectedMonth!.apiValue}',
    );

    debugPrint(
      'POINTS = $point',
    );

    debugPrint(
      '========================================',
    );

    bloc.add(
      SubmitSelfTargetEvent(
        userId: userId,
        month: selectedMonth!.apiValue,
        groupId:"",
        points: point,
      ),
    );
  }


   

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,

          backgroundColor:
              AppColors.error,

          margin:
              const EdgeInsets.all(
            12,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          content: Text(
            message,

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Future<void> _showSuccessDialog(
    String message,
  ) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder:
          (dialogContext) {
        return AlertDialog(
          backgroundColor:
              Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          contentPadding:
              const EdgeInsets.fromLTRB(
            22,
            24,
            22,
            18,
          ),

          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 68,
                height: 68,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFEAF7EE,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons
                      .check_circle_rounded,

                  color:
                      Color(
                    0xFF166534,
                  ),

                  size: 46,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              const Text(
                'Target Submitted',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  fontSize: 18,

                  fontWeight:
                      FontWeight.w800,

                  color:
                      Color(
                    0xFF17201B,
                  ),
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                message,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 12,

                  height: 1.4,

                  color:
                      Color(
                    0xFF66736B,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

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
                    Navigator.pop(
                      dialogContext,
                    );

                    // Go to Home
                    context.go(
                      AppRouter.home,
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF166534,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'Done',

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),


            ],
          ),
        );
      },
    );
  }


   Future<void> _showFailureDialog(
  String message,
) async {
  if (!mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(
            milliseconds: 300,
          ),
          tween: Tween(
            begin: 0.85,
            end: 1.0,
          ),
          curve: Curves.easeOutBack,
          builder: (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              22,
              28,
              22,
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                24,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.15,
                  ),
                  blurRadius: 30,
                  offset: const Offset(
                    0,
                    12,
                  ),
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

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Target Already Added',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(
                      0xFF17201B,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // API MESSAGE
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(
                      0xFF66736B,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFDC2626,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 19,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Try Next Month',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                          ),
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
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider.value(
      value: bloc,

      child:
          BlocConsumer<
              SelfTargetBloc,
              SelfTargetState>(
        listener:
            (
          context,
          state,
        ) {
          // ====================================================
          // SUCCESS
          // ====================================================

          if (state.status ==
              SelfTargetStatus
                  .submitSuccess) {
            _showSuccessDialog(
              state.message
                      .trim()
                      .isEmpty
                  ? 'Self target submitted successfully.'
                  : state.message,
            );

            return;
          }

        
        // ====================================================
        // FAILURE
        // ====================================================

        if (state.status ==
            SelfTargetStatus.failure) {
          _showFailureDialog(
            state.message.trim().isEmpty
                ? 'Something went wrong. Please try again.'
                : state.message,
          );

          return;
        }
      },

        builder:
            (
          context,
          state,
        ) {
          return Scaffold(
            backgroundColor:
                const Color(
              0xFFF5F7F6,
            ),

            appBar:
                CustomAppBar(
              title:
                  'efwarfWRG',

              showBackButton:
                  true,

              onBackTap:
                  () {
                Navigator.pop(
                  context,
                );
              },
            ),

            body:
                _buildBody(
              state,
            ),

            bottomNavigationBar:
                _buildSubmitButton(
              state,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
    SelfTargetState state,
  ) {
    if (isLoadingUser) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              Color(
            0xFF166534,
          ),
        ),
      );
    }

    if (state.status ==
            SelfTargetStatus.loading &&
        state.groups.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              Color(
            0xFF166534,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color:
          const Color(
        0xFF166534,
      ),

      onRefresh:
          () async {
        bloc.add(
          const GetSelfTargetEvent(),
        );
      },

      child:
          SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          82,
        ),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HERO
            // ==================================================

            _buildHeroCard(),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // PRODUCT GROUP FIRST
            // ==================================================

            _buildGroupSection(
              state,
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // MONTH BELOW GROUP
            // ==================================================

            _buildMonthCard(),

            const SizedBox(
              height: 8,
            ),

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
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,

          colors: [
            Color(
              0xFF14532D,
            ),

            Color(
              0xFF1C7A45,
            ),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF166534,
            ).withOpacity(
              .14,
            ),

            blurRadius: 12,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child:
          Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                .15,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child:
                const Icon(
              Icons
                  .track_changes_rounded,

              color:
                  Colors.white,

              size: 23,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Self Target',

                  style:
                      TextStyle(
                    color:
                        Colors.white,

                    fontSize: 16,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  'Review group points and assign your monthly target.',

                  style:
                      TextStyle(
                    color:
                        Colors.white70,

                    fontSize: 9.5,
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

  Widget _buildGroupSection(
    SelfTargetState state,
  ) {
    double totalPoints =
        0;

    for (final group
        in state.groups) {
      totalPoints +=
          group.groupPointsValue;
    }

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE5EAE7,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(
              .02,
            ),

            blurRadius: 8,

            offset:
                const Offset(
              0,
              2,
            ),
          ),
        ],
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Row(
            children: [
              Container(
                height: 34,
                width: 34,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF6EE,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .category_rounded,

                  size: 18,

                  color:
                      Color(
                    0xFF166534,
                  ),
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      'Product Groups',

                      style:
                          TextStyle(
                        fontSize: 14,

                        fontWeight:
                            FontWeight
                                .w800,

                        color:
                            Color(
                          0xFF17201B,
                        ),
                      ),
                    ),

                    Text(
                      'Group-wise point details',

                      style:
                          TextStyle(
                        fontSize: 9,

                        color:
                            Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF0FDF4,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                    Text(
                  '${_formatPoint(totalPoints)} Amt/Pts',

                  style:
                      const TextStyle(
                    fontSize: 10,

                    fontWeight:
                        FontWeight.w800,

                    color:
                        Color(
                      0xFF166534,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          if (state.groups.isEmpty)
            _buildEmpty()
          else
            ...state.groups
                .asMap()
                .entries
                .map(
              (entry) {
                return Padding(
                  padding:
                      EdgeInsets.only(
                    bottom:
                        entry.key ==
                                state.groups.length -
                                    1
                            ? 0
                            : 6,
                  ),

                  child:
                      _buildCompactGroupCard(
                    group:
                        entry.value,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT GROUP CARD
  // ============================================================

  Widget _buildCompactGroupCard({
    required TargetGroupEntity group,
  }) {
    return Container(
      height: 56,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF8FAF9,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE7ECE9,
          ),
        ),
      ),

      child:
          Row(
        children: [
          // GROUP LETTER

          Container(
            height: 36,
            width: 36,

            // decoration:
            //     BoxDecoration(
            //   gradient:
            //       const LinearGradient(
            //     colors: [
            //       Color(
            //         0xFF166534,
            //       ),

            //       Color(
            //         0xFF2A9255,
            //       ),
            //     ],
            //   ),

            //   borderRadius:
            //       BorderRadius.circular(
            //     10,
            //   ),
            // ),

            alignment:
                Alignment.center,

            child:
                Text(
              group.groupType,

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize: 16,

                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          // GROUP TITLE

          Expanded(
            child:
                Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  '${group.groupType}',

                  style:
                      const TextStyle(
                    fontSize: 12.5,

                    fontWeight:
                        FontWeight.w700,

                    color:
                        Color(
                      0xFF17201B,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),

              
              ],
            ),
          ),

          // POINT VALUE

          Container(
            constraints:
                const BoxConstraints(
              minWidth: 72,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF6EE,
              ),

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Text(
                  _formatPoint(
                    group.groupPointsValue,
                  ),

                  style:
                      const TextStyle(
                    fontSize: 13,

                    fontWeight:
                        FontWeight.w900,

                    color:
                        Color(
                      0xFF166534,
                    ),
                  ),
                ),

                const Text(
                  'POINTS',

                  style:
                      TextStyle(
                    fontSize: 6.5,

                    letterSpacing: .5,

                    fontWeight:
                        FontWeight.w600,

                    color:
                        Color(
                      0xFF779280,
                    ),
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
      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE5EAE7,
          ),
        ),
      ),

      child:
          Row(
        children: [
          Container(
            height: 38,
            width: 38,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF6EE,
              ),

              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),

            child:
                const Icon(
              Icons
                  .calendar_month_rounded,

              color:
                  Color(
                0xFF166534,
              ),

              size: 19,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Expanded(
            flex: 2,

            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Target Month',

                  style:
                      TextStyle(
                    fontSize: 12.5,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                Text(
                  'Select month',

                  style:
                      TextStyle(
                    fontSize: 8.5,

                    color:
                        Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            flex: 3,

            child:
                DropdownButtonFormField<
                    TargetMonth>(
              value:
                  selectedMonth,

              isExpanded:
                  true,

              icon:
                  const Icon(
                Icons
                    .keyboard_arrow_down_rounded,

                size: 20,

                color:
                    Color(
                  0xFF166534,
                ),
              ),

              decoration:
                  InputDecoration(
                filled: true,

                fillColor:
                    const Color(
                  0xFFF7F9F8,
                ),

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 9,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  borderSide:
                      BorderSide.none,
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  borderSide:
                      const BorderSide(
                    color:
                        Color(
                      0xFFE2E8E4,
                    ),
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  borderSide:
                      const BorderSide(
                    color:
                        Color(
                      0xFF166534,
                    ),
                  ),
                ),
              ),

              items:
                  months.map(
                (month) {
                  return DropdownMenuItem<
                      TargetMonth>(
                    value:
                        month,

                    child:
                        Text(
                      month.displayName,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        fontSize: 11,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                setState(() {
                  selectedMonth =
                      value;
                });

                bloc.add(
                  ChangeSelfTargetMonthEvent(
                    month:
                        value.apiValue,
                  ),
                );
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
      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF0FDF4,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFC6E6CF,
          ),
        ),
      ),

      child:
          Row(
        children: [
          Container(
            height: 40,
            width: 40,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF166534,
              ),

              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),

            child:
                const Icon(
              Icons
                  .edit_note_rounded,

              color:
                  Colors.white,

              size: 22,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Enter Your Point',

                  style:
                      TextStyle(
                    fontSize: 12.5,

                    fontWeight:
                        FontWeight.w800,

                    color:
                        Color(
                      0xFF17201B,
                    ),
                  ),
                ),

                SizedBox(
                  height: 1,
                ),

                Text(
                  'Monthly target',

                  style:
                      TextStyle(
                    fontSize: 8.5,

                    color:
                        Color(
                      0xFF66736B,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          SizedBox(
            width: 145,

            child:
                TextFormField(
              controller:
                  pointController,

              focusNode:
                  pointFocusNode,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal:
                    true,
              ),

              inputFormatters: [
                FilteringTextInputFormatter
                    .allow(
                  RegExp(
                    r'^\d*\.?\d{0,2}',
                  ),
                ),
              ],

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 15,

                fontWeight:
                    FontWeight.w800,

                color:
                    Color(
                  0xFF17201B,
                ),
              ),

              decoration:
                  InputDecoration(
                hintText:
                    '0',

                suffixText:
                    'Amt/Pts',

                suffixStyle:
                    const TextStyle(
                  fontSize: 9,

                  color:
                      Color(
                    0xFF166534,
                  ),

                  fontWeight:
                      FontWeight.w700,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  borderSide:
                      const BorderSide(
                    color:
                        Color(
                      0xFFCCE4D3,
                    ),
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  borderSide:
                      const BorderSide(
                    color:
                        Color(
                      0xFF166534,
                    ),

                    width: 1.4,
                  ),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
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
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 22,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF8FAF9,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child:
          const Column(
        children: [
          Icon(
            Icons
                .inventory_2_outlined,

            size: 30,

            color:
                Color(
              0xFF92A099,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'No product groups available',

            style:
                TextStyle(
              fontSize: 10.5,

              fontWeight:
                  FontWeight.w600,

              color:
                  Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton(
    SelfTargetState state,
  ) {
    final bool loading =
        state.status ==
            SelfTargetStatus.submitting;

    return SafeArea(
      top: false,

      child:
          Container(
        padding:
            const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          8,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          border:
              const Border(
            top:
                BorderSide(
              color:
                  Color(
                0xFFE6EBE8,
              ),
            ),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withOpacity(
                .045,
              ),

              blurRadius: 10,

              offset:
                  const Offset(
                0,
                -2,
              ),
            ),
          ],
        ),

        child:
            SizedBox(
          height: 47,

          width:
              double.infinity,

          child:
              ElevatedButton(
            onPressed:
                loading
                    ? null
                    : _submit,

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF166534,
              ),

              foregroundColor:
                  Colors.white,

              disabledBackgroundColor:
                  const Color(
                0xFF8EB398,
              ),

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
            ),

            child:
                loading
                    ? const SizedBox(
                        width: 20,

                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.2,

                          color:
                              Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Icon(
                            Icons
                                .task_alt_rounded,

                            size: 19,
                          ),

                          SizedBox(
                            width: 7,
                          ),

                          Text(
                            'Submit Target',

                            style:
                                TextStyle(
                              fontSize: 13.5,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
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

  String _formatPoint(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value.toStringAsFixed(
        0,
      );
    }

    return value.toStringAsFixed(
      2,
    );
  }
}

// =============================================================================
// TARGET MONTH
// =============================================================================

class TargetMonth {
  final String apiValue;

  final String displayName;

  const TargetMonth({
    required this.apiValue,
    required this.displayName,
  });

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(
          this,
          other,
        ) ||
        other is TargetMonth &&
            runtimeType ==
                other.runtimeType &&
            apiValue ==
                other.apiValue;
  }

  @override
  int get hashCode =>
      apiValue.hashCode;
}