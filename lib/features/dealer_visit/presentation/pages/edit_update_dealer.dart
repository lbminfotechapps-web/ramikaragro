import 'dart:io';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/app_image_picker.dart';
import 'package:solufine/core/utility/data_list.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart' show CustomAppBar;
import 'package:solufine/core/utility/widgets/custom_button.dart';
import 'package:solufine/core/utility/widgets/custom_dropdown.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:solufine/features/dealer/data/models/DealerListModel.dart';
import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_event.dart';
import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_state.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/taluka_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditUpdateDealer extends StatefulWidget {
  final DealerListModel? dealerData;
  const EditUpdateDealer(this.dealerData, {super.key});

  @override
  State<EditUpdateDealer> createState() => _EditUpdateDealerState();
}

class _EditUpdateDealerState extends State<EditUpdateDealer> {
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
  String? _selectedDealerStatus;
  String? _selectedFollowUpStatus;
  @override
  void initState() {
    super.initState();
    // _loadStates();
    if (widget.dealerData != null) {
      setData();
    }
    loadApiData();
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ============================================
    // VALIDATE STATE
    // ============================================
    if (_selectedStateId == null ||
        _selectedStateId!.isEmpty ||
        _selectedStateId == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select state')));
      return;
    }

    // ============================================
    // VALIDATE DISTRICT
    // ============================================
    if (_selectedDistrictId == null ||
        _selectedDistrictId!.isEmpty ||
        _selectedDistrictId == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select district')));
      return;
    }

    // ============================================
    // VALIDATE TALUKA
    // ============================================
    if (_selectedTalukaId == null ||
        _selectedTalukaId!.isEmpty ||
        _selectedTalukaId == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select taluka')));
      return;
    }

    // ============================================
    // GET USER DATA
    // ============================================
    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
      return;
    }

    // ============================================
    // OUTLET ID
    // ============================================
    final outletId = widget.dealerData?.outletId.toString() ?? '';

    if (outletId.isEmpty || outletId == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid dealer ID')));
      return;
    }

    // ============================================
    // UPDATE DEALER DEBUG
    // ============================================
    debugPrint('========================================');
    debugPrint('UPDATE DEALER - ALL PARAMS');
    debugPrint('========================================');

    debugPrint('outlet_id: $outletId');
    debugPrint('user_id: $userId');
    debugPrint('type: Dealer');

    debugPrint('outlet_name: ${shopNameController.text.trim()}');

    debugPrint('contact_person: ${ownerNameController.text.trim()}');

    debugPrint('gst_no: ${gstController.text.trim()}');

    debugPrint('mobile_no: ${mobileController.text.trim()}');

    debugPrint('mobile_no2: ${alternateMobileController.text.trim()}');

    debugPrint('email_id: ${emailController.text.trim()}');

    debugPrint('address: ${addressController.text.trim()}');

    debugPrint('state: ${_selectedStateId ?? '0'}');

    debugPrint('district: ${_selectedDistrictId ?? '0'}');

    debugPrint('taluka: ${_selectedTalukaId ?? '0'}');

    debugPrint('remark: ${remarkController.text.trim()}');

    debugPrint('city: ');

    // Kotlin update explicitly sends empty values
    debugPrint('latitude: ');
    debugPrint('longitude: ');

    debugPrint('dealerCode: ${dealerCodeController.text.trim()}');

    debugPrint('activityId: 1');

    debugPrint('followUpType: $followUpType');

    debugPrint('registrationType: $_selectedDealerStatus');

    debugPrint('========================================');
    debugPrint('END UPDATE DEALER PARAMS');
    debugPrint('========================================');

    // ============================================
    // START LOADING
    // ============================================
    if (!mounted) return;

    setState(() {
      isLoading = true;
      _submissionSent = false;
    });

