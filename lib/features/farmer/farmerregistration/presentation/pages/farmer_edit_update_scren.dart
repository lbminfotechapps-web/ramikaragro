import 'dart:io';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/data_list.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_dropdown.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/crop_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/irrigation_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/product_entity.dart'
    show ProductEntity;
import 'package:demo/features/farmer/farmerregistration/domain/entity/selected_crop_detail.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/taluka_entity.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/widgets/crop_details_dialog.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/widgets/product_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class FarmerEditUpdateScren extends StatefulWidget {
  final FarmerlistModel? farmerDetails;
  const FarmerEditUpdateScren({super.key, this.farmerDetails});

  @override
  State<FarmerEditUpdateScren> createState() => _FarmerEditUpdateScrenState();
}

class _FarmerEditUpdateScrenState extends State<FarmerEditUpdateScren> {
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
  // bool _submissionSent = false;
  String? _selectedStateId = '0';
  String? _selectedDistrictId = '0';
  String? _selectedTalukaId = '0';
  String? _selectedFarmerStatus;

  final List<String> _selectedProductIds = [];
  String? _existingProductIds;
  bool _productsMapped = false;
  final List<SelectedCropDetail> _selectedCropDetails = [];

  String selectedSowingDates = '';
  String selectedAcers = '';
  String selectedIrrigationId = '';
  String selectedCropId = '';

  String? _existingSowingDates;
  String? _existingAcers;
  String? _existingIrrigationIds;
  String? _existingCropIds;

  bool _cropDetailsMapped = false;

  @override
  void initState() {
    super.initState();

    if (widget.farmerDetails != null) {
      setData();
    }

    loadApiData();
    context.read<StateBloc>().add(FarmerDropEvent());
  }

  void loadApiData() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id'];
    context.read<StateBloc>().add(StateListEvent(userId: userId.toString()));
    if (_selectedStateId != null && _selectedStateId != '0') {
      context.read<StateBloc>().add(
        DistrictEvent(userId: userId.toString(), stateId: _selectedStateId!),
      );
    }

