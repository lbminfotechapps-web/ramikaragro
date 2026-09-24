import 'dart:convert';
import 'dart:io';

import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/utility/app_toast.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/utility/image_compression.dart';

import '../../../../core/utility/app_dialog.dart';
import '../../domain/entities/expense_parameter_entity.dart';
import '../../domain/entities/vehicle_entity.dart';

import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final openingKm = TextEditingController();

  final closingKm = TextEditingController();

  final totalKm = TextEditingController();

  final amountController = TextEditingController();

  final placeController = TextEditingController();

  final remarkController = TextEditingController();

  final dateController = TextEditingController();

  final daAmountController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String? daType;
  int? userId;

  double vehicleRate = 0;

  double travelAmount = 0;

  double extraExpenseTotal = 0;

  double finalTotalAmount = 0;

  double enteredKM = 0;
  final Map<String, TextEditingController> _expenseAmountControllers = {};

  bool _isTravelExpense(ExpenseParameterEntity expense) {
    final name = expense.fldExpName.trim().toLowerCase();
    return RegExp(
      r'\b(travel|traveling|travelling|travaling|traving)\b',
    ).hasMatch(name);
  }

  double _expenseAmount(ExpenseParameterEntity expense) {
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
        text: expense.amount > 0 ? expense.amount.toString() : '',
      );
    }

    return _expenseAmountControllers[key]!;
  }

  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);

    _loadInitialExpenses();
  }

  Future<void> _loadInitialExpenses() async {
    final userData = await SecureStorage.instance.getUserData();
    userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (!mounted) return;

    context.read<ExpenseBloc>().add(
      LoadExpenseEvent(
        userId: userId.toString(),
        date: formatDate(dateController.text),
      ),
    );
  }

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

  String formatDate(String value) {
    final clean = value.split(' ').first;

    final date = DateFormat('dd-MM-yyyy').parse(clean);

    return DateFormat('yyyy-MM-dd').format(date);
  }

  void calculateKM(ExpenseState state) {
    final open = double.tryParse(openingKm.text) ?? 0;

    final close = double.tryParse(closingKm.text) ?? 0;

    double total = close - open;

    if (total < 0) {
      total = 0;
    }

    enteredKM = total;

    totalKm.text = total.toStringAsFixed(0);

    travelAmount = total * vehicleRate;

    final da = double.tryParse(daAmountController.text) ?? 0;

    finalTotalAmount = travelAmount + da + extraExpenseTotal;

    amountController.text = travelAmount.toStringAsFixed(2);

    setState(() {});
  }

  void selectVehicle(VehicleEntity vehicle) {
    vehicleRate = double.tryParse(vehicle.fldVehicleRateAdmin) ?? 0;

    openingKm.text = vehicle.fldStartingKm.isEmpty
        ? '0'
        : vehicle.fldStartingKm;

    closingKm.text = vehicle.fldClosingKm.isEmpty ? '0' : vehicle.fldClosingKm;

    calculateKM(context.read<ExpenseBloc>().state);
  }

  Future<void> pickDate(ExpenseState state) async {
    print("days is :${state.allowedDays}");
    final today = DateTime.now();

    final firstAllowed = today.subtract(Duration(days: state.allowedDays));

    final picked = await showDatePicker(
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

      dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    });

    context.read<ExpenseBloc>().add(
      ChangeExpenseDateEvent(
        userId: userId.toString(),
        date: formatDate(dateController.text),
      ),
    );
  }

  void selectDaType(String? value, ExpenseState state) {
    if (value == null) {
      return;
    }

    calculateKM(state);

    final kmLimit = state.apiKmLimit;

    if (enteredKM < kmLimit && state.fldOpeningClosingKm == '1') {
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
          message: 'You are not applicable for DA',
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

        daAmountController.text = state.localDa.toStringAsFixed(2);
      });
    }

    if (value == 'NIGHT') {
      if (state.nightDa <= 0) {
        AppDialog.show(
          context: context,
          message: 'You are not applicable for Night Halt DA',
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

        daAmountController.text = state.nightDa.toStringAsFixed(2);
      });
    }

    calculateKM(state);
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon, color: Colors.green),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state.status == ExpenseStatus.error) {
          AppDialog.show(
            context: context,
            message: state.errorMessage,
            type: DialogType.error,
          );
        }

        if (state.status == ExpenseStatus.success) {
          AppDialog.show(
            context: context,
            message: state.successMessage ?? 'Expense Submit Successfully',
            type: DialogType.success,
            onOkPressed: () {
              Navigator.pop(context);

              if (mounted) {
                Navigator.pop(context); // go back to Main screen
              }
            },
          );
        }

        if (state.status == ExpenseStatus.submitting) {
          AppDialog.showLoading(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Add Expesne',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
          // onBackTap: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state.status == ExpenseStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => pickDate(state),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.green,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (state.expStatus == 0 || state.expStatus == -1)
                    _buildExpenseForm(state)
                  else if (state.expStatus == 1)
                    _buildStatus(
                      Icons.check_circle,
                      Colors.green,
                      'Expenses Already Entered',
                    )
                  else if (state.expStatus == 2)
                    _buildStatus(
                      Icons.warning,
                      Colors.orange,
                      'You Have Not Out-Punched Yet',
                    )
                  else
                    _buildStatus(
                      Icons.error_outline,
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

  Widget _buildExpenseForm(ExpenseState state) {
    final vehicle = state.selectedVehicle;

    if (vehicle != null && openingKm.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectVehicle(vehicle);
      });
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          buildField(
            'Visited Place *',
            placeController,
            icon: Icons.location_on,
          ),

          const SizedBox(height: 8),

          IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<VehicleEntity>(
                value: state.selectedVehicle,
                isExpanded: true,
                underline: const SizedBox(),
                items: state.vehicles.map((vehicle) {
                  return DropdownMenuItem<VehicleEntity>(
                    value: vehicle,
                    child: Text(vehicle.fldVehicleType),
                  );
                }).toList(),
                onChanged: null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          buildField('Opening KM', openingKm, readOnly: true),

          buildField('Closing KM', closingKm, readOnly: true),

          buildField('Total KM', totalKm, readOnly: true),

          buildField('Traveling Amount', amountController, readOnly: true),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: daType,
                  hint: Text(
                    'Select DA Type',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'DA', child: Text('DA')),
                    DropdownMenuItem(
                      value: 'NIGHT',
                      child: Text('Night Halt DA'),
                    ),
                  ],
                  onChanged: (value) => selectDaType(value, state),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildField(
                  'DA Amount',
                  daAmountController,
                  readOnly: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showExpenseSheet(state);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expenses'),
            ),
          ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '₹ ${finalTotalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Remark',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (placeController.text.trim().isEmpty) {
                  AppDialog.show(
                    context: context,
                    message: 'Please Enter Visited Place',
                    type: DialogType.error,
                  );
                  return;
                }

                submitExpense(state);
              },
              child: const Text('SUBMIT', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: Column(
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  void showExpenseSheet(ExpenseState state) {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(sheetContext).size.height * 0.85,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ============================================
                // HANDLE
                // ============================================
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // ============================================
                // TITLE
                // ============================================
                const Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // ============================================
                // EXPENSE LIST
                // ============================================
                Expanded(
                  child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (blocContext, currentState) {
                      return ListView.builder(
                        itemCount: currentState.expenses.length,
                        itemBuilder: (listContext, index) {
                          final item = currentState.expenses[index];

                          // Get permanent controller for this expense
                          final isTravelExpense = _isTravelExpense(item);
                          final expenseAmountController = isTravelExpense
                              ? amountController
                              : _getExpenseAmountController(item);

                          // Keep controller value synchronized
                          // ONLY when field is not focused.
                          if (!isTravelExpense &&
                              (!expenseAmountController.selection.isValid ||
                                  !expenseAmountController
                                      .selection
                                      .isDirectional)) {
                            final expectedText = item.amount > 0
                                ? item.amount.toString()
                                : '';

                            if (expenseAmountController.text != expectedText &&
                                !expenseAmountController.selection.isValid) {
                              expenseAmountController.text = expectedText;
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ==========================================
                                // IMAGE / CAMERA
                                // ==========================================
                                GestureDetector(
                                  onTap: isTravelExpense ? null : () async {
                                    // Hide keyboard before opening camera
                                    FocusScope.of(sheetContext).unfocus();

                                    try {
                                      final XFile? photo = await picker
                                          .pickImage(
                                            source: ImageSource.camera,
                                            imageQuality: 70,
                                          );

                                      if (photo == null) {
                                        return;
                                      }

                                      final file =
                                          await ImageCompression.compressImage(
                                            File(photo.path),
                                            maxWidth: 400,
                                            maxHeight: 400,
                                            quality: 35,
                                          );

                                      if (file == null) {
                                        throw Exception(
                                          'Unable to compress expense image',
                                        );
                                      }

                                      // Get latest Bloc state
                                      final latestState = context
                                          .read<ExpenseBloc>()
                                          .state;

                                      if (index >=
                                          latestState.expenses.length) {
                                        return;
                                      }

                                      final latestExpense =
                                          latestState.expenses[index];

                                      // Update only image.
                                      // Preserve current amount.
                                      context.read<ExpenseBloc>().add(
                                        UpdateExpenseParameterEvent(
                                          index: index,
                                          amount: _expenseAmount(latestExpense),
                                          image: file,
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Unable to capture image',
                                            ),
                                            duration: Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: item.imageFile != null
                                            ? Image.file(
                                                item.imageFile!,
                                                height: 65,
                                                width: 65,
                                                fit: BoxFit.cover,
                                              )
                                            : _buildExpenseImage(item),
                                      ),

                                      // Camera is available for editable expenses only.
                                      if (!isTravelExpense) Positioned(
                                        right: 3,
                                        bottom: 3,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // ==========================================
                                // EXPENSE NAME + AMOUNT
                                // ==========================================
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fldExpName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      TextFormField(
                                        // IMPORTANT:
                                        // No ValueKey based on amount.
                                        controller: expenseAmountController,
                                        readOnly: isTravelExpense,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter Amount',
                                          prefixText: '₹ ',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 11,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),

                                        // ==================================
                                        // AMOUNT CHANGE
                                        // ==================================
                                        onChanged: (value) {
                                          final amount =
                                              double.tryParse(value) ?? 0.0;

                                          final latestState = context
                                              .read<ExpenseBloc>()
                                              .state;

                                          if (index >=
                                              latestState.expenses.length) {
                                            return;
                                          }

                                          final latestExpense =
                                              latestState.expenses[index];

                                          // Preserve image
                                          context.read<ExpenseBloc>().add(
                                            UpdateExpenseParameterEvent(
                                              index: index,
                                              amount: amount,
                                              image: latestExpense.imageFile,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ============================================
                // BUTTONS
                // ============================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        final currentState = context.read<ExpenseBloc>().state;

                        double tempTotal = 0.0;

                        // ========================================
                        // VALIDATION
                        // ========================================
                        for (final expense in currentState.expenses) {
                          final hasAmount = _expenseAmount(expense) > 0;
                          final hasImage = expense.imageFile != null;

                          // Amount entered but image missing
                          if (!_isTravelExpense(expense) &&
                              hasAmount && !hasImage) {
                            Fluttertoast.showToast(
                              msg:
                                  'Please capture image for ${expense.fldExpName}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );

                            return;
                          }

                          // Image selected but amount missing
                          if (!_isTravelExpense(expense) &&
                              hasImage && !hasAmount) {
                            Fluttertoast.showToast(
                              msg:
                                  'Please enter amount for ${expense.fldExpName}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );

                            return;
                          }

                          // Travel is already included by calculateKM.
                          if (!_isTravelExpense(expense)) {
                            tempTotal += expense.amount;
                          }
                        }

                        // ========================================
                        // UPDATE EXTRA EXPENSE TOTAL
                        // ========================================
                        setState(() {
                          extraExpenseTotal = tempTotal;
                        });

                        // ========================================
                        // RECALCULATE TOTAL
                        // ========================================
                        calculateKM(currentState);

                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  Widget _buildExpenseImage(ExpenseParameterEntity item) {
    return Container(
      height: 65,
      width: 65,
      color: Colors.grey.shade200,
      child: const Icon(Icons.camera_alt, color: Colors.grey),
    );
  }

  void submitExpense(ExpenseState state) {
    final selected = state.selectedVehicle;

    final expenseJson = jsonEncode(
      state.expenses.map((e) {
        return {
          'fld_exp_id': e.fldExpId,
          'fld_exp_name': e.fldExpName,
          'Amount': _expenseAmount(e),
          'fldImageName': e.imageFile != null
              ? base64Encode(e.imageFile!.readAsBytesSync())
              : '',
        };
      }).toList(),
    );

    final fields = <String, String>{
      'user_id': userId.toString(),

      'expenses_date': DateFormat(
        'dd-MM-yyyy',
      ).format(DateFormat('yyyy-MM-dd').parse(formatDate(dateController.text))),

      'starting_kilometer': openingKm.text,

      'closing_kilometer': closingKm.text,

      'total_kilometer': totalKm.text,

      'visited_place': placeController.text.trim(),

      'journy_from': placeController.text.trim(),

      'journy_to': placeController.text.trim(),

      'travaling_amount': amountController.text.trim(),

      'travaling_mode': selected?.fldVehicleType ?? '',

      'total_amount': finalTotalAmount.toStringAsFixed(2),

      'remark': remarkController.text.trim(),

      'daAmount': daAmountController.text.trim(),

      'daType': daType ?? '',

      'vehicleTypeId': selected?.fldVehicleTypeId ?? '',

      'isExpenseExceed': '0',

      'isTotalExceedKm': '0',

      'expenseJson': expenseJson,
    };
    print('========== EXPENSE FIELDS ==========');

    fields.forEach((key, value) {
      if (key == 'expenseJson') {
        print('$key: $value');
      } else {
        print('$key: $value');
      }
    });

    print('====================================');
    context.read<ExpenseBloc>().add(SubmitExpenseEvent(fields: fields));
  }
}