    // ============================================
    // SEND UPDATE EVENT
    // ============================================
    try {
      context.read<AddDealerVisitBlock>().add(
        UpdateDealerEvent(
          outletId: outletId,

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

          // Kotlin update API sends empty location
          latitude: '',
          longitude: '',

          dealerCode: dealerCodeController.text.trim(),

          activityId: '1',

          followUpType: _selectedFollowUpStatus.toString(),

          registrationType: _selectedDealerStatus.toString(),
        ),
      );

      _submissionSent = true;

      debugPrint('================================');
      debugPrint('UPDATE DEALER EVENT SENT');
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

  void loadApiData() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id'];
    context.read<AddDealerVisitBlock>().add(
      StateListEvent(userId: userId.toString()),
    );
    if (_selectedStateId != null && _selectedStateId != '0') {
      context.read<AddDealerVisitBlock>().add(
        DistrictEvent(userId: userId.toString(), stateId: _selectedStateId!),
      );
    }
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

  // void _onStateSelected(String? stateId, AddDealerVisitState state) async {
  //   if (stateId == null || stateId.isEmpty) {
  //     return;
  //   }

  //   debugPrint('================================');
  //   debugPrint('STATE SELECTED');
  //   debugPrint('New State ID: $stateId');
  //   debugPrint('================================');

  //   if (stateId == '0') {
  //     setState(() {
  //       _selectedStateId = '0';
  //       _selectedDistrictId = '0';
  //       _selectedTalukaId = '0';
  //     });

  //     return;
  //   }

  //   setState(() {
  //     _selectedStateId = stateId;

  //     _selectedDistrictId = '0';
  //     _selectedTalukaId = '0';
  //   });

  //   final userData = await SecureStorage.instance.getUserData();

  //   final int? userId = int.tryParse(userData?['user_id']?.toString() ?? '');

  //   if (userId == null) {
  //     debugPrint('Invalid user ID');
  //     return;
  //   }

  //   // Load districts for NEW state
  //   context.read<AddDealerVisitBlock>().add(
  //     DistrictEvent(userId: userId.toString(), stateId: stateId),
  //   );
  // }

  // Future<void> getUserId() async {
  //   final userData = await SecureStorage.instance.getUserData();

  //   final userId = userData?['user_id']?.toString();

  //   if (!mounted || userId == null || userId.isEmpty) {
  //     return;
  //   }

  //   debugPrint('USER ID: $userId');

  //   context.read<AddDealerVisitBlock>().add(StateListEvent(userId: userId));
  // }

  void setData() {
    if (widget.dealerData == null) return;
    shopNameController.text = widget.dealerData!.outletName.toString();
    dealerCodeController.text = widget.dealerData!.code.toString();
    ownerNameController.text = widget.dealerData!.outletPerson.toString();
    addressController.text = widget.dealerData!.outletAddress.toString();
    mobileController.text = widget.dealerData!.outletPersonMobile.toString();

    alternateMobileController.text = widget.dealerData!.outletMobile.toString();
    emailController.text = widget.dealerData!.outletPersonEmail.toString();
    gstController.text = widget.dealerData!.gstNo.toString();
    remarkController.text = widget.dealerData!.remark.toString();
    dateController.text = _dateOnly(widget.dealerData!.lastVisitDateTime);

    final existingDealerStatus = widget.dealerData!.outletType?.trim();

    if (existingDealerStatus == null || existingDealerStatus.isEmpty) {
      _selectedDealerStatus = dealerTypeStatus.first;
    } else {
      _selectedDealerStatus = dealerTypeStatus.firstWhere(
        (status) => status.toLowerCase() == existingDealerStatus.toLowerCase(),
        orElse: () => dealerTypeStatus.first,
      );
    }

    final existingFollowUpStatus = widget.dealerData!.followupType?.trim();

    if (existingFollowUpStatus == null || existingFollowUpStatus.isEmpty) {
      _selectedFollowUpStatus = followUpType.first;
    } else {
      _selectedFollowUpStatus = followUpType.firstWhere(
        (status) =>
            status.toLowerCase() == existingFollowUpStatus.toLowerCase(),
        orElse: () => followUpType.first,
      );
    }

    _selectedStateId = widget.dealerData!.outletState?.toString() ?? '0';
    _selectedDistrictId = widget.dealerData!.outletDistrict?.toString() ?? '0';
    _selectedTalukaId = widget.dealerData!.outletTaluka?.toString() ?? '0';
  }

  String _dateOnly(String? value) {
    final rawValue = value?.trim() ?? '';
    if (rawValue.isEmpty) return '';

    for (final format in [
      DateFormat('dd-MM-yyyy hh:mm a'),
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('yyyy-MM-dd'),
    ]) {
      try {
        return DateFormat('dd-MM-yyyy').format(format.parseStrict(rawValue));
      } catch (_) {}
    }

    return rawValue.split(' ').first;
  }

  void _mapSelectedState(AddDealerVisitState state) {
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
  // void _mapSelectedState(AddDealerVisitState state) {
  //   if (_selectedStateId == null || _selectedStateId == '0') {
  //     return;
  //   }

  //   final exists = state.statentity.any(
  //     (item) => item.stateId == _selectedStateId,
  //   );

  //   if (!exists) {
  //     debugPrint(
  //       'Existing state ID $_selectedStateId '
  //       'not found in state API',
  //     );

  //     return;
  //   }

  //   debugPrint('Existing state mapped: $_selectedStateId');
  // }

  void _mapSelectedDistrictAndTaluka(AddDealerVisitState state) {
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

  void _onDistrictSelected(String? districtId, AddDealerVisitState state) {
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
  // void _onDistrictSelected(String? districtId, AddDealerVisitState state) {
  //   if (districtId == null || districtId.isEmpty) {
  //     return;
  //   }

  //   // Reset district
  //   if (districtId == '0') {
  //     setState(() {
  //       _selectedDistrictId = '0';
  //       _selectedTalukaId = '0';
  //     });

  //     return;
  //   }

  //   DistrictEntity? selectedDistrict;

  //   for (final district in state.districtList) {
  //     if (district.fldDistId == districtId) {
  //       selectedDistrict = district;
  //       break;
  //     }
  //   }

  //   if (selectedDistrict == null) {
  //     debugPrint('District not found: $districtId');

  //     return;
  //   }

  //   debugPrint('Selected District ID: ${selectedDistrict.fldDistId}');

  //   debugPrint('Selected District Name: ${selectedDistrict.fldDistName}');

  //   debugPrint('Taluka Count: ${selectedDistrict.taluka.length}');

  //   setState(() {
  //     _selectedDistrictId = districtId;

  //     // Whenever district changes,
  //     // old taluka must be cleared.
  //     _selectedTalukaId = '0';
  //   });
  // }

  String? _selectedFollowUpType;
  bool _submissionSent = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Dealer Details',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          BlocBuilder<AddDealerVisitBlock, AddDealerVisitState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Update Dealer',
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
          if (state.statentity.isNotEmpty) {
            _mapSelectedState(state);
          }

          // District API completed
          if (state.districtList.isNotEmpty) {
            _mapSelectedDistrictAndTaluka(state);
          }
          if (!isLoading || !_submissionSent) return;
          if (state.addLeaveStatus == AddDealerVisitStatus.dealerUpdateSucess) {
            setState(() {
              isLoading = false;
              _submissionSent = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.backgroundColor,
                content: Text(
                  style: TextStyle(color: AppColors.accentGreen),
                  state.errorMessage ?? 'Farmer Updated Successfully',
                ),
              ),
            );
            context.go(AppRouter.home);
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

          for (final district in state.districtList) {
            if (district.fldDistId == _selectedDistrictId) {
              selectedDistrict = district;
              break;
            }
          }

          final talukaList = selectedDistrict?.taluka ?? [];

          if (_selectedDistrictId != null && _selectedDistrictId != '0') {
            for (final district in state.districtList) {
              if (district.fldDistId == _selectedDistrictId) {
                selectedDistrict = district;
                break;
              }
            }
          }

          final Map<String, DistrictEntity> uniqueDistricts = {};

          for (final district in state.districtList) {
            final id = district.fldDistId.trim();

            if (id.isEmpty || id == '0') {
              continue;
            }

            uniqueDistricts.putIfAbsent(id, () => district);
          }

          final districtItems = <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select District'),
            ),
            ...uniqueDistricts.entries.map((entry) {
              final district = entry.value;

              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(district.fldDistName),
              );
            }),
          ];

          final Map<String, TalukaEntity> uniqueTalukas = {};

          for (final taluka in talukaList) {
            final id = taluka.fldTalukaId.trim();

            if (id.isEmpty || id == '0') {
              continue;
            }

            uniqueTalukas.putIfAbsent(id, () => taluka);
          }

          final talukaItems = <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: '0',
              child: Text('Select Taluka'),
            ),
            ...uniqueTalukas.entries.map((entry) {
              final taluka = entry.value;

              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(taluka.fldName),
              );
            }),
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

