import 'dart:io';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/app_image_picker.dart';
import 'package:solufine/core/utility/appdialog.dart';
import 'package:solufine/core/utility/data_list.dart';
import 'package:solufine/core/utility/device_info_util.dart';
import 'package:solufine/core/utility/location_util.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_button.dart';
import 'package:solufine/core/utility/widgets/custom_dropdown.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/crop_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/irrigation_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/selected_crop_detail.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/widgets/crop_details_dialog.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/widgets/product_selection_dialog.dart';
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
  final List<String> _selectedProductIds = [];
  final List<SelectedCropDetail> _selectedCropDetails = [];

  String selectedSowingDates = '';
  String selectedAcers = '';
  String selectedIrrigationId = '';
  String selectedCropId = '';
  String latitude = '';
  String longitude = '';
  String address = '';
  @override
  void initState() {
    super.initState();
    _loadStates();
    getGeoAddress();

    context.read<StateBloc>().add(FarmerDropEvent());
  }

  Future<void> getGeoAddress() async {
    final position = await LocationUtil.instance.getCurrentLocation();

    if (position != null) {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      address = await LocationUtil.instance.getAddress(
        position.latitude,
        position.longitude,
      );
      addressController.text = address;
    }
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

        // ============================================
        // CONVERT DIALOG DATA TO API FORMAT
        // ============================================

        // Example:
        // 16-09-2026,14-09-2026,22-09-2026
        selectedSowingDates = _selectedCropDetails
            .map((item) => _formatApiDate(item.date))
            .join(',');

        // Example:
        // 258,523,,66,,
        selectedAcers = _selectedCropDetails
            .map((item) => item.acre.trim())
            .join(',');

        // Example:
        // 1,2,1
        selectedIrrigationId = _selectedCropDetails
            .map((item) => item.irrigationId)
            .join(',');

        // Example:
        // 145,146,148
        selectedCropId = _selectedCropDetails
            .map((item) => item.cropId)
            .join(',');
      });

      // ============================================
      // DEBUG
      // ============================================

      debugPrint('================================');
      debugPrint('SELECTED CROP DETAILS');
      debugPrint('================================');

      debugPrint('selectedSowingDates: $selectedSowingDates');

      debugPrint('selectedAcers: $selectedAcers');

      debugPrint('selectedIrrigationId: $selectedIrrigationId');

      debugPrint('selectedCropId: $selectedCropId');

      debugPrint('================================');
    }
  }

  String _formatApiDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String get _selectedProductNames {
    final productList =
        context
            .read<StateBloc>()
            .state
            .farmerDetailsEntity
            ?.productDetailsData ??
        [];

    return productList
        .where((product) => _selectedProductIds.contains(product.fldProductId))
        .map((product) => product.fldProductName)
        .join(', ');
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      _submissionSent = false;
    });

    try {
      if (_selectedStateId == null || _selectedStateId!.isEmpty) {
        throw Exception('Please select state');
      }

      if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
        throw Exception('Please select district');
      }

      if (_selectedTalukaId == null || _selectedTalukaId!.isEmpty) {
        throw Exception('Please select taluka');
      }

      final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

      final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

      // final position = await LocationUtil.instance.getCurrentLocation();

      // String latitude = '';
      // String longitude = '';
      // String address = '';

      // if (position != null) {
      //   latitude = position.latitude.toString();
      //   longitude = position.longitude.toString();

      //   address = await LocationUtil.instance.getAddress(
      //     position.latitude,
      //     position.longitude,
      //   );
      // }

      final userData = await SecureStorage.instance.getUserData();

      final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final selectedProductId = _selectedProductIds.join(',');

      context.read<StateBloc>().add(
        FarmerSubmitDetailsEvent(
          fldFarmerName: farmerNameController.text.trim(),

          fldAddress: addressController.text.trim(),

          userId: userId.toString(),

          fldCategoryId: '',

          state: _selectedStateId ?? '0',

          fldDemoTypeId: '',

          district: _selectedDistrictId ?? '0',

          taluka: _selectedTalukaId ?? '0',

          statusOfFarmer: _selectedFarmerStatus ?? '',

          campaignRadio: 'Yes',

          fldMobileNo: mobileController.text.trim(),

          fldMobileNo2: alternateMobileController.text.trim(),

          fldTotalAcre: _selectedCropDetails
              .fold<double>(
                0.0,
                (sum, item) => sum + (double.tryParse(item.acre) ?? 0),
              )
              .toStringAsFixed(2),

          fldEmailId: emailController.text.trim(),

          fldTractorMode: '',

          fldVillage: villageController.text.trim(),

          selectedProductId: selectedProductId,

          selectedCropId: _selectedCropDetails
              .map((item) => item.cropId.toString())
              .join(','),

          selectedAcers: selectedAcers,

          selectedSowingDates: selectedSowingDates,

          selectedIrrigationId: selectedIrrigationId,

          selectedCattleId: '',

          selectedCattleCount: '',

          latitude: latitude,

          longitude: longitude,

          networkLatitude: latitude,

          networkLongitude: longitude,

          gpsLatitude: latitude,

          gpsLongitude: longitude,

          differenceByAndroid: '0.0',

          contactPersonName: contactPersonController.text.trim(),

          meetingLocation: '',

          marketNearby: '',

          aadhaarNo: '',

          remark: remarkController.text.trim(),

          geoAddress: address,

          strNetworkInfo: networkInfo,

          currentProductUsed: currentProductUsedController.text.trim(),

          strBatteryInfo: batteryInfo,

          activityId: '2',

          image: _uploadedImage?.path ?? '',
        ),
      );

      _submissionSent = true;

      debugPrint('FARMER SUBMIT EVENT SENT');
    } catch (e) {
      debugPrint('FARMER SUBMIT ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        _submissionSent = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
  // void _submit() async {
  //   FocusScope.of(context).unfocus();

  //   if (isLoading) return;
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   if (_selectedStateId == null || _selectedStateId!.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please select state')));
  //     return;
  //   }

  //   if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please select district')));
  //     return;
  //   }

  //   final batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

  //   final networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

  //   final position = await LocationUtil.instance.getCurrentLocation();

  //   String latitude = '';
  //   String longitude = '';
  //   String address = '';

  //   if (position != null) {
  //     latitude = position.latitude.toString();
  //     longitude = position.longitude.toString();

  //     address = await LocationUtil.instance.getAddress(
  //       position.latitude,
  //       position.longitude,
  //     );
  //   }

  //   if (_selectedTalukaId == null || _selectedTalukaId!.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please select taluka')));
  //     return;
  //   }
  //   debugPrint('================================');
  //   debugPrint('FARMER REGISTRATION - ALL PARAMS');
  //   debugPrint('================================');

  //   debugPrint('FARMER LATTTT - $latitude');
  //   debugPrint('FARMER LONG - $longitude');
  //   debugPrint('================================');

  //   // Basic farmer details
  //   debugPrint('fld_farmer_name: ${farmerNameController.text.trim()}');
  //   debugPrint('fld_address: ${addressController.text.trim()}');

  //   debugPrint('fld_category_id: ');
  //   debugPrint('state: ${_selectedStateId ?? '0'}');
  //   debugPrint('fld_demo_type_id: ');
  //   debugPrint('district: ${_selectedDistrictId ?? '0'}');
  //   debugPrint('taluka: ${_selectedTalukaId ?? '0'}');

  //   // Farmer status
  //   debugPrint('status_of_farmer: ${_selectedFarmerStatus ?? ''}');
  //   debugPrint('campaign_radio: Yes');

  //   // Mobile / contact
  //   debugPrint('fld_mobile_no: ${mobileController.text.trim()}');
  //   debugPrint('fld_mobile_no2: ${alternateMobileController.text.trim()}');
  //   debugPrint('fld_email_id: ${emailController.text.trim()}');
  //   debugPrint('contactPersonName: ${contactPersonController.text.trim()}');

  //   // Address
  //   debugPrint('fld_village: ${villageController.text.trim()}');
  //   debugPrint('geoAddress: $address');
  //   debugPrint('meetingLocation: ');
  //   debugPrint('marketNearby: ');

  //   // Other farmer details
  //   debugPrint('fld_tractor_mode: ');
  //   debugPrint(
  //     'fld_total_acre: ${_selectedCropDetails.fold<double>(0.0, (sum, item) => sum + (double.tryParse(item.acre) ?? 0)).toStringAsFixed(2)}',
  //   );

  //   debugPrint('aadhaarNo: ');
  //   debugPrint('remark: ${remarkController.text.trim()}');
  //   debugPrint(
  //     'currentProductUsed: '
  //     '${currentProductUsedController.text.trim()}',
  //   );

  //   // Products / crops
  //   debugPrint('selectedProductId: ${_selectedProductIds.join(',')}');
  //   debugPrint('selectedProductId LIST: $_selectedProductIds');

  //   debugPrint(
  //     'selectedCropId: ${_selectedCropDetails.map((crop) => crop.cropId.toString()).join(',')}',
  //   );

  //   debugPrint(
  //     'selectedCropId LIST: ${_selectedCropDetails.map((crop) => crop.cropId.toString()).toList()}',
  //   );

  //   debugPrint('selectedAcers: $selectedAcers');

  //   debugPrint('selectedSowingDates: $selectedSowingDates');

  //   debugPrint('selectedIrrigationId: $selectedIrrigationId');

  //   debugPrint('selectedCattleId: ');
  //   debugPrint('selectedCattleCount: ');

  //   // Crop details
  //   debugPrint('--------------------------------');
  //   debugPrint('SELECTED CROP DETAILS');
  //   debugPrint('--------------------------------');

  //   debugPrint('Selected Crop Details Count: ${_selectedCropDetails.length}');

  //   for (final crop in _selectedCropDetails) {
  //     debugPrint(
  //       'Crop -> '
  //       'ID: ${crop.cropId}, '
  //       'Name: ${crop.cropName}, '
  //       'Date: ${_formatApiDate(crop.date)}, '
  //       'Acre: ${crop.acre}, '
  //       'Irrigation ID: ${crop.irrigationId}, '
  //       'Irrigation: ${crop.irrigationName}',
  //     );
  //   }

  //   // Location
  //   debugPrint('--------------------------------');
  //   debugPrint('LOCATION');
  //   debugPrint('--------------------------------');

  //   debugPrint('latitude: $latitude');
  //   debugPrint('longitude: $longitude');

  //   debugPrint('networkLatitude: $latitude');
  //   debugPrint('networkLongitude: $longitude');

  //   debugPrint('gpsLatitude: $latitude');
  //   debugPrint('gpsLongitude: $longitude');

  //   debugPrint('differenceByAndroid: 0.0');

  //   // Device information
  //   debugPrint('--------------------------------');
  //   debugPrint('DEVICE INFORMATION');
  //   debugPrint('--------------------------------');

  //   debugPrint('strNetworkInfo: $networkInfo');
  //   debugPrint('strBatteryInfo: $batteryInfo');

  //   // Activity
  //   debugPrint('activityId: 2');

  //   // Image
  //   debugPrint('--------------------------------');
  //   debugPrint('IMAGE');
  //   debugPrint('--------------------------------');

  //   debugPrint(
  //     'selfie_capture_image: '
  //     '${_uploadedImage?.path ?? 'No image selected'}',
  //   );

  //   debugPrint('================================');
  //   debugPrint('END FARMER REGISTRATION PARAMS');
  //   debugPrint('================================');

  //   debugPrint('================================');

  //   final userData = await SecureStorage.instance.getUserData();

  //   final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

  //   debugPrint('User ID: $userId');

  //   final selectedProductId = _selectedProductIds.join(',');

  //   debugPrint('Final selectedProductId: $selectedProductId');

  //   setState(() {
  //     isLoading = true;
  //     _submissionSent = false;
  //   });

  //   try {
  //     context.read<StateBloc>().add(
  //       FarmerSubmitDetailsEvent(
  //         fldFarmerName: farmerNameController.text.trim(),

  //         fldAddress: addressController.text.trim(),

  //         userId: userId?.toString() ?? '',

  //         fldCategoryId: '',

  //         state: _selectedStateId ?? '0',

  //         fldDemoTypeId: '',

  //         district: _selectedDistrictId ?? '0',

  //         taluka: _selectedTalukaId ?? '0',

  //         statusOfFarmer: _selectedFarmerStatus ?? '',

  //         campaignRadio: 'Yes',

  //         fldMobileNo: mobileController.text.trim(),

  //         fldMobileNo2: alternateMobileController.text.trim(),

  //         fldTotalAcre: _selectedCropDetails
  //             .fold<double>(
  //               0.0,
  //               (sum, item) => sum + (double.tryParse(item.acre) ?? 0),
  //             )
  //             .toStringAsFixed(2),

  //         fldEmailId: emailController.text.trim(),

  //         fldTractorMode: '',

  //         fldVillage: villageController.text.trim(),

  //         selectedProductId: selectedProductId,

  //         // Example: 145,146
  //         selectedCropId: _selectedCropDetails
  //             .map((item) => item.cropId.toString())
  //             .join(','),

  //         // Example: 10,14
  //         selectedAcers: selectedAcers,

  //         // Example: 11-09-2026,12-09-2026
  //         selectedSowingDates: selectedSowingDates,

  //         // Example: 1,1
  //         selectedIrrigationId: selectedIrrigationId,

  //         selectedCattleId: '',

  //         selectedCattleCount: '',

  //         latitude: latitude,

  //         longitude: longitude,

  //         networkLatitude: latitude,

  //         networkLongitude: longitude,

  //         gpsLatitude: latitude,

  //         gpsLongitude: longitude,

  //         differenceByAndroid: '0.0',

  //         contactPersonName: contactPersonController.text.trim(),

  //         meetingLocation: '',

  //         marketNearby: '',

  //         aadhaarNo: '',

  //         remark: remarkController.text.trim(),

  //         geoAddress: address,

  //         strNetworkInfo: networkInfo,

  //         currentProductUsed: currentProductUsedController.text.trim(),

  //         strBatteryInfo: batteryInfo,

  //         activityId: '2',

  //         image: _uploadedImage?.path ?? '',
  //       ),
  //     );
  //     _submissionSent = true;

  //     debugPrint('================================');
  //     debugPrint('FARMER SUBMIT EVENT SENT');
  //     debugPrint('================================');
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() {
  //       isLoading = false;
  //       _submissionSent = false;
  //     });

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(e.toString())));
  //   }
  // }

  @override
  void dispose() {
    farmerNameController.dispose();
    contactPersonController.dispose();
    addressController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    villageController.dispose();
    currentProductUsedController.dispose();
    remarkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Farmer Registration Form',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<StateBloc, StatsState>(
        builder: (context, state) {
          return CustomButton(
            text: 'Register Farmer',
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

      body: BlocConsumer<StateBloc, StatsState>(
        listener: (context, state) {
          if (!isLoading || !_submissionSent) return;
          if (state.status == StatesStatus.farmerRegiSuccess) {
            setState(() {
              isLoading = false;
              _submissionSent = false;
            });

            AppDialog.show(
              context: context,
              message: 'Farmer Added Successfully',
              onButtonPressed: () => {context.go(AppRouter.home)},
            );
          }
          // ============================================
          // API ERROR
          // ============================================
          else if (state.status == StatesStatus.failed) {
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
                      labelText: 'Farmer Name *',
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
                      labelText: 'Contact Person Name',
                      prefixIcon: Icons.person_outline,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      controller: addressController,
                      hintText: 'Address *',
                      labelText: 'Address',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 3,
                       validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address';
                        }

                        return null;
                      },
                      
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      maxLength: 10,
                      controller: mobileController,
                      hintText: 'Mobile No *',
                      labelText: 'Mobile No *',
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

                    // SizedBox(height: 10.h),
                    CustomTextFormField(
                      maxLength: 10,
                      controller: alternateMobileController,
                      hintText: 'Alternate Mobile No',
                      labelText: 'Alternate Mobile No ',
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

                    // SizedBox(height: 10.h),
                    CustomTextFormField(
                      controller: emailController,
                      hintText: 'Email ID',
                      labelText: 'Email ID',
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
                      labelText: 'Village',
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

                    CustomTextFormField(
                      controller: TextEditingController(
                        text: _selectedProductIds.isEmpty
                            ? ''
                            : _selectedProductNames,
                      ),
                      hintText: 'Select Suggested Product',
                      prefixIcon: Icons.inventory_2_outlined,
                      readOnly: true,
                      onTap: productDetailData.isEmpty
                          ? null
                          : () async {
                              final result = await showDialog<List<String>>(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) {
                                  return ProductSelectionDialog(
                                    productList: productDetailData,
                                    selectedProductIds: _selectedProductIds,
                                  );
                                },
                              );

                              if (result != null && mounted) {
                                setState(() {
                                  _selectedProductIds
                                    ..clear()
                                    ..addAll(result);
                                });

                                debugPrint(
                                  'Selected Product IDs: '
                                  '${_selectedProductIds.join(',')}',
                                );

                                debugPrint(
                                  'Selected Product IDs List: '
                                  '$_selectedProductIds',
                                );
                              }
                            },
                      validator: (value) {
                        if (_selectedProductIds.isEmpty) {
                          return 'Please select a suggested product';
                        }

                        return null;
                      },
                    ),

                    // FormField<bool>(
                    //   initialValue: _selectedProductIds.isNotEmpty,
                    //   validator: (_) {
                    //     if (_selectedProductIds.isEmpty) {
                    //       return 'Please select a suggested product';
                    //     }

                    //     return null;
                    //   },
                    //   builder: (field) {
                    //     return Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         InkWell(
                    //           onTap: productDetailData.isEmpty
                    //               ? null
                    //               : () async {
                    //                   final result =
                    //                       await showDialog<List<String>>(
                    //                         context: context,
                    //                         barrierDismissible: false,
                    //                         builder: (dialogContext) {
                    //                           return ProductSelectionDialog(
                    //                             productList: productDetailData,
                    //                             selectedProductIds:
                    //                                 _selectedProductIds,
                    //                           );
                    //                         },
                    //                       );

                    //                   if (result != null && mounted) {
                    //                     setState(() {
                    //                       _selectedProductIds
                    //                         ..clear()
                    //                         ..addAll(result);
                    //                     });

                    //                     debugPrint(
                    //                       'Selected Product IDs: '
                    //                       '${_selectedProductIds.join(',')}',
                    //                     );

                    //                     debugPrint(
                    //                       'Selected Product IDs List: '
                    //                       '$_selectedProductIds',
                    //                     );
                    //                   }
                    //                 },
                    //           child: Container(
                    //             width: double.infinity,
                    //             padding: EdgeInsets.symmetric(
                    //               horizontal: 14.w,
                    //               vertical: 15.h,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: productDetailData.isEmpty
                    //                   ? Colors.grey.shade100
                    //                   : Colors.white,
                    //               borderRadius: BorderRadius.circular(22.r),
                    //               boxShadow: productDetailData.isNotEmpty
                    //                   ? [
                    //                       BoxShadow(
                    //                         color: Colors.black.withValues(
                    //                           alpha: 0.08,
                    //                         ),
                    //                         blurRadius: 8,
                    //                         offset: const Offset(0, 2),
                    //                       ),
                    //                     ]
                    //                   : [],
                    //             ),
                    //             child: Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.inventory_2_outlined,
                    //                   color: productDetailData.isEmpty
                    //                       ? Colors.grey
                    //                       : const Color(0xFF087C3A),
                    //                 ),

                    //                 SizedBox(width: 12.w),

                    //                 Expanded(
                    //                   child: _selectedProductIds.isEmpty
                    //                       ? Text(
                    //                           'Select Suggested Product',
                    //                           style: TextStyle(
                    //                             fontSize: 14.sp,
                    //                             color: Colors.grey.shade500,
                    //                           ),
                    //                         )
                    //                       : Text(
                    //                           _selectedProductNames,
                    //                           maxLines: 2,
                    //                           overflow: TextOverflow.ellipsis,
                    //                           style: TextStyle(
                    //                             fontSize: 14.sp,
                    //                             color: Colors.black87,
                    //                             fontWeight: FontWeight.w500,
                    //                           ),
                    //                         ),
                    //                 ),

                    //                 Icon(
                    //                   Icons.keyboard_arrow_down,
                    //                   color: productDetailData.isEmpty
                    //                       ? Colors.grey
                    //                       : Colors.grey.shade600,
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         if (field.hasError)
                    //           Padding(
                    //             padding: EdgeInsets.only(left: 16.w, top: 4.h),
                    //             child: Text(
                    //               field.errorText!,
                    //               style: TextStyle(
                    //                 color: Colors.red,
                    //                 fontSize: 12.sp,
                    //               ),
                    //             ),
                    //           ),
                    //       ],
                    //     );
                    //   },
                    // ),
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
                      labelText: 'Current Product Used',
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

      //  BlocBuilder<StateBloc, StatsState>(
      //   builder: (context, state) {
      //   final productDetailData =
      //       state.farmerDetailsEntity?.productDetailsData ?? [];
      //   DistrictEntity? selectedDistrict;

      //   final cropList = state.farmerDetailsEntity?.cropDetailsData ?? [];

      //   final irrigationList =
      //       state.farmerDetailsEntity?.irrigationDetailsData ?? [];

      //   if (_selectedDistrictId != null && _selectedDistrictId != '0') {
      //     for (final district in state.districtList) {
      //       if (district.fldDistId == _selectedDistrictId) {
      //         selectedDistrict = district;
      //         break;
      //       }
      //     }
      //   }

      //   final talukaList = selectedDistrict?.taluka ?? [];

      //   final districtItems = [
      //     const DropdownMenuItem<String>(
      //       value: '0',
      //       child: Text('Select District'),
      //     ),

      //     ...state.districtList
      //         .where((district) => district.fldDistId != '0')
      //         .map(
      //           (district) => DropdownMenuItem<String>(
      //             value: district.fldDistId,
      //             child: Text(district.fldDistName),
      //           ),
      //         ),
      //   ];

      //   final talukaItems = [
      //     const DropdownMenuItem<String>(
      //       value: '0',
      //       child: Text('Select Taluka'),
      //     ),

      //     ...talukaList
      //         .where((taluka) => taluka.fldTalukaId != '0')
      //         .map(
      //           (taluka) => DropdownMenuItem<String>(
      //             value: taluka.fldTalukaId,
      //             child: Text(taluka.fldName),
      //           ),
      //         ),
      //   ];

      //   final farmerStatusItems = farmerStatus.map((status) {
      //     return DropdownMenuItem<String>(value: status, child: Text(status));
      //   }).toList();

      // },
      // ),
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
                      'Upload Photo *',
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