    // context.read<StateBloc>().add(
    //      FarmerDropEvent(),
    //   );
  }

  void _onStateSelected(String? stateId, StatsState state) async {
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

      // IMPORTANT:
      // User manually changed state,
      // therefore old district/taluka are invalid.
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
    context.read<StateBloc>().add(
      DistrictEvent(userId: userId.toString(), stateId: stateId),
    );
  }

  void _onDistrictSelected(String? districtId, StatsState state) {
    if (districtId == null || districtId.isEmpty) {
      return;
    }

    // Reset district
    if (districtId == '0') {
      setState(() {
        _selectedDistrictId = '0';
        _selectedTalukaId = '0';
      });

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
      debugPrint('District not found: $districtId');

      return;
    }

    debugPrint('Selected District ID: ${selectedDistrict.fldDistId}');

    debugPrint('Selected District Name: ${selectedDistrict.fldDistName}');

    debugPrint('Taluka Count: ${selectedDistrict.taluka.length}');

    setState(() {
      _selectedDistrictId = districtId;

      // Whenever district changes,
      // old taluka must be cleared.
      _selectedTalukaId = '0';
    });
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

        selectedSowingDates = _selectedCropDetails
            .map((item) => _formatApiDate(item.date))
            .join(',');

        selectedAcers = _selectedCropDetails
            .map((item) => item.acre.trim())
            .join(',');

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

  void setData() {
    if (widget.farmerDetails == null) return;
    farmerNameController.text = widget.farmerDetails!.farmerName.toString();
    contactPersonController.text = widget.farmerDetails!.contactPersonName
        .toString();
    addressController.text = widget.farmerDetails!.farmerAddress.toString();
    mobileController.text = widget.farmerDetails!.farmerPhone.toString();

    alternateMobileController.text = widget.farmerDetails!.mobileNo2.toString();
    emailController.text = widget.farmerDetails!.emailId.toString();
    addressController.text = widget.farmerDetails!.farmerAddress.toString();
    villageController.text = widget.farmerDetails!.city.toString();

    _selectedStateId = widget.farmerDetails!.stateId?.toString() ?? '0';
    _selectedDistrictId = widget.farmerDetails!.distId?.toString() ?? '0';
    _selectedTalukaId = widget.farmerDetails!.talukaId?.toString() ?? '0';

    debugPrint('================================');
    debugPrint('State ID: $_selectedStateId');
    debugPrint('District ID: $_selectedDistrictId');
    debugPrint('Taluka ID: $_selectedTalukaId');
    debugPrint('================================');

    final existingStatus = widget.farmerDetails!.statusOfFarmer?.trim();

    if (existingStatus == null || existingStatus.isEmpty) {
      _selectedFarmerStatus = farmerStatus.first;
    } else {
      _selectedFarmerStatus = farmerStatus.firstWhere(
        (status) => status.toLowerCase() == existingStatus.toLowerCase(),
        orElse: () => farmerStatus.first,
      );
    }

    _existingProductIds = widget.farmerDetails!.productId?.toString();
    debugPrint('Existing Product IDs: $_existingProductIds');
    _existingSowingDates = widget.farmerDetails!.sowingDate?.toString();

    _existingAcers = widget.farmerDetails!.acre?.toString();

    _existingIrrigationIds = widget.farmerDetails!.irrigationId?.toString();

    _existingCropIds = widget.farmerDetails!.cropId?.toString();

    debugPrint('================================');
    debugPrint('EXISTING CROP DATA');
    debugPrint('================================');
    debugPrint('Sowing Dates: $_existingSowingDates');
    debugPrint('Acres: $_existingAcers');
    debugPrint('Irrigation IDs: $_existingIrrigationIds');
    debugPrint('Crop IDs: $_existingCropIds');
    debugPrint('================================');
    currentProductUsedController.text = widget.farmerDetails!.currentProductUsed
        .toString();

    // _uploadedImage = widget.farmerDetails!.u;
    remarkController.text = widget.farmerDetails!.remark.toString();
  }

  void _matchExistingProducts(List<ProductEntity> productList) {
    if (_existingProductIds == null || _existingProductIds!.trim().isEmpty) {
      _selectedProductIds.clear();
      return;
    }

    final existingIds = _existingProductIds!
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    debugPrint('Parsed Existing Product IDs: $existingIds');

    // Match only IDs which actually exist
    // in the product API response.
    final matchedIds = productList
        .where((product) => existingIds.contains(product.fldProductId.trim()))
        .map((product) => product.fldProductId.trim())
        .toSet()
        .toList();

    setState(() {
      _selectedProductIds
        ..clear()
        ..addAll(matchedIds);
    });

    debugPrint('Matched Product IDs: $_selectedProductIds');

    debugPrint('Matched Product Names: $_selectedProductNames');
  }

  DateTime? _parseApiDate(String value) {
    final parts = value.split('-');

    if (parts.length != 3) {
      return null;
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      debugPrint('Date parse error: $value | $e');

      return null;
    }
  }

  void _matchExistingCropDetails(
    List<CropEntity> cropList,
    List<IrrigationEntity> irrigationList,
  ) {
    if (_cropDetailsMapped) {
      return;
    }

    if (_existingCropIds == null || _existingCropIds!.trim().isEmpty) {
      _cropDetailsMapped = true;
      return;
    }

    // ============================================
    // SPLIT EXISTING VALUES
    // ============================================

    final cropIds = _existingCropIds!
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    final sowingDates = (_existingSowingDates ?? '')
        .split(',')
        .map((date) => date.trim())
        .toList();

    final acres = (_existingAcers ?? '')
        .split(',')
        .map((acre) => acre.trim())
        .toList();

    final irrigationIds = (_existingIrrigationIds ?? '')
        .split(',')
        .map((id) => id.trim())
        .toList();

    debugPrint('================================');
    debugPrint('MAPPING EXISTING CROP DETAILS');
    debugPrint('================================');
    debugPrint('Crop IDs: $cropIds');
    debugPrint('Dates: $sowingDates');
    debugPrint('Acres: $acres');
    debugPrint('Irrigation IDs: $irrigationIds');
    debugPrint('================================');

    final List<SelectedCropDetail> matchedDetails = [];

    for (int i = 0; i < cropIds.length; i++) {
      final cropId = cropIds[i];

      // --------------------------------------------
      // Find Crop
      // --------------------------------------------

      CropEntity? selectedCrop;

      for (final crop in cropList) {
        if (crop.fldCropId.toString().trim() == cropId) {
          selectedCrop = crop;
          break;
        }
      }

      if (selectedCrop == null) {
        debugPrint('Crop not found for ID: $cropId');
        continue;
      }

      // --------------------------------------------
      // Date
      // --------------------------------------------

      DateTime? selectedDate;

      if (i < sowingDates.length) {
        selectedDate = _parseApiDate(sowingDates[i]);
      }

      // --------------------------------------------
      // Acre
      // --------------------------------------------

      String acre = '';

      if (i < acres.length) {
        acre = acres[i];
      }

      // --------------------------------------------
      // Irrigation
      // --------------------------------------------

      String irrigationId = '';

      if (i < irrigationIds.length) {
        irrigationId = irrigationIds[i];
      }

      IrrigationEntity? selectedIrrigation;

      for (final irrigation in irrigationList) {
        if (irrigation.fldId.toString().trim() == irrigationId) {
          selectedIrrigation = irrigation;
          break;
        }
      }

      if (selectedIrrigation == null) {
        debugPrint('Irrigation not found for ID: $irrigationId');
        continue;
      }

      // --------------------------------------------
      // Add Selected Crop
      // --------------------------------------------

      if (selectedDate == null) {
        debugPrint('Invalid date for crop ID: $cropId');
        continue;
      }

      matchedDetails.add(
        SelectedCropDetail(
          cropId: selectedCrop.fldCropId,
          cropName: selectedCrop.fldCropName,
          date: selectedDate,
          acre: acre,
          irrigationId: selectedIrrigation.fldId,
          irrigationName: selectedIrrigation.fldIrrigationName,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _selectedCropDetails
        ..clear()
        ..addAll(matchedDetails);

      _cropDetailsMapped = true;

      // Prepare final API values also.
      selectedSowingDates = _selectedCropDetails
          .map((item) => _formatApiDate(item.date))
          .join(',');

      selectedAcers = _selectedCropDetails
          .map((item) => item.acre.trim())
          .join(',');

      selectedIrrigationId = _selectedCropDetails
          .map((item) => item.irrigationId)
          .join(',');

      selectedCropId = _selectedCropDetails
          .map((item) => item.cropId)
          .join(',');
    });

    debugPrint('================================');
    debugPrint('MATCHED CROP DETAILS');
    debugPrint('================================');

    for (final item in _selectedCropDetails) {
      debugPrint(
        'Crop: ${item.cropName} | '
        'ID: ${item.cropId} | '
        'Date: ${_formatApiDate(item.date)} | '
        'Acre: ${item.acre} | '
        'Irrigation: ${item.irrigationName} | '
        'Irrigation ID: ${item.irrigationId}',
      );
    }

    debugPrint('Final Crop IDs: $selectedCropId');
    debugPrint('Final Dates: $selectedSowingDates');
    debugPrint('Final Acres: $selectedAcers');
    debugPrint('Final Irrigation IDs: $selectedIrrigationId');

    debugPrint('================================');
  }

  void _mapSelectedState(StatsState state) {
    if (_selectedStateId == null || _selectedStateId == '0') {
      return;
    }

    final exists = state.statentity.any(
      (item) => item.stateId == _selectedStateId,
    );

    if (!exists) {
      debugPrint(
        'Existing state ID $_selectedStateId '
        'not found in state API',
      );

      return;
    }

    debugPrint('Existing state mapped: $_selectedStateId');
  }

  void _mapSelectedDistrictAndTaluka(StatsState state) {
    if (_selectedDistrictId == null || _selectedDistrictId == '0') {
      return;
    }

    final districtExists = state.districtList.any(
      (district) => district.fldDistId == _selectedDistrictId,
    );

    if (!districtExists) {
      debugPrint(
        'Existing district ID $_selectedDistrictId '
        'not found',
      );

      return;
    }

    final district = state.districtList.firstWhere(
      (district) => district.fldDistId == _selectedDistrictId,
    );

    final talukaExists = district.taluka.any(
      (taluka) => taluka.fldTalukaId == _selectedTalukaId,
    );

    if (!talukaExists) {
      debugPrint(
        'Existing taluka ID $_selectedTalukaId '
        'not found',
      );

      return;
    }

    debugPrint('================================');
    debugPrint('EXISTING LOCATION MAPPED');
    debugPrint('State ID: $_selectedStateId');
    debugPrint('District: ${district.fldDistName}');
    debugPrint('District ID: $_selectedDistrictId');
    debugPrint('Taluka ID: $_selectedTalukaId');
    debugPrint('================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: 'Farmer List',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: 'Update Farmer',
        onPressed: () {},
        isLoading: isLoading,
        width: double.infinity,
        height: 52,
        borderRadius: 22,
        backgroundColor: const Color(0xFF087C3A),
        textColor: Colors.white,
      ),

      body: BlocConsumer<StateBloc, StatsState>(
        listener: (context, state) {
          if (state.statentity.isNotEmpty) {
            _mapSelectedState(state);
          }

          // District API completed
          if (state.districtList.isNotEmpty) {
            _mapSelectedDistrictAndTaluka(state);
          }

          if (state.status == StatesStatus.sucess &&
              state.farmerDetailsEntity != null) {
            final products = state.farmerDetailsEntity!.productDetailsData;
            if (products.isNotEmpty) {
              _matchExistingProducts(products);
            }
          }

          if (state.farmerDetailsEntity != null) {
            final cropList = state.farmerDetailsEntity!.cropDetailsData;

            final irrigationList =
                state.farmerDetailsEntity!.irrigationDetailsData;

            if (cropList.isNotEmpty && irrigationList.isNotEmpty) {
              _matchExistingCropDetails(cropList, irrigationList);
            }

            // Your existing product mapping
            final products = state.farmerDetailsEntity!.productDetailsData;

            if (products.isNotEmpty) {
              _matchExistingProducts(products);
            }
          }
          // if (!isLoading || !_submissionSent) return;
          // if (state.status == StatesStatus.farmerRegiSuccess) {
          //   setState(() {
          //     isLoading = false;
          //     _submissionSent = false;
          //   });
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       backgroundColor: AppColors.backgroundColor,
          //       content: Text(
          //         style: TextStyle(color: AppColors.accentGreen),
          //         state.errorMessage ?? 'Farmer Added Successfully',
          //       ),
          //     ),
          //   );
          //   context.go(AppRouter.home);
          // }
          // ============================================
          // API ERROR
          // ============================================
          // else if (state.status == StatesStatus.failed) {
          //   setState(() {
          //     isLoading = false;
          //     _submissionSent = false;
          //   });
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(state.errorMessage ?? 'Submission failed'),
          //     ),
          //   );
          // }
        },
        builder: (context, state) {
          final productDetailData =
              state.farmerDetailsEntity?.productDetailsData ?? [];
          DistrictEntity? selectedDistrict;

          for (final district in state.districtList) {
            if (district.fldDistId == _selectedDistrictId) {
              selectedDistrict = district;
              break;
            }
          }

          final talukaList = selectedDistrict?.taluka ?? [];

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

          // final districtItems = [
          //   const DropdownMenuItem<String>(
          //     value: '0',
          //     child: Text('Select District'),
          //   ),

          //   ...state.districtList
          //       .where((district) => district.fldDistId != '0')
          //       .map(
          //         (district) => DropdownMenuItem<String>(
          //           value: district.fldDistId,
          //           child: Text(district.fldDistName),
          //         ),
          //       ),
          // ];
          final uniqueDistricts = <String, DistrictEntity>{};

          for (final district in state.districtList) {
            final id = district.fldDistId.trim();

            if (id.isEmpty || id == '0') {
              continue;
            }

            // Keep only the first occurrence of each district ID
            if (!uniqueDistricts.containsKey(id)) {
              uniqueDistricts[id] = district;
            }
          }

          final districtItems = <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select District'),
            ),
            ...uniqueDistricts.values.map(
              (district) => DropdownMenuItem<String>(
                value: district.fldDistId.trim(),
                child: Text(district.fldDistName),
              ),
            ),
          ];

          // final talukaItems = [
          //   const DropdownMenuItem<String>(
          //     value: '0',
          //     child: Text('Select Taluka'),
          //   ),

          //   ...talukaList
          //       .where((taluka) => taluka.fldTalukaId != '0')
          //       .map(
          //         (taluka) => DropdownMenuItem<String>(
          //           value: taluka.fldTalukaId,
          //           child: Text(taluka.fldName),
          //         ),
          //       ),
          // ];
          final uniqueTalukas = <String, TalukaEntity>{};

          for (final taluka in talukaList) {
            final id = taluka.fldTalukaId.trim();

            if (id.isEmpty || id == '0') {
              continue;
            }

            // Keep only the first occurrence of each taluka ID
            if (!uniqueTalukas.containsKey(id)) {
              uniqueTalukas[id] = taluka;
            }
          }

          final talukaItems = <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select Taluka'),
            ),
            ...uniqueTalukas.values.map(
              (taluka) => DropdownMenuItem<String>(
                value: taluka.fldTalukaId.trim(),
                child: Text(taluka.fldName),
              ),
            ),
          ];
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
                    Text(_selectedFarmerStatus.toString()),
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

                    // Text(widget.farmerDetails!.contactPersonName.toString()),
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
                      hintText: 'Select Farmer Status',
                      prefixIcon: Icons.local_fire_department_outlined,

                      items: farmerStatus.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),

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

                    FormField<bool>(
                      initialValue: _selectedProductIds.isNotEmpty,
                      validator: (_) {
                        if (_selectedProductIds.isEmpty) {
                          return 'Please select a suggested product';
                        }

                        return null;
                      },
                      builder: (field) {
                        debugPrint(
                          '================ PRODUCT DEBUG ================',
                        );
                        debugPrint(
                          'Product API count: ${productDetailData.length}',
                        );
                        debugPrint(
                          'Existing Product IDs: $_existingProductIds',
                        );
                        debugPrint(
                          'Selected Product IDs: $_selectedProductIds',
                        );
                        debugPrint('Products mapped: $_productsMapped');
                        debugPrint(
                          '================================================',
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: productDetailData.isEmpty
                                  ? null
                                  : () async {
                                      final result =
                                          await showDialog<List<String>>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (dialogContext) {
                                              return ProductSelectionDialog(
                                                productList: productDetailData,
                                                selectedProductIds:
                                                    _selectedProductIds,
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
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 15.h,
                                ),
                                decoration: BoxDecoration(
                                  color: productDetailData.isEmpty
                                      ? Colors.grey.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(22.r),
                                  boxShadow: productDetailData.isNotEmpty
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: productDetailData.isEmpty
                                          ? Colors.grey
                                          : const Color(0xFF087C3A),
                                    ),

                                    SizedBox(width: 12.w),

                                    Expanded(
                                      child: _selectedProductIds.isEmpty
                                          ? Text(
                                              'Select Suggested Product',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey.shade500,
                                              ),
                                            )
                                          : Text(
                                              _selectedProductNames,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),

                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: productDetailData.isEmpty
                                          ? Colors.grey
                                          : Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
}
