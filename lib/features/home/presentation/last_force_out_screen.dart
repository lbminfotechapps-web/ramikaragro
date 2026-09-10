import 'dart:io';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LastForceOutScreen extends StatefulWidget {
  final PunchStatEntity? punchStat;

  const LastForceOutScreen(this.punchStat, {super.key});

  @override
  State<LastForceOutScreen> createState() => _LastForceOutScreenState();
}

class _LastForceOutScreenState extends State<LastForceOutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController lastTimeController = TextEditingController();
  final TextEditingController newTimeController = TextEditingController();
  final TextEditingController openingKmController = TextEditingController();
  final TextEditingController closingKmController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  bool isLoading = false;
  bool _submissionSent = false;

  @override
  void initState() {
    super.initState();

    dateController.text = widget.punchStat?.date ?? '';
    lastTimeController.text = widget.punchStat?.time ?? '';

    openingKmController.text = widget.punchStat?.startingKm.trim() ?? '';
    dateController.text = widget.punchStat?.date.trim() ?? '';
  }

  // ------------------------------------------------------------
  // TIME PICKER
  // ------------------------------------------------------------

  Future<void> _selectNewTime() async {
    final lastTime = _parseTime(lastTimeController.text);

    final initialTime = lastTime != null
        ? TimeOfDay(hour: lastTime.hour, minute: lastTime.minute)
        : TimeOfDay.now();

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted || selectedTime == null) return;

    // Convert selected time to 24-hour HH:mm:ss format
    final now = DateTime.now();

    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
      0,
    );

    newTimeController.text = DateFormat('HH:mm:ss').format(selectedDateTime);

    _formKey.currentState?.validate();

    setState(() {});
  }

  // ------------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------------

  Future<void> _submitPunch() async {
    if (isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found')),
      );

      return;
    }

    setState(() {
      isLoading = true;
      _submissionSent = true;
    });

    try {
      // ----------------------------------------------------------
      // DEVICE INFORMATION
      // ----------------------------------------------------------

      final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

      final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

      // ----------------------------------------------------------
      // LOCATION
      // ----------------------------------------------------------

      final position = await LocationUtil.instance.getCurrentLocation();

      String latitude = '';
      String longitude = '';
      String address = '';

      if (position != null) {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();

        address = await LocationUtil.instance.getAddress(
          position.latitude,
          position.longitude,
        );
      }

      if (!mounted) return;

      // ----------------------------------------------------------
      // API EVENT
      // ----------------------------------------------------------

      context.read<QuickAcessBloc>().add(
        PunchInOutDetailsAddEvent(
          userId: userId,

          inOutStatus: '2',

          batteryInfo: batteryInfo,
          networkInfo: networkInfo,

          latitude: latitude,
          longitude: longitude,

          networkLatitude: latitude,
          networkLongitude: longitude,

          gpsLatitude: latitude,
          gpsLongitude: longitude,

          geoAddress: address,

          pinRemark: remarkController.text.trim(),

          startingClosingKmAmount: closingKmController.text.trim(),

          vehicleTypeId: '',

          route: '',

          startingKmImage: '',
          closingKmImage: '',

          activityId: widget.punchStat?.dailyTranId ?? '',
          date: dateController.text.trim(),
          newTime: newTimeController.text.trim(),
          isForceOutPunch: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        _submissionSent = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    dateController.dispose();
    lastTimeController.dispose();
    newTimeController.dispose();
    openingKmController.dispose();
    closingKmController.dispose();
    remarkController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: 'Last Out Punch',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: SafeArea(
        child: BlocConsumer<QuickAcessBloc, QuickAccessState>(
          listener: (context, state) {
            // --------------------------------------------------
            // SUCCESS
            // --------------------------------------------------

            if (state.quickAccessStatus == QuickAccessStatus.success) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });

              context.go(AppRouter.home);
            }

            // --------------------------------------------------
            // FAILURE
            // --------------------------------------------------

            if (state.quickAccessStatus == QuickAccessStatus.failure &&
                _submissionSent) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Punch Out failed'),
                ),
              );
            }
          },

          builder: (context, vehicleState) {
            return Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // ------------------------------------------------
                    // DATE
                    // ------------------------------------------------
                    _textField(
                      controller: dateController,
                      hintText: 'Date',
                      icon: Icons.calendar_today_outlined,
                      enabled: false,
                    ),

                    SizedBox(height: 14.h),

                    // ------------------------------------------------
                    // LAST TIME
                    // ------------------------------------------------
                    _textField(
                      controller: lastTimeController,
                      hintText: 'Last Time',
                      icon: Icons.history_outlined,
                      enabled: false,
                    ),

                    SizedBox(height: 14.h),

                    // ------------------------------------------------
                    // NEW TIME
                    // ------------------------------------------------
                    _textField(
                      controller: newTimeController,
                      hintText: 'Time',
                      icon: Icons.access_time_outlined,
                      validator: _validateNewTime,
                      readOnly: true,
                      suffixIcon: Icons.schedule_outlined,
                      onTap: _selectNewTime,
                    ),

                    SizedBox(height: 14.h),

                    // ------------------------------------------------
                    // OPENING / CLOSING KM
                    // ------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _kmField(
                            controller: openingKmController,
                            hintText: 'Opening KM',
                            enabled: false,
                            validator: (_) => null,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: _kmField(
                            controller: closingKmController,
                            hintText: 'Closing KM*',
                            enabled: true,
                            validator: (value) =>
                                _validateKm(value, 'Closing KM'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // ------------------------------------------------
                    // REMARK
                    // ------------------------------------------------
                    _textField(
                      controller: remarkController,
                      hintText: 'Enter Remark',
                      icon: Icons.note_add_outlined,
                      maxLines: 3,
                    ),

                    SizedBox(height: 20.h),

                    // ------------------------------------------------
                    // SUBMIT
                    // ------------------------------------------------
                    _submitButton(),

                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TIME VALIDATION
  // ------------------------------------------------------------

  String? _validateNewTime(String? value) {
    final newTime = _parseTime(value);
    final lastTime = _parseTime(lastTimeController.text);

    debugPrint('================================');
    debugPrint('LAST TIME RAW  : "${lastTimeController.text}"');
    debugPrint('NEW TIME RAW   : "${value ?? ''}"');
    debugPrint('LAST TIME PARSED: $lastTime');
    debugPrint('NEW TIME PARSED : $newTime');
    debugPrint('================================');

    if (newTime == null) {
      return 'Please select a valid time';
    }

    if (lastTime == null) {
      return 'Last time is not available';
    }

    // Compare only hours and minutes.
    //
    // Example:
    // Last Time = 02:00 AM
    // New Time  = 01:00 PM
    //
    // 13:00 > 02:00 => VALID
    //
    // Last Time = 02:00 AM
    // New Time  = 01:00 AM
    //
    // 01:00 < 02:00 => INVALID

    final lastMinutes = lastTime.hour * 60 + lastTime.minute;

    final newMinutes = newTime.hour * 60 + newTime.minute;

    if (newMinutes < lastMinutes) {
      return 'New time cannot be less than last time';
    }

    return null;
  }

  DateTime? _parseTime(String? value) {
    if (value == null) {
      return null;
    }

    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    debugPrint('Parsing time: "$text"');

    // 12-hour format with seconds
    // Example: 04:09:39 PM
    try {
      return DateFormat('hh:mm:ss a').parseStrict(text);
    } catch (_) {}

    // 12-hour format without seconds
    // Example: 06:46 PM
    try {
      return DateFormat('hh:mm a').parseStrict(text);
    } catch (_) {}

    // 24-hour format with seconds
    // Example: 16:09:39
    try {
      return DateFormat('HH:mm:ss').parseStrict(text);
    } catch (_) {}

    // 24-hour format without seconds
    // Example: 16:09
    try {
      return DateFormat('HH:mm').parseStrict(text);
    } catch (_) {}

    debugPrint('Unable to parse time: "$text"');

    return null;
  }

  String? _validateKm(String? value, String fieldName) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter $fieldName';
    }

    final km = double.tryParse(text);

    if (km == null) {
      return 'Please enter a valid $fieldName';
    }

    final openingText = openingKmController.text.trim();

    final openingKm = double.tryParse(openingText);

    if (openingKm != null && km < openingKm) {
      return 'Closing KM cannot be less than Opening KM';
    }

    return null;
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: icon,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      suffixIcon: suffixIcon,
      validator: validator,
    );
  }

  Widget _kmField({
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    required String? Function(String?) validator,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.speed_outlined,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      validator: enabled ? validator : null,
    );
  }

  Widget _submitButton() {
    return CustomButton(
      width: double.infinity,
      textSize: 15.sp,
      text: 'SUBMIT',
      onPressed: _submitPunch,
      isLoading: isLoading,
    );
  }
}
