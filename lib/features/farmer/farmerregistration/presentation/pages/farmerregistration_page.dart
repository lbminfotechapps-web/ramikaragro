import 'dart:io';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/data_list.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_dropdown.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/crop_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/irrigation_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/selected_crop_detail.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/widgets/crop_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class FarmerregistrationPage extends StatefulWidget {
  const FarmerregistrationPage({super.key});

  @override
  State<FarmerregistrationPage> createState() => _FarmerregistrationPageState();
}

class _FarmerregistrationPageState extends State<FarmerregistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController farmerNameController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController alternateMobileController =
      TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController villageController = TextEditingController();

  final TextEditingController currentProductUsedController =
      TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  bool isLoading = false;
  bool _submissionSent = false;
  String? _selectedStateId = '0';
  String? _selectedDistrictId = '0';
  String? _selectedTalukaId = '0';
  String? _selectedFarmerStatus;
  File? _uploadedImage;
  String? _selectedProductId;
  final List<SelectedCropDetail> _selectedCropDetails = [];
  @override
  void initState() {
    super.initState();
    _loadStates();

    context.read<StateBloc>().add(FarmerDropEvent());
  }

  Future<void> getUserId() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id']?.toString();

    if (!mounted || userId == null || userId.isEmpty) {
      return;
    }

    debugPrint('USER ID: $userId');

    context.read<StateBloc>().add(StateListEvent(userId: userId));
  }

  Future<void> _loadStates() async {
    await getUserId();
  }

  Future<void> _onStateSelected(String? stateId) async {
    if (stateId == null || stateId.isEmpty) {
      return;
    }

    debugPrint('================================');
    debugPrint('STATE SELECTED');
    debugPrint('STATE ID: $stateId');
    debugPrint('================================');

    if (stateId == '0') {
      setState(() {
        _selectedStateId = '0';

        // Reset district
        _selectedDistrictId = '0';

        // Reset taluka
        _selectedTalukaId = '0';
      });

      debugPrint('Select State selected');
      debugPrint('District reset to Select District');
      debugPrint('Taluka reset to Select Taluka');

      return;
    }

    setState(() {
      _selectedStateId = stateId;

      _selectedDistrictId = '0';
      _selectedTalukaId = '0';
    });

    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id']?.toString();

    if (!mounted || userId == null || userId.isEmpty) {
      return;
    }

    debugPrint('================================');
    debugPrint('CALLING DISTRICT API');
    debugPrint('USER ID: $userId');
    debugPrint('STATE ID: $stateId');
    debugPrint('================================');

    context.read<StateBloc>().add(
      DistrictEvent(userId: userId, stateId: stateId),
    );
  }

  void _onDistrictSelected(String? districtId, StatsState state) {
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

  Future<void> _showCropDetailsDialog(
    List<CropEntity> cropList,
    List<IrrigationEntity> irrigationList,
  ) async {
    if (cropList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Crop data not available')));
      return;
    }

    if (irrigationList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Irrigation data not available')),
      );
      return;
    }

    final result = await showDialog<List<SelectedCropDetail>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CropDetailsDialog(
          cropList: cropList,
          irrigationList: irrigationList,
          existingSelections: _selectedCropDetails,
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCropDetails
          ..clear()
          ..addAll(result);
      });
    }
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
    debugPrint('FARMER REGISTRATION');
    debugPrint('================================');

    debugPrint('Farmer Name: ${farmerNameController.text}');

    debugPrint('Contact Person: ${contactPersonController.text}');

    debugPrint('Address: ${addressController.text}');

    debugPrint('Mobile: ${mobileController.text}');

    debugPrint('Alternate Mobile: ${alternateMobileController.text}');

    debugPrint('Email: ${emailController.text}');

    debugPrint('Village: ${villageController.text}');

    debugPrint('State ID: $_selectedStateId');

    debugPrint('District ID: $_selectedDistrictId');

    debugPrint('Taluka ID: $_selectedTalukaId');

    debugPrint('================================');
    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');
    /*
    context.read<StateBloc>().add(
      FarmerSubmitDetailsEvent(
        selectedSowingDates: selectedSowingDates, // came frmom dalog
        marketNearby: address,
        gpsLongitude: longitude,
        networkLatitude: latitude,
        latitude: latitude,
        statusOfFarmer: _selectedFarmerStatus.toString(),
        fldTractorMode: fldTractorMode, // dont know
        remark: remarkController.text.trim(),
        selectedAcers: selectedAcers, // -> acre come from dialog
        selectedCattleCount: selectedCattleCount, // dont know
        selectedIrrigationId:
            selectedIrrigationId, // irrigationDetailsData ->fld_id
        selectedProductId:
            selectedProductId, //-> productDetailsData -> fld_product_id
        activityId: activityId,
        campaignRadio: campaignRadio, // dont know
        currentProductUsed: currentProductUsed,
        selectedCattleId: selectedCattleId, //dont know
        fldCategoryId: fldCategoryId, // dont know
        state: _selectedStateId.toString(),
        fldDemoTypeId: fldDemoTypeId, // dont know
        fldVillage: villageController.text.trim(),
        geoAddress: address,
        strNetworkInfo: networkInfo,
        longitude: longitude,
        gpsLatitude: latitude,
        fldTotalAcre: ac, // -> acre come from dialog
        aadhaarNo: addressController.text.trim(),
        fldEmailId: emailController.text.trim(),
        fldAddress: addressController.text.trim(),
        fldMobileNo: mobileController.text.trim(),
        strBatteryInfo: batteryInfo,
        differenceByAndroid: '0.0',
        contactPersonName: contactPersonController.text.trim(),
        userId: userId.toString(),
        fldFarmerName: farmerNameController.text.trim(),
        district: _selectedDistrictId.toString(),
        taluka: _selectedDistrictId.toString(),
        fldMobileNo2: mobileController.text.trim(),
        networkLongitude: latitude,
        image: _uploadedImage.toString(),
      ),
    );


    */
  }

  @override
  void dispose() {
    farmerNameController.dispose();
    contactPersonController.dispose();
    addressController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    villageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Farmer Registration Form',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: 'Register Farmer',
        onPressed: _submit,
        width: double.infinity,
        height: 52,
        borderRadius: 22,
        backgroundColor: const Color(0xFF087C3A),
        textColor: Colors.white,
      ),

      body: BlocBuilder<StateBloc, StatsState>(
        builder: (context, state) {
          final productDetailData =
              state.farmerDetailsEntity?.productDetailsData ?? [];
          DistrictEntity? selectedDistrict;

          final cropList = state.farmerDetailsEntity?.cropDetailsData ?? [];

          final irrigationList =
              state.farmerDetailsEntity?.irrigationDetailsData ?? [];

          if (_selectedDistrictId != null && _selectedDistrictId != '0') {
            for (final district in state.districtList) {
              if (district.fldDistId == _selectedDistrictId) {
                selectedDistrict = district;
                break;
              }
            }
          }

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

          final farmerStatusItems = farmerStatus.map((status) {
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
                    CustomTextFormField(
                      controller: farmerNameController,
                      hintText: 'Farmer Name *',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter farmer name';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: contactPersonController,
                      hintText: 'Contact Person Name',
                      prefixIcon: Icons.person_outline,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: addressController,
                      hintText: 'Address',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: mobileController,
                      hintText: 'Mobile No *',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mobile number';
                        }

                        if (value.length != 10) {
                          return 'Enter valid 10 digit mobile number';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: alternateMobileController,
                      hintText: 'Alternate Mobile No',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        if (value.length != 10) {
                          return 'Enter valid 10 digit mobile number';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: emailController,
                      hintText: 'Email ID',
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
                      controller: villageController,
                      hintText: 'Village',
                      prefixIcon: Icons.location_city_outlined,
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

                      items: state.statentity.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.stateId,
                          child: Text(item.stateName),
                        );
                      }).toList(),

                      onChanged: _onStateSelected,

                      validator: (value) {
                        if (value == null || value == '0') {
                          return 'Please select state';
                        }

                        return null;
                      },
                    ),

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

                    const Text(
                      'Status Of Farmer *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    CustomDropdown<String>(
                      value: _selectedFarmerStatus,

                      hintText: 'Farmer Status',

                      prefixIcon: Icons.person_outline,

                      enabled: true,

                      items: farmerStatusItems,

                      onChanged: (value) {
                        setState(() {
                          _selectedFarmerStatus = value;
                        });

                        debugPrint(
                          'Selected Farmer Status: $_selectedFarmerStatus',
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

                    const Text(
                      'Suggested Product *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    CustomDropdown<String>(
                      value: _selectedProductId,

                      hintText: 'Select Suggested Product',

                      prefixIcon: Icons.inventory_2_outlined,

                      enabled: productDetailData.isNotEmpty,

                      items: productDetailData.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.fldProductId,
                          child: Text(
                            product.fldProductName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                        });

                        debugPrint('Selected Product ID: $_selectedProductId');
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select suggested product';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    const Text(
                      'Crop Details *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CustomTextFormField(
                      controller: TextEditingController(
                        text: _selectedCropDetails.isEmpty
                            ? ''
                            : _selectedCropDetails
                                  .map((item) => item.cropName)
                                  .join(', '),
                      ),
                      hintText: 'Select Land and Crop Details',
                      prefixIcon: Icons.grass_outlined,
                      readOnly: true,
                      onTap: () {
                        _showCropDetailsDialog(cropList, irrigationList);
                      },
                      validator: (value) {
                        if (_selectedCropDetails.isEmpty) {
                          return 'Please select crop details';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: currentProductUsedController,
                      hintText: 'Current Product Used',
                      prefixIcon: Icons.note,
                      maxLines: 2,
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
