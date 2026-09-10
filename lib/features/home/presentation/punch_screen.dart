import 'dart:io';

import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PunchScreen extends StatefulWidget {
  final PunchStatEntity? punchStat;

  const PunchScreen({super.key, this.punchStat});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  // String get nextInOutStatus {
  //   final currentStatus = widget.punchStat?.inOutStatus ?? '0';

  //   if (currentStatus == '0') {
  //     return '1';
  //   } else if (currentStatus == '1') {
  //     return '2';
  //   }

  //   return '1';
  // }

  bool isLoading = false;
  bool _submissionSent = false;

  final _formKey = GlobalKey<FormState>();

  File? _uploadedImage;

  final TextEditingController openingKmController = TextEditingController();

  final TextEditingController closingKmController = TextEditingController();

  final TextEditingController routeController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  String? selectedVehicleId;

  // bool get isPunchOut => widget.punchStat?.inOutStatus == '1';

  @override
  @override
  void initState() {
    super.initState();

    // debugPrint('Punch Out: $isPunchOut');
    // debugPrint('Starting KM: ${widget.punchStat?.startingKm}');

    // if (isPunchOut) {
    //   final startingKm = widget.punchStat?.startingKm?.trim() ?? '';

    //   if (startingKm.isNotEmpty) {
    //     openingKmController.text = startingKm;
    //   }
    // }

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

    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found')),
      );

      return;
    }

    final vehicleTypeId = selectedVehicleId;

    if (vehicleTypeId == null || vehicleTypeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type')),
      );
      return;
    }

    // Start button loader
    setState(() {
      isLoading = true;
      _submissionSent = false;
    });

    try {
      final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

      final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

      // -----------------------------
      // Location information
      // -----------------------------

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

      debugPrint('FINAL vehicleTypeId: $vehicleTypeId');

      debugPrint(
        'Current status: '
        '${widget.punchStat?.inOutStatus}',
      );

      // debugPrint('Next status: $nextInOutStatus');

      // -----------------------------
      // Submit event
      // -----------------------------

      context.read<QuickAcessBloc>().add(
        PunchInOutDetailsAddEvent(
          userId: userId,

          // 0 -> 1
          // 1 -> 0
          inOutStatus: '1',

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

          startingClosingKmAmount:
              //  isPunchOut
              //     ? closingKmController.text.trim()
              // :
              openingKmController.text.trim(),

          vehicleTypeId: vehicleTypeId,

          route: routeController.text.trim(),

          startingKmImage: _uploadedImage?.path ?? '',

          closingKmImage: _uploadedImage?.path ?? '',

          // IMPORTANT:
          // Don't use widget.punchStat.toString()
          activityId: widget.punchStat?.dailyTranId ?? '',
          date: '',
          newTime: '',
          isForceOutPunch: false,
        ),
      );
      _submissionSent = true;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: 'Punch In',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: SafeArea(
        child: BlocConsumer<QuickAcessBloc, QuickAccessState>(
          listener: (context, state) {
            if (!isLoading || !_submissionSent) return;

            if (state.quickAccessStatus == QuickAccessStatus.success) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });
              context.go(AppRouter.home);
            } else if (state.quickAccessStatus == QuickAccessStatus.failure) {
              setState(() {
                isLoading = false;
                _submissionSent = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Submission failed'),
                ),
              );
            }
          },
          builder: (context, vehicleState) {
            final selectedVehicle = _selectedVehicle(vehicleState);

            return Stack(
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 14.h),
                          _vehicleDropdown(vehicleState),
                          SizedBox(height: 12.h),

                          // if (selectedVehicle?.openingClosingKm == '1') ...[
                          //   SizedBox(height: 14.h),

                          //   if (isPunchOut) ...[

                          //     Row(
                          //       children: [
                          //         Expanded(
                          //           child: _kmField(
                          //             controller: openingKmController,
                          //             hintText: 'Opening KM',
                          //             enabled: false,
                          //             validator: (value) =>
                          //                 _validateKm(value, 'opening KM'),
                          //           ),
                          //         ),

                          //         SizedBox(width: 12.w),

                          //         Expanded(
                          //           child: _kmField(
                          //             controller: closingKmController,
                          //             hintText: 'Closing KM',
                          //             enabled: true,
                          //             validator: (value) =>
                          //                 _validateKm(value, 'Closing KM'),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ] else ...[
                          if (selectedVehicle?.openingClosingKm != '0') ...[
                            _kmField(
                              controller: openingKmController,
                              hintText: 'Opening KM*',
                              enabled: true,
                              validator: (value) =>
                                  _validateKm(value, 'Opening KM'),
                            ),
                            SizedBox(height: 14.h),
                          ],
                          //   ],
                          // ],

                          // if (selectedVehicle?.openingClosingKm == '1') ...[
                          //   SizedBox(height: 14.h),

                          //   Row(
                          //     children: [
                          //       Expanded(
                          //         child: isPunchIn
                          //             ? _kmField(
                          //                 controller: closingKmController,
                          //                 hintText: 'Closing KM',
                          //                 enabled: true,
                          //                 validator: (value) =>
                          //                     _validateKm(value, 'Closing KM'),
                          //               )
                          //             : _kmField(
                          //                 controller: openingKmController,
                          //                 hintText: 'Opening KM',
                          //                 enabled: true,
                          //                 validator: (value) =>
                          //                     _validateKm(value, 'Opening KM'),
                          //               ),
                          //       ),
                          //     ],
                          //   ),
                          // ],

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
                ),

                ///********* */ if we want to add center loader*********************
                // if (isLoading)
                //   Positioned.fill(
                //     child: AbsorbPointer(
                //       child: Container(
                //         color: Colors.black26,
                //         alignment: Alignment.center,
                //         child: const CircularProgressIndicator(
                //           color: AppColors.accentGreen,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // VEHICLE DROPDOWN
  // ------------------------------------------------------------

  VehicleTypeEntity? _selectedVehicle(QuickAccessState state) {
    if (state.vehicleList.isEmpty) {
      return state.selectedVehicle;
    }

    // If user has selected a vehicle, find it.
    if (selectedVehicleId != null) {
      try {
        return state.vehicleList.firstWhere(
          (vehicle) => vehicle.vehicleTypeId == selectedVehicleId,
        );
      } catch (_) {
        // Selected ID is no longer available in the list.
      }
    }

    // If Bloc already has a selected vehicle, use it.
    if (state.selectedVehicle != null) {
      return state.selectedVehicle;
    }

    // Otherwise select the first vehicle.
    return state.vehicleList.first;
  }

  Widget _vehicleDropdown(QuickAccessState state) {
    // If the list has loaded and nothing is selected,
    // automatically select the first vehicle.
    if (state.vehicleList.isNotEmpty && selectedVehicleId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final firstVehicle = state.vehicleList.first;

        setState(() {
          selectedVehicleId = firstVehicle.vehicleTypeId;
        });

        print('Default vehicle selected: ${firstVehicle.vehicleTypeId}');
      });
    }

    // Find currently selected vehicle.
    VehicleTypeEntity? selectedVehicle;

    if (selectedVehicleId != null) {
      for (final vehicle in state.vehicleList) {
        if (vehicle.vehicleTypeId == selectedVehicleId) {
          selectedVehicle = vehicle;
          break;
        }
      }
    }

    // If still null, use first vehicle.
    selectedVehicle ??= state.vehicleList.isNotEmpty
        ? state.vehicleList.first
        : null;

    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVehicle?.vehicleTypeId,

          isExpanded: true,

          hint: const Text('Select Vehicle Type'),

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade500,
          ),

          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),

          items: state.vehicleList.map((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle.vehicleTypeId,
              child: Text(vehicle.vehicleType),
            );
          }).toList(),

          onChanged: (value) {
            if (value == null) return;

            print('Vehicle selected from dropdown: $value');

            setState(() {
              selectedVehicleId = value;
            });

            print(
              'selectedVehicleId after setState: '
              '$selectedVehicleId',
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
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.speed_outlined,
      keyboardType: TextInputType.number,
      enabled: enabled,
      validator: enabled ? validator : null,
    );
  }

  String? _validateKm(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    final km = double.tryParse(text);

    if (text.isEmpty) {
      return '$fieldName is required';
    }

    if (km == null || km < 0) {
      return 'Enter a valid $fieldName';
    }

    // if (isPunchOut && fieldName == 'Closing KM') {
    //   final openingText = openingKmController.text.trim();
    //   final openingKm = double.tryParse(openingText);

    //   if (openingKm != null && km < openingKm) {
    //     return 'Closing KM cannot be less than Opening KM';
    //   }
    // }

    return null;
  }

  // String? _validateKm(String? value, String fieldName) {
  //   final text = value?.trim() ?? '';
  //   final km = double.tryParse(text);

  //   if (text.isEmpty) {
  //     return '$fieldName is required';
  //   }

  //   if (km == null || km < 0) {
  //     return 'Enter a valid $fieldName';
  //   }

  //   return null;
  // }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
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
      isLoading: isLoading,
      onPressed: _submitPunch,
    );
  }
}
