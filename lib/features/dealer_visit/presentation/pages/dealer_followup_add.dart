import 'dart:io';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/appdialog.dart';
import 'package:demo/core/utility/data_list.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_dropdown.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_event.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_state.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DealerFollowupAdd extends StatefulWidget {
  const DealerFollowupAdd({super.key});

  @override
  State<DealerFollowupAdd> createState() => _DealerFollowupAddState();
}

class _DealerFollowupAddState extends State<DealerFollowupAdd> {
  final TextEditingController shopNameController = TextEditingController();

  final TextEditingController dealerCodeController = TextEditingController();

  final TextEditingController ownerNameController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController alternateMobileController =
      TextEditingController();

  final TextEditingController gstController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  String? _selectedStateId = '0';
  String? _selectedDistrictId = '0';
  String? _selectedTalukaId = '0';

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStateId == null || _selectedStateId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select state')));
      return;
    }

    if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select district')));
      return;
    }

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

    if (_selectedTalukaId == null || _selectedTalukaId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select taluka')));
      return;
    }
    debugPrint('================================');
    debugPrint('FARMER REGISTRATION - ALL PARAMS');
    debugPrint('================================');

    debugPrint('FARMER LATTTT - $latitude');
    debugPrint('FARMER LONG - $longitude');
    debugPrint('================================');

    debugPrint('fld_address: ${addressController.text.trim()}');

    debugPrint('fld_category_id: ');
    debugPrint('state: ${_selectedStateId ?? '0'}');
    debugPrint('fld_demo_type_id: ');
    debugPrint('district: ${_selectedDistrictId ?? '0'}');
    debugPrint('taluka: ${_selectedTalukaId ?? '0'}');

    debugPrint('campaign_radio: Yes');

    // Mobile / contact
    debugPrint('fld_mobile_no: ${mobileController.text.trim()}');
    debugPrint('fld_mobile_no2: ${alternateMobileController.text.trim()}');
    debugPrint('fld_email_id: ${emailController.text.trim()}');

    debugPrint('geoAddress: $address');
    debugPrint('meetingLocation: ');
    debugPrint('marketNearby: ');

    // Other farmer details
    debugPrint('fld_tractor_mode: ');

    debugPrint('aadhaarNo: ');
    debugPrint('remark: ${remarkController.text.trim()}');

    debugPrint('selectedCattleId: ');
    debugPrint('selectedCattleCount: ');

    // Crop details
    debugPrint('--------------------------------');
    debugPrint('SELECTED CROP DETAILS');
    debugPrint('--------------------------------');

    // Location
    debugPrint('--------------------------------');
    debugPrint('LOCATION');
    debugPrint('--------------------------------');

    debugPrint('latitude: $latitude');
    debugPrint('longitude: $longitude');

    debugPrint('networkLatitude: $latitude');
    debugPrint('networkLongitude: $longitude');

    debugPrint('gpsLatitude: $latitude');
    debugPrint('gpsLongitude: $longitude');

    debugPrint('differenceByAndroid: 0.0');

    // Device information
    debugPrint('--------------------------------');
    debugPrint('DEVICE INFORMATION');
    debugPrint('--------------------------------');

    debugPrint('strNetworkInfo: $networkInfo');
    debugPrint('strBatteryInfo: $batteryInfo');

    // Activity
    debugPrint('activityId: 2');

    // Image
    debugPrint('--------------------------------');
    debugPrint('IMAGE');
    debugPrint('--------------------------------');

    debugPrint(
      'selfie_capture_image: '
      '${_uploadedImage?.path ?? 'No image selected'}',
    );

    debugPrint('================================');
    debugPrint('END FARMER REGISTRATION PARAMS');
    debugPrint('================================');

    debugPrint('================================');

    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    debugPrint('User ID: $userId');

    setState(() {
      isLoading = true;
      _submissionSent = false;
    });

    try {
      context.read<AddDealerVisitBlock>().add(
        AddDealerFollowUpEvent(
          userId: userId.toString(),
          type: 'Dealer',
          outletName: shopNameController.text.trim(),
          contactPerson: ownerNameController.text.trim(),
          gstNo: gstController.text.trim(),
          mobileNo: mobileController.text.trim(),
          mobileNo2: alternateMobileController.text.trim(),
          emailId: emailController.text.trim(),
          address: addressController.text.trim(),
          state: _selectedStateId.toString(),
          district: _selectedDistrictId.toString(),
          taluka: _selectedTalukaId.toString(),
          remark: remarkController.text.trim(),
          city: '',
          latitude: latitude,
          longitude: longitude,
          networkLatitude: latitude,
          networkLongitude: longitude,
          gpsLatitude: latitude,
          gpsLongitude: longitude,
          geoAddress: address,
          differenceByAndroid: '0.0',
          mobileInfo: '',
          mobileImei: '',
          followUpDate: dateController.text.trim(),
          followUpType: _selectedFollowUpType.toString(),
          strNetworkInfo: '',
          strBatteryInfo: batteryInfo,
          registrationType: _selectedDealerType.toString(),
          flag: '1',
          dealerCode: dealerCodeController.text.trim(),
          activityId: '1',
          selfieCaptureImage: _uploadedImage?.path ?? '',
        ),
      );
      _submissionSent = true;

      debugPrint('================================');
      debugPrint('FARMER SUBMIT EVENT SENT');
      debugPrint('================================');
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
    shopNameController.dispose();
    dealerCodeController.dispose();
    ownerNameController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    gstController.dispose();
    emailController.dispose();
    addressController.dispose();
    dateController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    await getUserId();
  }

  Future<void> getUserId() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id']?.toString();

    if (!mounted || userId == null || userId.isEmpty) {
      return;
    }

    debugPrint('USER ID: $userId');

    context.read<AddDealerVisitBlock>().add(StateListEvent(userId: userId));
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    });
  }

  String? _selectedDealerType;
  String? _selectedFollowUpType;

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

  File? _uploadedImage;
  bool _submissionSent = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _onDistrictSelected(String? districtId, AddDealerVisitState state) {
    if (districtId == null || districtId.isEmpty) {
      return;
    }

    debugPrint('================================');
    debugPrint('DISTRICT SELECTED');
    debugPrint('DISTRICT ID: $districtId');
    debugPrint('================================');

    if (districtId == '0') {
      setState(() {
        _selectedDistrictId = '0';
        _selectedTalukaId = '0';
      });

      debugPrint('Select District selected');
      debugPrint('Taluka reset to Select Taluka');

      return;
    }

    DistrictEntity? selectedDistrict;

    for (final district in state.districtList) {
      if (district.fldDistId == districtId) {
        selectedDistrict = district;
        break;
      }
    }

    if (selectedDistrict == null) {
      debugPrint('Selected district not found');
      return;
    }

    debugPrint('DISTRICT NAME: ${selectedDistrict.fldDistName}');

    debugPrint('TALUKA COUNT: ${selectedDistrict.taluka.length}');

    setState(() {
      _selectedDistrictId = districtId;

      _selectedTalukaId = '0';
    });
  }

  void _onStateSelected(String? stateId, AddDealerVisitState state) async {
    if (stateId == null || stateId.isEmpty) {
      return;
    }

    debugPrint('================================');
    debugPrint('STATE SELECTED');
    debugPrint('New State ID: $stateId');
    debugPrint('================================');

    if (stateId == '0') {
      setState(() {
        _selectedStateId = '0';
        _selectedDistrictId = '0';
        _selectedTalukaId = '0';
      });

      return;
    }

    setState(() {
      _selectedStateId = stateId;

      _selectedDistrictId = '0';
      _selectedTalukaId = '0';
    });

    final userData = await SecureStorage.instance.getUserData();

    final int? userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      debugPrint('Invalid user ID');
      return;
    }

    // Load districts for NEW state
    context.read<AddDealerVisitBlock>().add(
      DistrictEvent(userId: userId.toString(), stateId: stateId),
    );
  }
  // Future<void> _onStateSelected(String? stateId) async {
  //   if (stateId == null || stateId.isEmpty) {
  //     return;
  //   }

  //   debugPrint('================================');
  //   debugPrint('STATE SELECTED');
  //   debugPrint('STATE ID: $stateId');
  //   debugPrint('================================');

  //   if (stateId == '0') {
  //     setState(() {
  //       _selectedStateId = '0';

  //       // Reset district
  //       _selectedDistrictId = '0';

  //       // Reset taluka
  //       _selectedTalukaId = '0';
  //     });

  //     debugPrint('Select State selected');
  //     debugPrint('District reset to Select District');
  //     debugPrint('Taluka reset to Select Taluka');

  //     return;
  //   }

  //   setState(() {
  //     _selectedStateId = stateId;

  //     _selectedDistrictId = '0';
  //     _selectedTalukaId = '0';
  //   });

  //   final userData = await SecureStorage.instance.getUserData();

  //   final userId = userData?['user_id']?.toString();

  //   if (!mounted || userId == null || userId.isEmpty) {
  //     return;
  //   }

  //   debugPrint('================================');
  //   debugPrint('CALLING DISTRICT API');
  //   debugPrint('USER ID: $userId');
  //   debugPrint('STATE ID: $stateId');
  //   debugPrint('================================');

  //   context.read<AddDealerVisitBlock>().add(
  //     DistrictEvent(userId: userId, stateId: stateId),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Dealer Registration Form',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          BlocBuilder<AddDealerVisitBlock, AddDealerVisitState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Register Dealer',
                onPressed: _submit,
                isLoading: isLoading,
                width: double.infinity,
                height: 52,
                borderRadius: 22,
                backgroundColor: const Color(0xFF087C3A),
                textColor: Colors.white,
              );
            },
          ),
      body: BlocConsumer<AddDealerVisitBlock, AddDealerVisitState>(
        listener: (context, state) {
          if (!isLoading || !_submissionSent) return;
          if (state.addLeaveStatus == AddDealerVisitStatus.dealerAddedSuccess) {
            setState(() {
              isLoading = false;
              _submissionSent = false;
            });

            AppDialog.show(
              context: context,
              message: 'Dealer Added Successfully',
              onButtonPressed: () => {context.go(AppRouter.home)},
            );
            context.push(AppRouter.home);
          }
          // ============================================
          // API ERROR
          // ============================================
          else if (state.addLeaveStatus == AddDealerVisitStatus.failure) {
            setState(() {
              isLoading = false;
              _submissionSent = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.darkErrorColor,
                content: Text(state.errorMessage ?? 'Submission failed'),
              ),
            );
          }
        },
        builder: (context, state) {
          DistrictEntity? selectedDistrict;

          if (_selectedDistrictId != null && _selectedDistrictId != '0') {
            for (final district in state.districtList) {
              if (district.fldDistId == _selectedDistrictId) {
                selectedDistrict = district;
                break;
              }
            }
          }
          final uniqueStates = <String, StateEntity>{};

          for (final item in state.statentity) {
            final id = item.stateId.trim();

            if (id.isEmpty) {
              continue;
            }

            if (!uniqueStates.containsKey(id)) {
              uniqueStates[id] = item;
            }
          }

          final stateItems = uniqueStates.values
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.stateId.trim(),
                  child: Text(item.stateName),
                ),
              )
              .toList();
          final talukaList = selectedDistrict?.taluka ?? [];

          final districtItems = [
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select District'),
            ),

            ...state.districtList
                .where((district) => district.fldDistId != '0')
                .map(
                  (district) => DropdownMenuItem<String>(
                    value: district.fldDistId,
                    child: Text(district.fldDistName),
                  ),
                ),
          ];

          final talukaItems = [
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select Taluka'),
            ),

            ...talukaList
                .where((taluka) => taluka.fldTalukaId != '0')
                .map(
                  (taluka) => DropdownMenuItem<String>(
                    value: taluka.fldTalukaId,
                    child: Text(taluka.fldName),
                  ),
                ),
          ];
          final dealerTypeItems = dealerTypeStatus.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList();

          final followUpTypeItem = followUpType.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList();
          return SafeArea(
            child: Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 10.h),

                    const Text(
                      'Dealer Type *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    CustomDropdown<String>(
                      value: _selectedDealerType,

                      hintText: 'Select Dealer Type',

                      prefixIcon: Icons.person_outline,

                      enabled: true,

                      items: dealerTypeItems,

                      onChanged: (value) {
                        setState(() {
                          _selectedDealerType = value;
                        });

                        debugPrint(
                          'Selected Farmer Status: $_selectedDealerType',
                        );
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select farmer status';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),
                    CustomTextFormField(
                      labelText: 'Shop Name',
                      controller: shopNameController,
                      hintText: 'Shop Name *',

                      prefixIcon: Icons.shop,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Shop name';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Dealer Code',
                      controller: dealerCodeController,
                      hintText: 'Dealer Code',

                      prefixIcon: Icons.person_outline,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Owner Name',
                      controller: ownerNameController,
                      hintText: 'Owner Name',

                      prefixIcon: Icons.person_2_outlined,
                      maxLines: 1,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Mobile No',
                      controller: mobileController,
                      hintText: 'Mobile No *',

                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final mobileNumber = value?.trim() ?? '';

                        if (mobileNumber.isEmpty) {
                          return 'Please enter mobile number';
                        }

                        if (!RegExp(r'^\d{10}$').hasMatch(mobileNumber)) {
                          return 'Enter valid 10 digit mobile number';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Alternate Mobile No',
                      controller: alternateMobileController,
                      hintText: 'Alternate Mobile No',

                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final mobileNumber = value?.trim() ?? '';

                        if (mobileNumber.isEmpty) {
                          return null;
                        }

                        if (!RegExp(r'^\d{10}$').hasMatch(mobileNumber)) {
                          return 'Enter valid 10 digit mobile number';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'GST No',
                      controller: gstController,
                      hintText: 'GST No',

                      prefixIcon: Icons.receipt_long_outlined,
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Email Id',
                      controller: emailController,
                      hintText: 'Email Id',

                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Enter valid email address';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Address',
                      controller: addressController,
                      hintText: 'Address',

                      prefixIcon: Icons.home_outlined,
                    ),

                    SizedBox(height: 10.h),

                    const Text(
                      'State *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10.h),
                    CustomDropdown<String>(
                      value: _selectedStateId == '0' ? null : _selectedStateId,

                      hintText: 'Select State',

                      prefixIcon: Icons.map_outlined,

                      items: stateItems,

                      onChanged: (value) {
                        _onStateSelected(value, state);
                      },

                      validator: (value) {
                        if (value == null || value == '0') {
                          return 'Please select state';
                        }

                        return null;
                      },
                    ),

                    // CustomDropdown<String>(
                    //   value: _selectedStateId == '0' ? null : _selectedStateId,

                    //   hintText: 'Select State',

                    //   prefixIcon: Icons.map_outlined,

                    //   items: state.statentity.map((item) {
                    //     return DropdownMenuItem<String>(
                    //       value: item.stateId,
                    //       child: Text(item.stateName),
                    //     );
                    //   }).toList(),

                    //   onChanged: _onStateSelected,

                    //   validator: (value) {
                    //     if (value == null || value == '0') {
                    //       return 'Please select state';
                    //     }

                    //     return null;
                    //   },
                    // ),
                    SizedBox(height: 10.h),

                    const Text(
                      'District *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    CustomDropdown<String>(
                      value: _selectedDistrictId == '0'
                          ? null
                          : _selectedDistrictId,
                      hintText: 'Select District',
                      prefixIcon: Icons.location_city_outlined,
                      enabled:
                          _selectedStateId != null && _selectedStateId != '0',
                      items: districtItems,
                      onChanged: (value) {
                        _onDistrictSelected(value, state);
                      },
                      validator: (value) {
                        if (value == null || value == '0') {
                          return 'Please select district';
                        }

                        return null;
                      },
                    ),

                    // CustomDropdown<String>(
                    //   value: _selectedDistrictId == '0'
                    //       ? null
                    //       : _selectedDistrictId,

                    //   hintText: 'Select District',

                    //   prefixIcon: Icons.location_city_outlined,

                    //   enabled:
                    //       _selectedStateId != null && _selectedStateId != '0',

                    //   items: districtItems,

                    //   onChanged: (value) {
                    //     _onDistrictSelected(value, state);
                    //   },

                    //   validator: (value) {
                    //     if (value == null || value == '0') {
                    //       return 'Please select district';
                    //     }

                    //     return null;
                    //   },
                    // ),
                    SizedBox(height: 10.h),

                    const Text(
                      'Taluka *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10.h),
                    CustomDropdown<String>(
                      value: _selectedTalukaId == '0'
                          ? null
                          : _selectedTalukaId,
                      hintText: 'Select Taluka',
                      prefixIcon: Icons.location_on_outlined,
                      enabled:
                          _selectedDistrictId != null &&
                          _selectedDistrictId != '0' &&
                          talukaList.isNotEmpty,
                      items: talukaItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedTalukaId = value ?? '0';
                        });

                        debugPrint('Selected Taluka ID: $_selectedTalukaId');
                      },
                      validator: (value) {
                        if (value == null || value == '0') {
                          return 'Please select taluka';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    _textField(
                      controller: dateController,
                      hintText: 'Next Followup Date *',
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      // suffixIcon: Icons.calendar_month_outlined,
                      onSuffixIconTap: _pickDate,
                      onTap: _pickDate,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select date';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),

                    const Text(
                      'Follow Up Type *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    CustomDropdown<String>(
                      value: _selectedFollowUpType,
                      hintText: 'Follow Up Type',
                      prefixIcon: Icons.event_note_outlined,
                      enabled: true,
                      items: followUpTypeItem,
                      onChanged: (value) {
                        setState(() {
                          _selectedFollowUpType = value;
                        });

                        debugPrint(
                          'Selected Follow Up Type: $_selectedFollowUpType',
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select follow up type';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

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
                                padding: EdgeInsets.only(left: 16.w, top: 4.h),
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
                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      labelText: 'Remark',
                      controller: remarkController,
                      hintText: 'Remark',

                      prefixIcon: Icons.note,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
    VoidCallback? onSuffixIconTap,
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
      onSuffixIconTap: onSuffixIconTap,
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
}