          final dealerTypeItems = dealerTypeStatus.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList();

          final followUpTypeItem = followUpType.map((status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList();

          final selectedDistrictValue =
              uniqueDistricts.containsKey(_selectedDistrictId)
              ? _selectedDistrictId
              : null;

          final selectedTalukaValue =
              uniqueTalukas.containsKey(_selectedTalukaId)
              ? _selectedTalukaId
              : null;

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
                      value: _selectedDealerStatus,

                      hintText: 'Select Dealer Type',

                      prefixIcon: Icons.person_outline,

                      enabled: true,

                      items: dealerTypeItems,

                      onChanged: (value) {
                        setState(() {
                          _selectedDealerStatus = value;
                        });

                        debugPrint(
                          'Selected Farmer Status: $_selectedDealerStatus',
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
                      maxLines: 3,
                    ),

                    SizedBox(height: 10.h),

                    CustomTextFormField(
                      maxLength: 10,
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
                      maxLength: 10,
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

                    //   items: stateItems,

                    //   onChanged: (value) {
                    //     _onStateSelected(value, state);
                    //   },

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
                      value: selectedDistrictValue,
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
                      value: selectedTalukaValue,
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

                    // CustomDropdown<String>(
                    //   value: _selectedTalukaId == '0'
                    //       ? null
                    //       : _selectedTalukaId,
                    //   hintText: 'Select Taluka',
                    //   prefixIcon: Icons.location_on_outlined,
                    //   enabled:
                    //       _selectedDistrictId != null &&
                    //       _selectedDistrictId != '0' &&
                    //       talukaList.isNotEmpty,
                    //   items: talukaItems,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _selectedTalukaId = value ?? '0';
                    //     });

                    //     debugPrint('Selected Taluka ID: $_selectedTalukaId');
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value == '0') {
                    //       return 'Please select taluka';
                    //     }

                    //     return null;
                    //   },
                    // ),
                    SizedBox(height: 10.h),

                    _textField(
                      controller: dateController,
                      hintText: 'Next Visit Date *',
                      icon: Icons.calendar_today_outlined,
                      enabled: false,
                      readOnly: true,
                      // suffixIcon: Icons.calendar_month_outlined,
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
                    CustomDropdown<String>(
                      value: _selectedFollowUpStatus,
                      hintText: 'Follow Up Type',
                      prefixIcon: Icons.event_note_outlined,
                      enabled: true,
                      items: followUpTypeItem,
                      onChanged: (value) {
                        setState(() {
                          _selectedFollowUpStatus = value;
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
}
