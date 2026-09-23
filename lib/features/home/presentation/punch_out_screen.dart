import 'dart:convert';
import 'dart:io';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/app_image_picker.dart';
import 'package:solufine/core/utility/appdialog.dart';
import 'package:solufine/core/utility/device_info_util.dart';
import 'package:solufine/core/utility/location_util.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_button.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:solufine/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:solufine/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart'
    show PunchInOutDetailsAddEvent, VehicleTypeEvent;
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PunchOutScreen extends StatefulWidget {
  final PunchStatEntity? punchStat;
  const PunchOutScreen(this.punchStat, {super.key});

  @override
  State<PunchOutScreen> createState() => _PunchOutScreenState();
}

class _PunchOutScreenState extends State<PunchOutScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _uploadedImage;

  final TextEditingController openingKmController = TextEditingController();

  final TextEditingController closingKmController = TextEditingController();

  final TextEditingController routeController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  // String? punchVehicleId;

  bool isLoading = false;
  bool _submissionSent = false;

  @override
  void initState() {
    super.initState();

    openingKmController.text = widget.punchStat?.startingKm?.trim() ?? '';
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (!mounted || userId == null) return;

    context.read<QuickAcessBloc>().add(
      VehicleTypeEvent(userId, DateFormat('yyyy-MM-dd').format(DateTime.now())),
    );
  }

  VehicleTypeEntity? _getMatchedVehicle(QuickAccessState state) {
    try {
      return state.vehicleList.firstWhere(
        (vehicle) =>
            vehicle.vehicleTypeId.isNotEmpty &&
            vehicle.vehicleTypeId != '0' &&
            vehicle.vehicleTypeId == vehicle.vehicleTypeIdValue,
      );
    } catch (_) {
      return null;
    }
  }

  void _setMatchedVehicleAndRoute(QuickAccessState state) {
    final vehicle = _getMatchedVehicle(state);

    if (vehicle == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      vehicleController.text = vehicle.vehicleType;
      routeController.text = vehicle.todaysRoute;
    });

    debugPrint('Matched Vehicle: ${vehicle.vehicleType}');
    debugPrint('Matched Vehicle ID: ${vehicle.vehicleTypeId}');
    debugPrint('Matched Route: ${vehicle.todaysRoute}');
  }

  Future<void> _captureImage() async {
    try {
      final File? image = await AppImagePicker.instance.pickFromCamera();

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _uploadedImage = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to capture image')));
    }
  }

  Future<void> _submitPunch() async {
    if (isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicleState = context.read<QuickAcessBloc>().state;

    final matchedVehicle = _getMatchedVehicle(vehicleState);

    if (matchedVehicle == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle type not found')));

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
      final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

      final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

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

      String? closingImageBase64;

      if (_uploadedImage != null) {
        debugPrint('Closing image path: ${_uploadedImage!.path}');

        if (await _uploadedImage!.exists()) {
          final imageBytes = await _uploadedImage!.readAsBytes();

          closingImageBase64 = base64Encode(imageBytes);

          debugPrint(
            'Closing image Base64 length: '
            '${closingImageBase64.length}',
          );
        } else {
          debugPrint('Closing image file does not exist');
        }
      } else {
        debugPrint('Closing image: NOT SELECTED');
      }

      context.read<QuickAcessBloc>().add(
        PunchInOutDetailsAddEvent(
          userId: userId,

          // OUT PUNCH
          inOutStatus: '2',

          differenceByAndroid: '0.0',
          locationHistoryString: '',

          batteryInfo: batteryInfo,
          networkInfo: networkInfo,

          pinRemark: remarkController.text.trim(),

          startingClosingKmAmount: closingKmController.text.trim(),

          vehicleTypeId: matchedVehicle.vehicleTypeId,

          route: routeController.text.trim(),

          latitude: latitude,
          longitude: longitude,

          networkLatitude: latitude,
          networkLongitude: longitude,

          gpsLatitude: latitude,
          gpsLongitude: longitude,

          geoAddress: address,
          closingKmImage: closingImageBase64,
          // No startingKmImage
          // No closingKmImage
          // No date
          // No newTime
          // No isForceOutPunch
          activityId: '4',
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
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    openingKmController.dispose();
    closingKmController.dispose();
    routeController.dispose();
    remarkController.dispose();
    vehicleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: 'Punch Out',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: SafeArea(
        child: BlocConsumer<QuickAcessBloc, QuickAccessState>(
          listener: (context, state) {
            if (state.quickAccessStatus == QuickAccessStatus.success &&
                !_submissionSent) {
              _setMatchedVehicleAndRoute(state);
            }

            // if (state.quickAccessStatus == QuickAccessStatus.success &&
            //     !_submissionSent) {
            //   final vehicle = _getMatchedVehicle(state);

            //   if (vehicle != null) {
            //     vehicleController.text = vehicle.vehicleType;
            //   }
            // }

            if (!_submissionSent) {
              return;
            }

            if (state.quickAccessStatus ==
                QuickAccessStatus.punchStatusSuccess) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });

              AppDialog.show(
                context: context,
                type: DialogType.success,
                title: 'Punch Out Successful',
                message: 'Your punch out has been submitted successfully.',
                buttonText: 'OK',
                onButtonPressed: () {
                  context.go('${AppRouter.home}?refresh=true');
                  // context.go(AppRouter.home);
                },
              );
            }

            if (state.quickAccessStatus == QuickAccessStatus.failure) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });
              AppDialog.show(
                context: context,
                type: DialogType.error,
                title: 'Punch Out Failed',
                message: state.errorMessage ?? 'Unable to submit punch out.',
                buttonText: 'OK',
              );
            }
          },
          builder: (context, vehicleState) {
            // final selectedVehicle = _getMatchedVehicle(vehicleState);
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 14.h),

                      // _vehicleDropdown(vehicleState),
                      SizedBox(height: 14.h),

                      _textField(
                        controller: vehicleController,
                        hintText: 'Vehicle Type',
                        icon: Icons.directions_car_outlined,
                        enabled: false,
                      ),

                      SizedBox(height: 14.h),

                      // Opening KM - READ ONLY
                      _kmField(
                        controller: openingKmController,
                        hintText: 'Opening KM',
                        enabled: false,
                        validator: (_) => null,
                      ),

                      SizedBox(height: 14.h),

                      // Closing KM - EDITABLE
                      _kmField(
                        controller: closingKmController,
                        hintText: 'Closing KM*',
                        enabled: true,
                        validator: (value) => _validateKm(value, 'Closing KM'),
                        onChanged: (value) {
                          // Validate immediately while typing
                          _formKey.currentState?.validate();
                        },
                      ),

                      SizedBox(height: 14.h),

                      // Route
                      _textField(
                        controller: routeController,
                        hintText: 'Enter Route*',
                        icon: Icons.route_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter route';
                          }

                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      // Remark
                      _textField(
                        controller: remarkController,
                        hintText: 'Enter Remark',
                        icon: Icons.note_add_outlined,
                        maxLines: 1,
                      ),

                      SizedBox(height: 14.h),

                      // Upload photo
                      FormField<bool>(
                        initialValue: _uploadedImage != null,
                        validator: (_) {
                          if (_uploadedImage == null) {
                            return 'Please upload an image';
                          }

                          return null;
                        },
                        
                        builder: (field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _uploadPhotoCard(),
                              if (field.hasError)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.w,
                                    top: 4.h,
                                  ),
                                  child: Text(
                                    field.errorText!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 14.h),

                      // Submit
                      _submitButton(),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _kmField({
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      labelText: hintText,
      prefixIcon: Icons.speed_outlined,
      keyboardType: TextInputType.number,
      enabled: enabled,
      validator: enabled ? validator : null,
      onChanged: onChanged,
    );
  }

  String? _validateKm(String? value, String fieldName) {
    final text = value?.trim() ?? '';

    // Empty field
    if (text.isEmpty) {
      return 'Please enter $fieldName';
    }

    final km = double.tryParse(text);

    // Invalid number
    if (km == null) {
      return 'Please enter a valid $fieldName';
    }

    final openingText = openingKmController.text.trim();
    final openingKm = double.tryParse(openingText);

    // Compare only when opening KM is available
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
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      labelText: hintText,
      prefixIcon: icon,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _uploadPhotoCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Upload header
          InkWell(
            onTap: _captureImage,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F8EB),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF00A83B),
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade500,
                    size: 28.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Image capture area
          InkWell(
            onTap: _captureImage,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _uploadedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 52.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        _uploadedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ],
      ),
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
