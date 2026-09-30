import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/app_dialog.dart';
import 'package:solufine/core/utility/image_compression.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/expense_parameter_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({
    super.key,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final openingKm = TextEditingController();
  final closingKm = TextEditingController();
  final totalKm = TextEditingController();
  final amountController = TextEditingController();
  final placeController = TextEditingController();
  final remarkController = TextEditingController();
  final dateController = TextEditingController();
  final daAmountController = TextEditingController();

  // ===========================================================================
  // STATE
  // ===========================================================================

  DateTime selectedDate = DateTime.now();

  DialogRoute<void>? _submissionDialog;

  String? daType;

  int? userId;

  double vehicleRate = 0;
  double travelAmount = 0;
  double extraExpenseTotal = 0;
  double finalTotalAmount = 0;
  double enteredKM = 0;

  final Map<String, TextEditingController> _expenseAmountControllers = {};

  // ===========================================================================
  // EXPENSE HELPERS
  // ===========================================================================

  bool _isTravelExpense(
    ExpenseParameterEntity expense,
  ) {
    final name = expense.fldExpName.trim().toLowerCase();

    return RegExp(
      r'\b(travel|traveling|travelling|travaling|traving)\b',
    ).hasMatch(name);
  }

  double _expenseAmount(
    ExpenseParameterEntity expense,
  ) {
    return _isTravelExpense(expense)
        ? double.tryParse(amountController.text) ?? 0
        : expense.amount;
  }

  TextEditingController _getExpenseAmountController(
    ExpenseParameterEntity expense,
  ) {
    final key = expense.fldExpId.toString();

    if (!_expenseAmountControllers.containsKey(key)) {
      _expenseAmountControllers[key] = TextEditingController(
        text: expense.amount > 0
            ? expense.amount.toString()
            : '',
      );
    }

    return _expenseAmountControllers[key]!;
  }

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(
      selectedDate,
    );

    _loadInitialExpenses();
  }

  Future<void> _loadInitialExpenses() async {
    final userData =
        await SecureStorage.instance.getUserData();

    userId = int.tryParse(
      userData?['user_id']?.toString() ?? '',
    );

    if (!mounted) {
      return;
    }

    context.read<ExpenseBloc>().add(
          LoadExpenseEvent(
            userId: userId.toString(),
            date: formatDate(
              dateController.text,
            ),
          ),
        );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    openingKm.dispose();
    closingKm.dispose();
    totalKm.dispose();
    amountController.dispose();
    placeController.dispose();
    remarkController.dispose();
    dateController.dispose();
    daAmountController.dispose();

    for (final controller in _expenseAmountControllers.values) {
      controller.dispose();
    }

    _expenseAmountControllers.clear();

    super.dispose();
  }

  // ===========================================================================
  // DATE FORMAT
  // ===========================================================================

  String formatDate(
    String value,
  ) {
    final clean = value.split(' ').first;

    final date = DateFormat(
      'dd-MM-yyyy',
    ).parse(
      clean,
    );

    return DateFormat(
      'yyyy-MM-dd',
    ).format(
      date,
    );
  }

  // ===========================================================================
  // CALCULATE KM
  // ===========================================================================

  void calculateKM(
    ExpenseState state,
  ) {
    final open =
        double.tryParse(openingKm.text) ?? 0;

    final close =
        double.tryParse(closingKm.text) ?? 0;

    double total = close - open;

    if (total < 0) {
      total = 0;
    }

    enteredKM = total;

    totalKm.text = total.toStringAsFixed(0);

    travelAmount = total * vehicleRate;

    final da =
        double.tryParse(
          daAmountController.text,
        ) ??
        0;

    finalTotalAmount =
        travelAmount +
        da +
        extraExpenseTotal;

    amountController.text =
        travelAmount.toStringAsFixed(2);

    setState(() {});
  }

  // ===========================================================================
  // VEHICLE
  // ===========================================================================

  void selectVehicle(
    VehicleEntity vehicle,
  ) {
    vehicleRate =
        double.tryParse(
          vehicle.fldVehicleRateAdmin,
        ) ??
        0;

    openingKm.text =
        vehicle.fldStartingKm.isEmpty
        ? '0'
        : vehicle.fldStartingKm;

    closingKm.text =
        vehicle.fldClosingKm.isEmpty
        ? '0'
        : vehicle.fldClosingKm;

    calculateKM(
      context.read<ExpenseBloc>().state,
    );
  }

  // ===========================================================================
  // DATE
  // ===========================================================================

  Future<void> pickDate(
    ExpenseState state,
  ) async {
    print(
      'days is :${state.allowedDays}',
    );

    final today = DateTime.now();

    final firstAllowed = today.subtract(
      Duration(
        days: state.allowedDays,
      ),
    );

    final picked =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstAllowed,
      lastDate: today,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;

      dateController.text =
          DateFormat(
        'dd-MM-yyyy',
      ).format(
        picked,
      );
    });

    context.read<ExpenseBloc>().add(
          ChangeExpenseDateEvent(
            userId: userId.toString(),
            date: formatDate(
              dateController.text,
            ),
          ),
        );
  }

  // ===========================================================================
  // DA
  // ===========================================================================

  void selectDaType(
    String? value,
    ExpenseState state,
  ) {
    if (value == null) {
      return;
    }

    calculateKM(state);

    final kmLimit = state.apiKmLimit;

    if (enteredKM < kmLimit &&
        state.fldOpeningClosingKm == '1') {
      AppDialog.show(
        context: context,
        message:
            'DA is not applicable for this trip. Minimum required distance is $kmLimit KM.',
        type: DialogType.error,
      );

      setState(() {
        daType = null;
      });

      return;
    }

    if (value == 'DA') {
      if (state.localDa <= 0) {
        AppDialog.show(
          context: context,
          message:
              'You are not applicable for DA',
          type: DialogType.error,
        );

        setState(() {
          daType = null;

          daAmountController.clear();
        });

        calculateKM(state);

        return;
      }

      setState(() {
        daType = value;

        daAmountController.text =
            state.localDa.toStringAsFixed(2);
      });
    }

    if (value == 'NIGHT') {
      if (state.nightDa <= 0) {
        AppDialog.show(
          context: context,
          message:
              'You are not applicable for Night Halt DA',
          type: DialogType.error,
        );

        setState(() {
          daType = null;

          daAmountController.clear();
        });

        calculateKM(state);

        return;
      }

      setState(() {
        daType = value;

        daAmountController.text =
            state.nightDa.toStringAsFixed(2);
      });
    }

    calculateKM(state);
  }

  // ===========================================================================
  // FIELD
  // ===========================================================================

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    IconData? icon,
    double bottomPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w500,
          color: const Color(
            0xFF26302B,
          ),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(
              0xFF75807A,
            ),
            fontSize: 11.5.sp,
          ),
          floatingLabelStyle:
              TextStyle(
            color: const Color(
              0xFF118F49,
            ),
            fontWeight:
                FontWeight.w600,
            fontSize: 11.5.sp,
          ),
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: const Color(
                    0xFF13974E,
                  ),
                  size: 19.sp,
                ),
          filled: true,
          fillColor: readOnly
              ? const Color(
                  0xFFF4F6F5,
                )
              : Colors.white,
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12.r,
            ),
            borderSide:
                const BorderSide(
              color: Color(
                0xFFE0E7E3,
              ),
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12.r,
            ),
            borderSide:
                const BorderSide(
              color: Color(
                0xFFE0E7E3,
              ),
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12.r,
            ),
            borderSide:
                const BorderSide(
              color: Color(
                0xFF11934A,
              ),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocListener<
        ExpenseBloc,
        ExpenseState>(
      listenWhen:
          (previous, current) =>
              previous.status !=
              current.status,
      listener:
          (context, state) {
        if (state.status !=
            ExpenseStatus.submitting) {
          final dialog =
              _submissionDialog;

          _submissionDialog = null;

          if (dialog != null &&
              dialog.isActive) {
            dialog.navigator
                ?.removeRoute(
              dialog,
            );
          }
        }

        if (state.status ==
            ExpenseStatus.error) {
          AppDialog.show(
            context: context,
            message:
                state.errorMessage,
            type:
                DialogType.error,
          );
        }

        if (state.status ==
            ExpenseStatus.success) {
          AppDialog.show(
            context: context,
            message:
                state.successMessage ??
                'Expense Submit Successfully',
            type:
                DialogType.success,
            onOkPressed: () {
              if (context.mounted) {
                context.go(
                  AppRouter.home,
                );
              }
            },
          );
        }

        if (state.status ==
            ExpenseStatus.submitting) {
          final dialog =
              DialogRoute<void>(
            context: context,
            barrierDismissible:
                false,
            builder: (_) =>
                const PopScope(
              canPop: false,
              child: AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        'Submitting expense...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          _submissionDialog =
              dialog;

          Navigator.of(
            context,
            rootNavigator: true,
          ).push(
            dialog,
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            const Color(
          0xFFF4F7F5,
        ),
        appBar: CustomAppBar(
          title: 'Add Expense',
          showBackButton: true,
          onBackTap: () =>
              context.go(
            AppRouter.home,
          ),
        ),
        body: BlocBuilder<
            ExpenseBloc,
            ExpenseState>(
          builder:
              (context, state) {
            if (state.status ==
                ExpenseStatus.loading) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              padding:
                  EdgeInsets.fromLTRB(
                14.w,
                10.h,
                14.w,
                20.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _expenseHeader(),

                  SizedBox(
                    height: 12.h,
                  ),

                  _dateSelector(
                    state,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  if (state.expStatus ==
                          0 ||
                      state.expStatus ==
                          -1)
                    _buildExpenseForm(
                      state,
                    )
                  else if (state
                          .expStatus ==
                      1)
                    _buildStatus(
                      Icons
                          .check_circle_rounded,
                      Colors.green,
                      'Expenses Already Entered',
                    )
                  else if (state
                          .expStatus ==
                      2)
                    _buildStatus(
                      Icons
                          .warning_amber_rounded,
                      Colors.orange,
                      'You Have Not Out-Punched Yet',
                    )
                  else
                    _buildStatus(
                      Icons
                          .error_outline_rounded,
                      Colors.grey,
                      'You have not in-punched and out-punched',
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _expenseHeader() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(
              0xFF08783D,
            ),
            Color(
              0xFF12A052,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF11934A,
            ).withOpacity(
              0.16,
            ),
            blurRadius: 14,
            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30.w,
            top: -35.h,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withOpacity(
                  0.06,
                ),
                shape:
                    BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withOpacity(
                    0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13.r,
                  ),
                ),
                child: Icon(
                  Icons
                      .receipt_long_rounded,
                  color:
                      Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(
                width: 11.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Daily Expense',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            16.sp,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Review travel and add today\'s expenses',
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: TextStyle(
                        color: Colors
                            .white
                            .withOpacity(
                          0.82,
                        ),
                        fontSize:
                            10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 5.h,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withOpacity(
                    0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20.r,
                  ),
                ),
                child: Text(
                  'EXPENSE',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        8.5.sp,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DATE
  // ===========================================================================

  Widget _dateSelector(
    ExpenseState state,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            pickDate(
          state,
        ),
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              14.r,
            ),
            border: Border.all(
              color: const Color(
                0xFFE3E9E6,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xFFE7F6EC,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10.r,
                  ),
                ),
                child: Icon(
                  Icons
                      .calendar_month_rounded,
                  color: const Color(
                    0xFF11934A,
                  ),
                  size: 18.sp,
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Expense Date',
                      style: TextStyle(
                        color:
                            const Color(
                          0xFF7C8580,
                        ),
                        fontSize:
                            9.5.sp,
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text(
                      dateController
                          .text,
                      style: TextStyle(
                        color:
                            const Color(
                          0xFF26302B,
                        ),
                        fontSize:
                            13.sp,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color: const Color(
                  0xFF7D8681,
                ),
                size: 21.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EXPENSE FORM
  // ===========================================================================

  Widget _buildExpenseForm(
    ExpenseState state,
  ) {
    final vehicle =
        state.selectedVehicle;

    if (vehicle != null &&
        openingKm.text.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          selectVehicle(
            vehicle,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.route_rounded,
          'Trip Details',
        ),

        SizedBox(
          height: 7.h,
        ),

        _modernCard(
          child: Column(
            children: [
              buildField(
                'Visited Place *',
                placeController,
                icon: Icons
                    .location_on_rounded,
              ),

              SizedBox(
                height: 9.h,
              ),

              _vehicleCard(
                state,
              ),

              SizedBox(
                height: 9.h,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildField(
                      'Opening KM',
                      openingKm,
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: buildField(
                      'Closing KM',
                      closingKm,
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: buildField(
                      'Total KM',
                      totalKm,
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 9.h,
              ),

              buildField(
                'Traveling Amount',
                amountController,
                readOnly: true,
                icon: Icons
                    .currency_rupee_rounded,
              ),
            ],
          ),
        ),

        SizedBox(
          height: 12.h,
        ),

        _sectionTitle(
          Icons
              .account_balance_wallet_rounded,
          'DA Details',
        ),

        SizedBox(
          height: 7.h,
        ),

        _modernCard(
          child: Row(
            children: [
              Expanded(
                child: _daDropdown(
                  state,
                ),
              ),
              SizedBox(
                width: 9.w,
              ),
              Expanded(
                child: buildField(
                  'DA Amount',
                  daAmountController,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 12.h,
        ),

        _sectionTitle(
          Icons.add_card_rounded,
          'Other Expenses',
        ),

        SizedBox(
          height: 7.h,
        ),

        InkWell(
          onTap: () {
            showExpenseSheet(
              state,
            );
          },
          borderRadius:
              BorderRadius.circular(
            14.r,
          ),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(
              horizontal: 13.w,
              vertical: 11.h,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                14.r,
              ),
              border: Border.all(
                color: const Color(
                  0xFFDCE7E1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFE7F6EC,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10.r,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .add_rounded,
                    color:
                        const Color(
                      0xFF11934A,
                    ),
                    size: 21.sp,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Add Expenses',
                        style:
                            TextStyle(
                          color:
                              const Color(
                            0xFF26302B,
                          ),
                          fontSize:
                              12.5.sp,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      Text(
                        'Select receipt from gallery and enter amount',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color:
                              const Color(
                            0xFF89928D,
                          ),
                          fontSize:
                              9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color:
                      const Color(
                    0xFF8B948F,
                  ),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          height: 12.h,
        ),

        _totalCard(),

        SizedBox(
          height: 10.h,
        ),

        _modernCard(
          child: TextField(
            controller:
                remarkController,
            minLines: 1,
            maxLines: 2,
            decoration:
                InputDecoration(
              hintText: 'Remark',
              prefixIcon: Icon(
                Icons
                    .edit_note_rounded,
                color:
                    const Color(
                  0xFF11934A,
                ),
              ),
              filled: true,
              fillColor:
                  const Color(
                0xFFF8FAF9,
              ),
              isDense: true,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  11.r,
                ),
                borderSide:
                    const BorderSide(
                  color: Color(
                    0xFFE2E8E4,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          height: 12.h,
        ),

        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  const Color(
                0xFF11934A,
              ),
              foregroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14.r,
                ),
              ),
            ),
            onPressed: () {
              if (placeController.text
                  .trim()
                  .isEmpty) {
                AppDialog.show(
                  context: context,
                  message:
                      'Please Enter Visited Place',
                  type:
                      DialogType.error,
                );

                return;
              }

              submitExpense(
                state,
              );
            },
            child: Text(
              'SUBMIT EXPENSE',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION
  // ===========================================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 29.w,
          height: 29.w,
          decoration: BoxDecoration(
            color: const Color(
              0xFFE7F6EC,
            ),
            borderRadius:
                BorderRadius.circular(
              8.r,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(
              0xFF11934A,
            ),
            size: 15.sp,
          ),
        ),
        SizedBox(
          width: 7.w,
        ),
        Text(
          title,
          style: TextStyle(
            color: const Color(
              0xFF202823,
            ),
            fontSize: 13.sp,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _modernCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        10.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          15.r,
        ),
        border: Border.all(
          color: const Color(
            0xFFE5EBE7,
          ),
        ),
      ),
      child: child,
    );
  }

  // ===========================================================================
  // VEHICLE
  // ===========================================================================

  Widget _vehicleCard(
    ExpenseState state,
  ) {
    return IgnorePointer(
      child: Container(
        height: 47.h,
        padding:
            EdgeInsets.symmetric(
          horizontal: 11.w,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFF4F6F5,
          ),
          borderRadius:
              BorderRadius.circular(
            12.r,
          ),
          border: Border.all(
            color: const Color(
              0xFFE0E7E3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons
                  .directions_car_filled_rounded,
              color: const Color(
                0xFF11934A,
              ),
              size: 19.sp,
            ),
            SizedBox(
              width: 9.w,
            ),
            Expanded(
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<
                        VehicleEntity>(
                  value:
                      state.selectedVehicle,
                  isExpanded: true,
                  items:
                      state.vehicles.map(
                    (vehicle) {
                      return DropdownMenuItem<
                          VehicleEntity>(
                        value: vehicle,
                        child: Text(
                          vehicle
                              .fldVehicleType,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DA
  // ===========================================================================

  Widget _daDropdown(
    ExpenseState state,
  ) {
    return DropdownButtonFormField<String>(
      value: daType,
      isExpanded: true,
      isDense: true,
      hint: const Text(
        'Select DA Type',
      ),
      decoration:
          InputDecoration(
        filled: true,
        fillColor:
            Colors.white,
        isDense: true,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12.r,
          ),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'DA',
          child: Text(
            'DA',
          ),
        ),
        DropdownMenuItem(
          value: 'NIGHT',
          child: Text(
            'Night Halt DA',
          ),
        ),
      ],
      onChanged: (value) =>
          selectDaType(
        value,
        state,
      ),
    );
  }

  // ===========================================================================
  // TOTAL
  // ===========================================================================

  Widget _totalCard() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 11.h,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFE8F7EE,
        ),
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        border: Border.all(
          color: const Color(
            0xFFD6EBDE,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments_rounded,
            color: const Color(
              0xFF11934A,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          const Expanded(
            child: Text(
              'Total Amount',
            ),
          ),
          Text(
            '₹ ${finalTotalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: const Color(
                0xFF0C8E44,
              ),
              fontSize: 16.sp,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _buildStatus(
    IconData icon,
    Color color,
    String text,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 35.h,
      ),
      padding:
          EdgeInsets.symmetric(
        vertical: 28.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48.sp,
            color: color,
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            text,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EXPENSE SHEET
  // ===========================================================================

  void showExpenseSheet(
    ExpenseState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder:
          (sheetContext) {
        return Padding(
          padding:
              EdgeInsets.only(
            bottom:
                MediaQuery.of(
              sheetContext,
            ).viewInsets.bottom,
          ),
          child: Container(
            height:
                MediaQuery.of(
                      sheetContext,
                    ).size.height *
                    0.82,
            padding:
                EdgeInsets.fromLTRB(
              14.w,
              10.h,
              14.w,
              12.h,
            ),
            decoration:
                BoxDecoration(
              color: const Color(
                0xFFF8FAF9,
              ),
              borderRadius:
                  BorderRadius.vertical(
                top:
                    Radius.circular(
                  22.r,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 4.h,
                  width: 42.w,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFD5DBD8,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10.r,
                    ),
                  ),
                ),

                SizedBox(
                  height: 10.h,
                ),

                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE7F6EC,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10.r,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .photo_library_rounded,
                        color:
                            const Color(
                          0xFF11934A,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 9.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Add Expenses',
                            style:
                                TextStyle(
                              fontSize:
                                  15.sp,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          Text(
                            'Enter amount and select receipt from gallery',
                            style:
                                TextStyle(
                              fontSize:
                                  9.5.sp,
                              color:
                                  const Color(
                                0xFF8A938E,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(
                        sheetContext,
                      ),
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 8.h,
                ),

                Expanded(
                  child: BlocBuilder<
                      ExpenseBloc,
                      ExpenseState>(
                    builder:
                        (
                      blocContext,
                      currentState,
                    ) {
                      return ListView.builder(
                        itemCount:
                            currentState
                                .expenses
                                .length,
                        itemBuilder:
                            (
                          listContext,
                          index,
                        ) {
                          final item =
                              currentState
                                  .expenses[
                              index];

                          final isTravelExpense =
                              _isTravelExpense(
                            item,
                          );

                          final expenseAmountController =
                              isTravelExpense
                              ? amountController
                              : _getExpenseAmountController(
                                  item,
                                );

                          if (!isTravelExpense &&
                              (!expenseAmountController
                                      .selection
                                      .isValid ||
                                  !expenseAmountController
                                      .selection
                                      .isDirectional)) {
                            final expectedText =
                                item.amount > 0
                                ? item.amount
                                    .toString()
                                : '';

                            if (expenseAmountController
                                        .text !=
                                    expectedText &&
                                !expenseAmountController
                                    .selection
                                    .isValid) {
                              expenseAmountController
                                      .text =
                                  expectedText;
                            }
                          }

                          return _expenseItemCard(
                            sheetContext:
                                sheetContext,
                            item: item,
                            index: index,
                            isTravelExpense:
                                isTravelExpense,
                            controller:
                                expenseAmountController,
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(
                  height: 8.h,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(
                          sheetContext,
                        ),
                        child:
                            const Text(
                          'Cancel',
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 9.w,
                    ),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF11934A,
                          ),
                          foregroundColor:
                              Colors.white,
                        ),
                        onPressed: () {
                          final currentState =
                              context
                                  .read<
                                      ExpenseBloc>()
                                  .state;

                          double tempTotal =
                              0.0;

                          for (final expense
                              in currentState
                                  .expenses) {
                            final hasAmount =
                                _expenseAmount(
                                      expense,
                                    ) >
                                    0;

                            final hasImage =
                                expense
                                        .imageFile !=
                                    null;

                            if (!_isTravelExpense(
                                  expense,
                                ) &&
                                hasAmount &&
                                !hasImage) {
                              Fluttertoast
                                  .showToast(
                                msg:
                                    'Please select image for ${expense.fldExpName}',
                                toastLength:
                                    Toast
                                        .LENGTH_SHORT,
                                gravity:
                                    ToastGravity
                                        .BOTTOM,
                              );

                              return;
                            }

                            if (!_isTravelExpense(
                                  expense,
                                ) &&
                                hasImage &&
                                !hasAmount) {
                              Fluttertoast
                                  .showToast(
                                msg:
                                    'Please enter amount for ${expense.fldExpName}',
                                toastLength:
                                    Toast
                                        .LENGTH_SHORT,
                                gravity:
                                    ToastGravity
                                        .BOTTOM,
                              );

                              return;
                            }

                            if (!_isTravelExpense(
                              expense,
                            )) {
                              tempTotal +=
                                  expense
                                      .amount;
                            }
                          }

                          setState(() {
                            extraExpenseTotal =
                                tempTotal;
                          });

                          calculateKM(
                            currentState,
                          );

                          Navigator.pop(
                            sheetContext,
                          );
                        },
                        icon: const Icon(
                          Icons.save,
                        ),
                        label:
                            const Text(
                          'Save',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // EXPENSE ITEM
  // ===========================================================================
  //
  // THIS IS THE MAIN CHANGE:
  //
  // OLD:
  // Navigator.push(... CameraCapturePage())
  //
  // NEW:
  // ImagePicker().pickImage(source: ImageSource.gallery)
  //
  // ===========================================================================

  Widget _expenseItemCard({
    required BuildContext sheetContext,
    required ExpenseParameterEntity item,
    required int index,
    required bool isTravelExpense,
    required TextEditingController controller,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8.h,
      ),
      padding: EdgeInsets.all(
        9.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        border: Border.all(
          color: const Color(
            0xFFE4EAE6,
          ),
        ),
      ),
      child: Row(
        children: [
          // ================================================================
          // GALLERY IMAGE
          // ================================================================

          GestureDetector(
            onTap: isTravelExpense
                ? null
                : () async {
                    FocusScope.of(
                      sheetContext,
                    ).unfocus();

                    try {
                      // =====================================================
                      // NEW - OPEN GALLERY
                      // =====================================================

                      final ImagePicker picker =
                          ImagePicker();

                      final XFile? pickedImage =
                          await picker.pickImage(
                        source:
                            ImageSource.gallery,

                        imageQuality:
                            85,
                      );

                      // User cancelled gallery
                      if (pickedImage ==
                              null ||
                          !mounted ||
                          !sheetContext
                              .mounted) {
                        return;
                      }

                      // =====================================================
                      // SAME EXISTING COMPRESSION
                      // =====================================================

                      final file =
                          await ImageCompression
                              .compressImage(
                        File(
                          pickedImage.path,
                        ),
                        maxWidth: 400,
                        maxHeight: 400,
                        quality: 35,
                      );

                      if (file == null) {
                        throw Exception(
                          'Unable to compress expense image',
                        );
                      }

                      if (!mounted ||
                          !sheetContext
                              .mounted) {
                        return;
                      }

                      final latestState =
                          context
                              .read<
                                  ExpenseBloc>()
                              .state;

                      if (index >=
                          latestState
                              .expenses
                              .length) {
                        return;
                      }

                      final latestExpense =
                          latestState
                              .expenses[index];

                      // =====================================================
                      // SAME EXISTING BLOC EVENT
                      // =====================================================

                      context
                          .read<
                              ExpenseBloc>()
                          .add(
                            UpdateExpenseParameterEvent(
                              index:
                                  index,

                              amount:
                                  _expenseAmount(
                                latestExpense,
                              ),

                              image:
                                  file,
                            ),
                          );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger
                          .of(
                        context,
                      )
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to select image from gallery',
                            ),
                            duration:
                                Duration(
                              seconds: 3,
                            ),
                            behavior:
                                SnackBarBehavior
                                    .floating,
                          ),
                        );
                    }
                  },

            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    11.r,
                  ),
                  child:
                      item.imageFile !=
                              null
                          ? Image.file(
                              item
                                  .imageFile!,
                              height:
                                  58.w,
                              width:
                                  58.w,
                              fit: BoxFit
                                  .cover,
                            )
                          : _buildExpenseImage(
                              item,
                            ),
                ),

                if (!isTravelExpense)
                  Positioned(
                    right: 2.w,
                    bottom: 2.w,
                    child: Container(
                      padding:
                          EdgeInsets.all(
                        4.w,
                      ),
                      decoration:
                          const BoxDecoration(
                        color: Color(
                          0xFF11934A,
                        ),
                        shape:
                            BoxShape.circle,
                      ),
                      child: Icon(
                        // CHANGED CAMERA ICON -> GALLERY ICON
                        Icons
                            .photo_library_rounded,
                        size: 11.sp,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(
            width: 10.w,
          ),

          // ================================================================
          // EXPENSE NAME + AMOUNT
          // ================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.fldExpName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 12.sp,
                    color:
                        const Color(
                      0xFF26302B,
                    ),
                  ),
                ),

                SizedBox(
                  height: 5.h,
                ),

                SizedBox(
                  height: 42.h,
                  child: TextFormField(
                    controller:
                        controller,

                    readOnly:
                        isTravelExpense,

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter Amount',

                      prefixText:
                          '₹ ',

                      filled: true,

                      fillColor:
                          isTravelExpense
                          ? const Color(
                              0xFFF2F5F3,
                            )
                          : const Color(
                              0xFFF9FBFA,
                            ),

                      isDense: true,

                      contentPadding:
                          EdgeInsets
                              .symmetric(
                        horizontal:
                            10.w,
                        vertical:
                            8.h,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          9.r,
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          9.r,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(
                            0xFF11934A,
                          ),
                        ),
                      ),
                    ),

                    onChanged:
                        (value) {
                      final amount =
                          double.tryParse(
                            value,
                          ) ??
                          0.0;

                      final latestState =
                          context
                              .read<
                                  ExpenseBloc>()
                              .state;

                      if (index >=
                          latestState
                              .expenses
                              .length) {
                        return;
                      }

                      final latestExpense =
                          latestState
                              .expenses[index];

                      context
                          .read<
                              ExpenseBloc>()
                          .add(
                            UpdateExpenseParameterEvent(
                              index:
                                  index,

                              amount:
                                  amount,

                              image:
                                  latestExpense
                                      .imageFile,
                            ),
                          );
                    },
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
  // DEFAULT IMAGE
  // ===========================================================================

  Widget _buildExpenseImage(
    ExpenseParameterEntity item,
  ) {
    return Container(
      height: 58.w,
      width: 58.w,
      decoration: BoxDecoration(
        color: const Color(
          0xFFF0F4F2,
        ),
        borderRadius:
            BorderRadius.circular(
          11.r,
        ),
      ),
      child: Icon(
        _isTravelExpense(
          item,
        )
            ? Icons
                  .directions_car_rounded
            // CHANGED CAMERA -> GALLERY
            : Icons
                  .photo_library_outlined,
        color: const Color(
          0xFF89928D,
        ),
        size: 21.sp,
      ),
    );
  }

  // ===========================================================================
  // SUBMIT
  // ===========================================================================

  void submitExpense(
    ExpenseState state,
  ) {
    final selected =
        state.selectedVehicle;

    final expenseJson =
        jsonEncode(
      state.expenses.map(
        (e) {
          return {
            'fld_exp_id':
                e.fldExpId,

            'fld_exp_name':
                e.fldExpName,

            'Amount':
                _expenseAmount(
              e,
            ),

            'fldImageName':
                e.imageFile != null
                ? base64Encode(
                    e.imageFile!
                        .readAsBytesSync(),
                  )
                : '',
          };
        },
      ).toList(),
    );

    final fields =
        <String, String>{
      'user_id':
          userId.toString(),

      'expenses_date':
          DateFormat(
        'dd-MM-yyyy',
      ).format(
        DateFormat(
          'yyyy-MM-dd',
        ).parse(
          formatDate(
            dateController.text,
          ),
        ),
      ),

      'starting_kilometer':
          openingKm.text,

      'closing_kilometer':
          closingKm.text,

      'total_kilometer':
          totalKm.text,

      'visited_place':
          placeController.text.trim(),

      'journy_from':
          placeController.text.trim(),

      'journy_to':
          placeController.text.trim(),

      'travaling_amount':
          amountController.text.trim(),

      'travaling_mode':
          selected?.fldVehicleType ?? '',

      'total_amount':
          finalTotalAmount.toStringAsFixed(
        2,
      ),

      'remark':
          remarkController.text.trim(),

      'daAmount':
          daAmountController.text.trim(),

      'daType':
          daType ?? '',

      'vehicleTypeId':
          selected?.fldVehicleTypeId ?? '',

      'isExpenseExceed':
          '0',

      'isTotalExceedKm':
          '0',

      'expenseJson':
          expenseJson,
    };

    print(
      '========== EXPENSE FIELDS ==========',
    );

    fields.forEach(
      (key, value) {
        print(
          '$key: $value',
        );
      },
    );

    print(
      '====================================',
    );

    context.read<ExpenseBloc>().add(
          SubmitExpenseEvent(
            fields: fields,
          ),
        );
  }
}