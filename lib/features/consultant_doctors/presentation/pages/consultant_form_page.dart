import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';

import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';

import '../../domain/entities/consultant_doctor.dart';
import '../bloc/consultant_bloc.dart';
import '../bloc/location_cubit.dart';

class ConsultantFormPage extends StatefulWidget {
  final ConsultantDoctor? consultant;
  final String userId;

  const ConsultantFormPage({super.key, this.consultant, required this.userId});

  @override
  State<ConsultantFormPage> createState() => _ConsultantFormPageState();
}

class _ConsultantFormPageState extends State<ConsultantFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS - INITIALIZED IMMEDIATELY
  // FIXES LateInitializationError
  // ============================================================

  final TextEditingController _doctorController = TextEditingController();

  final TextEditingController _ownerController = TextEditingController();

  final TextEditingController _mobileController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _doctorFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  bool get isEdit => widget.consultant != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final consultant = widget.consultant;

    // EDIT MODE - SET EXISTING VALUES
    if (consultant != null) {
      _doctorController.text = consultant.doctorName;
      _ownerController.text = consultant.ownerName;
      _mobileController.text = consultant.mobile;
      _addressController.text = consultant.address;
    }

    // LOAD DYNAMIC LOCATION OPTIONS
    context.read<LocationCubit>().initialize(
      userId: widget.userId,
      stateId: consultant?.stateId,
      districtId: consultant?.districtId,
      talukaId: consultant?.talukaId,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _doctorController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _addressController.dispose();

    _doctorFocus.dispose();
    _ownerFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _mobileValidator(String? value) {
    final mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Please enter mobile number';
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  // ============================================================
  // COMMON SECTION CARD
  // ============================================================

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appPrimary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: context.appPrimary),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.appText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.appSubText,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE FIELD
  // STANDARD TEXTFORMFIELD - DIGITS ONLY
  // ============================================================

  Widget _buildMobileField() {
    OutlineInputBorder fieldBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: _mobileController,
      focusNode: _mobileFocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: context.appInputText, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Mobile Number *',
        hintText: 'Enter 10-digit mobile number',
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: context.appInputBackground,
        labelStyle: TextStyle(color: context.appSubText, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: context.appPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: context.appSubText, fontSize: 13),
        prefixIcon: Icon(
          Icons.phone_android_outlined,
          color: context.appPrimary,
          size: 21,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: fieldBorder(context.appBorder),
        enabledBorder: fieldBorder(context.appBorder),
        focusedBorder: fieldBorder(context.appPrimary, width: 1.5),
        errorBorder: fieldBorder(context.appError),
        focusedErrorBorder: fieldBorder(context.appError, width: 1.5),
      ),
      onFieldSubmitted: (_) {
        _addressFocus.requestFocus();
      },
      validator: _mobileValidator,
    );
  }

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  Widget _buildBasicDetails() {
    return _buildSection(
      title: 'Basic Information',
      subtitle: 'Doctor and owner details',
      icon: Icons.medical_services_outlined,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _doctorController,
            focusNode: _doctorFocus,
            hintText: 'Enter doctor name',
            labelText: 'Doctor Name *',
            prefixIcon: Icons.medical_services_outlined,
            textInputAction: TextInputAction.next,
            showKeyboardDone: false,
            onFieldSubmitted: (_) {
              _ownerFocus.requestFocus();
            },
            validator: (value) => _requiredValidator(value, 'doctor name'),
          ),

          const SizedBox(height: 10),

          CustomTextFormField(
            controller: _ownerController,
            focusNode: _ownerFocus,
            hintText: 'Enter owner name',
            labelText: 'Owner Name *',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            showKeyboardDone: false,
            onFieldSubmitted: (_) {
              _mobileFocus.requestFocus();
            },
            validator: (value) => _requiredValidator(value, 'owner name'),
          ),

          const SizedBox(height: 10),

          _buildMobileField(),

          const SizedBox(height: 10),

          CustomTextFormField(
            controller: _addressController,
            focusNode: _addressFocus,
            hintText: 'Enter complete address',
            labelText: 'Address *',
            prefixIcon: Icons.location_on_outlined,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 2,
            showKeyboardDone: true,
            validator: (value) => _requiredValidator(value, 'address'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DROPDOWN DECORATION
  // ============================================================

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    OutlineInputBorder fieldBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      filled: true,
      isDense: true,
      fillColor: context.appInputBackground,
      prefixIcon: Icon(
        icon,
        size: 21,
        color: enabled ? context.appPrimary : context.appSubText,
      ),
      labelStyle: TextStyle(color: context.appSubText, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: context.appPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: fieldBorder(context.appBorder),
      enabledBorder: fieldBorder(context.appBorder),
      disabledBorder: fieldBorder(context.appBorder),
      focusedBorder: fieldBorder(context.appPrimary, width: 1.5),
      errorBorder: fieldBorder(context.appError),
      focusedErrorBorder: fieldBorder(context.appError, width: 1.5),
    );
  }

  // ============================================================
  // REUSABLE DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String? selectedValue,
    required Map<String, String> options,
    required IconData icon,
    required bool enabled,
    required ValueChanged<String?> onChanged,
    required String identityKey,
  }) {
    final validValue =
        selectedValue != null && options.containsKey(selectedValue)
        ? selectedValue
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('$identityKey-$validValue'),
      initialValue: validValue,
      isExpanded: true,
      dropdownColor: context.appCard,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.appPrimary),
      style: TextStyle(color: context.appInputText, fontSize: 13),
      decoration: _dropdownDecoration(
        label: label,
        icon: icon,
        enabled: enabled,
      ),
      items: options.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty || value == '0') {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  // ============================================================
  // LOCATION SECTION
  // API-DRIVEN STATE / DISTRICT / TALUKA
  // ============================================================

  Widget _buildLocationDetails() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, location) {
        final cubit = context.read<LocationCubit>();

        final states = <String, String>{
          for (final item in location.states) item.id: item.name,
        };

        final districts = <String, String>{
          for (final item in location.districts) item.id: item.name,
        };

        final talukas = <String, String>{
          for (final item in location.talukas) item.id: item.name,
        };

        return _buildSection(
          title: 'Location Details',
          subtitle: 'Select state, district and taluka',
          icon: Icons.map_outlined,
          child: Column(
            children: [
              if (location.statesLoading) ...[
                LinearProgressIndicator(
                  color: context.appPrimary,
                  minHeight: 2,
                ),
                const SizedBox(height: 8),
              ],

              _buildDropdown(
                label: 'State *',
                selectedValue: location.stateId,
                options: states,
                icon: Icons.map_outlined,
                enabled: !location.statesLoading && states.isNotEmpty,
                identityKey: 'state',
                onChanged: cubit.changeState,
              ),

              const SizedBox(height: 10),

              if (location.districtsLoading) ...[
                LinearProgressIndicator(
                  color: context.appPrimary,
                  minHeight: 2,
                ),
                const SizedBox(height: 8),
              ],

              _buildDropdown(
                label: 'District *',
                selectedValue: location.districtId,
                options: districts,
                icon: Icons.location_city_outlined,
                enabled:
                    location.stateId != null &&
                    !location.districtsLoading &&
                    districts.isNotEmpty,
                identityKey: 'district-${location.stateId}',
                onChanged: cubit.changeDistrict,
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                label: 'Taluka *',
                selectedValue: location.talukaId,
                options: talukas,
                icon: Icons.place_outlined,
                enabled: location.districtId != null && talukas.isNotEmpty,
                identityKey:
                    'taluka-${location.stateId}-'
                    '${location.districtId}',
                onChanged: cubit.changeTaluka,
              ),

              if (location.error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.appError.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.appError.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 17,
                            color: context.appError,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              location.error,
                              style: TextStyle(
                                color: context.appError,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            cubit.initialize(
                              userId: widget.userId,
                              stateId: location.stateId,
                              districtId: location.districtId,
                              talukaId: location.talukaId,
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (location.selectedState != null &&
                  location.selectedDistrict != null &&
                  location.selectedTaluka != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: context.appPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: context.appPrimary,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '${location.selectedTaluka!.name}, '
                          '${location.selectedDistrict!.name}, '
                          '${location.selectedState!.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.appPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medical_services_outlined,
            size: 22,
            color: context.appOnPrimary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Update Consultant' : 'New Consultant Doctor',
                style: TextStyle(
                  color: context.appText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Enter doctor and location information',
                style: TextStyle(color: context.appSubText, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveConsultant() {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final location = context.read<LocationCubit>().state;

    final selectedState = location.selectedState;
    final selectedDistrict = location.selectedDistrict;
    final selectedTaluka = location.selectedTaluka;

    if (location.statesLoading ||
        location.districtsLoading ||
        selectedState == null ||
        selectedDistrict == null ||
        selectedTaluka == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select State, District and Taluka.'),
          backgroundColor: context.appError,
        ),
      );
      return;
    }

    final consultant = ConsultantDoctor(
      id: widget.consultant?.id ?? 'CD${DateTime.now().microsecondsSinceEpoch}',
      doctorName: _doctorController.text.trim(),
      ownerName: _ownerController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      stateId: selectedState.id,
      stateName: selectedState.name,
      districtId: selectedDistrict.id,
      districtName: selectedDistrict.name,
      talukaId: selectedTaluka.id,
      talukaName: selectedTaluka.name,
      createdAt: widget.consultant?.createdAt ?? DateTime.now(),
    );

    context.read<ConsultantBloc>().add(SaveConsultant(consultant));
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 11),
        decoration: BoxDecoration(
          color: context.appCard,
          border: Border(top: BorderSide(color: context.appBorder)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: BlocBuilder<ConsultantBloc, ConsultantState>(
              builder: (context, state) {
                final saving = state.status == ConsultantStatus.saving;

                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _saveConsultant,
                    icon: saving
                        ? SizedBox(
                            height: 17,
                            width: 17,
                            child: CircularProgressIndicator(
                              color: context.appOnPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isEdit
                                ? Icons.check_circle_outline
                                : Icons.save_outlined,
                            size: 19,
                          ),
                    label: Text(
                      saving
                          ? 'Saving...'
                          : isEdit
                          ? 'Update Consultant'
                          : 'Save Consultant',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsultantBloc, ConsultantState>(
      listenWhen: (previous, current) =>
          previous.status == ConsultantStatus.saving &&
          (current.status == ConsultantStatus.saved ||
              current.status == ConsultantStatus.failure),
      listener: (context, state) {
        if (state.status == ConsultantStatus.saved) {
          context.pop(true);
          return;
        }

        if (state.status == ConsultantStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.appError,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        resizeToAvoidBottomInset: true,

        appBar: CustomAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.go(AppRouter.home),
          ),
          title: 'Add Consultant Doctor',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
          actionIcon: Icons.refresh_rounded,
          // onActionIconTap: _refreshList,
        ),

        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 13),
                      _buildBasicDetails(),
                      const SizedBox(height: 11),
                      _buildLocationDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomButton(),
      ),
    );
  }
}
