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
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  // Initialize immediately to avoid LateInitializationError.
  final _doctorController = TextEditingController();
  final _ownerController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarkController = TextEditingController();

  final _doctorFocus = FocusNode();
  final _ownerFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _remarkFocus = FocusNode();

  bool get isEdit => widget.consultant != null;

  @override
  void initState() {
    super.initState();

    final item = widget.consultant;

    if (item != null) {
      _doctorController.text = item.doctorName;
      _ownerController.text = item.ownerName;
      _mobileController.text = item.mobile;
      _addressController.text = item.address;
    }

    context.read<LocationCubit>().initialize(
      userId: widget.userId,
      stateId: item?.stateId,
      districtId: item?.districtId,
      talukaId: item?.talukaId,
    );
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _remarkController.dispose();

    _doctorFocus.dispose();
    _ownerFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();
    _remarkFocus.dispose();

    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: context.appInputBackground,
      prefixIcon: Icon(icon, size: 20, color: context.appPrimary),
      labelStyle: TextStyle(color: context.appSubText, fontSize: 13),
      floatingLabelStyle: TextStyle(color: context.appPrimary, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      counterText: '',
      border: _border(context.appBorder),
      enabledBorder: _border(context.appBorder),
      focusedBorder: _border(context.appPrimary, width: 1.5),
      disabledBorder: _border(context.appBorder),
      errorBorder: _border(context.appError),
      focusedErrorBorder: _border(context.appError, width: 1.5),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: context.appPrimary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: context.appPrimary, size: 17),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: TextStyle(
                  color: context.appText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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

  Widget _basicDetails() {
    return _section(
      title: 'Doctor Information',
      icon: Icons.medical_services_outlined,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _doctorController,
            focusNode: _doctorFocus,
            labelText: 'Doctor Name *',
            hintText: 'Enter doctor name',
            prefixIcon: Icons.medical_services_outlined,
            textInputAction: TextInputAction.next,
            showKeyboardDone: false,
            onFieldSubmitted: (_) {
              _ownerFocus.requestFocus();
            },
            validator: (value) => _required(value, 'doctor name'),
          ),

          const SizedBox(height: 10),

          CustomTextFormField(
            controller: _ownerController,
            focusNode: _ownerFocus,
            labelText: 'Owner Name *',
            hintText: 'Enter owner name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            showKeyboardDone: false,
            onFieldSubmitted: (_) {
              _mobileFocus.requestFocus();
            },
            validator: (value) => _required(value, 'owner name'),
          ),

          const SizedBox(height: 10),

          // Mobile uses standard TextFormField so no
          // change to CustomTextFormField is required.
          TextFormField(
            controller: _mobileController,
            focusNode: _mobileFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: context.appInputText, fontSize: 14),
            decoration: _decoration(
              'Mobile Number *',
              Icons.phone_android_outlined,
            ),
            validator: _validateMobile,
            onFieldSubmitted: (_) {
              _addressFocus.requestFocus();
            },
          ),
        ],
      ),
    );
  }

  Widget _addressDetails() {
    return _section(
      title: 'Address and Remark',
      icon: Icons.home_outlined,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _addressController,
            focusNode: _addressFocus,
            labelText: 'Address *',
            hintText: 'Enter address',
            prefixIcon: Icons.location_on_outlined,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 2,
            showKeyboardDone: true,
            validator: (value) => _required(value, 'address'),
          ),

          const SizedBox(height: 10),

          CustomTextFormField(
            controller: _remarkController,
            focusNode: _remarkFocus,
            labelText: 'Remark',
            hintText: 'Enter remark',
            prefixIcon: Icons.notes_outlined,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 2,
            showKeyboardDone: true,
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? selected,
    required Map<String, String> items,
    required IconData icon,
    required bool enabled,
    required ValueChanged<String?> onChanged,
    required String keyName,
  }) {
    final value =
        selected != null && selected != '0' && items.containsKey(selected)
        ? selected
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('$keyName-$value'),
      initialValue: value,
      autovalidateMode: _submitted
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      isExpanded: true,
      dropdownColor: context.appCard,
      style: TextStyle(color: context.appInputText, fontSize: 13),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.appPrimary),
      decoration: _decoration(label, icon),
      items: items.entries
          .where((entry) => entry.key != '0')
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (_) {
        // Validate the current Cubit selection rather
        // than a stale FormField value.
        final location = context.read<LocationCubit>().state;
        final currentId = keyName == 'state'
            ? location.stateId
            : keyName.startsWith('district')
            ? location.districtId
            : location.talukaId;

        if (currentId == null ||
            currentId.isEmpty ||
            currentId == '0' ||
            !items.containsKey(currentId)) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _locationDetails() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, location) {
        final cubit = context.read<LocationCubit>();

        final states = {
          for (final item in location.states)
            if (item.id != '0') item.id: item.name,
        };

        final districts = {
          for (final item in location.districts)
            if (item.id != '0') item.id: item.name,
        };

        final talukas = {
          for (final item in location.talukas)
            if (item.id != '0') item.id: item.name,
        };

        return _section(
          title: 'Location Details',
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

              _dropdown(
                label: 'State *',
                selected: location.stateId,
                items: states,
                icon: Icons.map_outlined,
                enabled: !location.statesLoading && states.isNotEmpty,
                onChanged: cubit.changeState,
                keyName: 'state',
              ),

              const SizedBox(height: 10),

              if (location.districtsLoading) ...[
                LinearProgressIndicator(
                  color: context.appPrimary,
                  minHeight: 2,
                ),
                const SizedBox(height: 8),
              ],

              _dropdown(
                label: 'District *',
                selected: location.districtId,
                items: districts,
                icon: Icons.location_city_outlined,
                enabled:
                    location.stateId != null &&
                    !location.districtsLoading &&
                    districts.isNotEmpty,
                onChanged: cubit.changeDistrict,
                keyName: 'district-${location.stateId}',
              ),

              const SizedBox(height: 10),

              _dropdown(
                label: 'Taluka *',
                selected: location.talukaId,
                items: talukas,
                icon: Icons.place_outlined,
                enabled:
                    location.districtId != null &&
                    !location.districtsLoading &&
                    talukas.isNotEmpty,
                onChanged: cubit.changeTaluka,
                keyName:
                    'taluka-${location.stateId}-'
                    '${location.districtId}',
              ),

              if (location.error.isNotEmpty) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 17,
                      color: context.appError,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.error,
                        style: TextStyle(color: context.appError, fontSize: 11),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cubit.initialize(
                          userId: widget.userId,
                          stateId: location.stateId,
                          districtId: location.districtId,
                          talukaId: location.talukaId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _saveConsultant() {
    final bloc = context.read<ConsultantBloc>();

    if (bloc.state.status == ConsultantStatus.saving) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _submitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final location = context.read<LocationCubit>().state;

    final state = location.selectedState;
    final district = location.selectedDistrict;
    final taluka = location.selectedTaluka;

    if (location.statesLoading ||
        location.districtsLoading ||
        state == null ||
        district == null ||
        taluka == null ||
        state.id == '0' ||
        district.id == '0' ||
        taluka.id == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select State, District and Taluka.',
            style: TextStyle(color: context.appColors.onError),
          ),
          backgroundColor: context.appError,
        ),
      );
      return;
    }

    if (widget.userId.trim().isEmpty || widget.userId.trim() == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Employee ID is required.')));
      return;
    }

    if (isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update Doctor API is required for editing.'),
        ),
      );
      return;
    }

    final consultant = ConsultantDoctor(
      id: 'CD${DateTime.now().microsecondsSinceEpoch}',
      doctorName: _doctorController.text.trim(),
      ownerName: _ownerController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      stateId: state.id,
      stateName: state.name,
      districtId: district.id,
      districtName: district.name,
      talukaId: taluka.id,
      talukaName: taluka.name,
      createdAt: DateTime.now(),
    );

    bloc.add(
      AddDoctor(
        userId: widget.userId.trim(),
        consultant: consultant,
        remark: _remarkController.text.trim(),
      ),
    );
  }

  Widget _bottomButton() {
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
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _saveConsultant,
                    icon: saving
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.appOnPrimary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          )
                        : Icon(
                            isEdit ? Icons.edit_outlined : Icons.save_outlined,
                          ),
                    label: Text(
                      saving
                          ? 'Saving...'
                          : isEdit
                          ? 'Update Consultant'
                          : 'Save Consultant',
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsultantBloc, ConsultantState>(
      listenWhen: (previous, current) =>
          previous.status == ConsultantStatus.saving &&
          (current.status == ConsultantStatus.saved ||
              current.status == ConsultantStatus.failure),
      listener: (context, state) {
        if (state.status == ConsultantStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message.isNotEmpty
                    ? state.message
                    : 'Doctor added successfully.',
              ),
              backgroundColor: context.appPrimary,
            ),
          );
          context.pop(true);
        } else if (state.status == ConsultantStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: context.appColors.onError),
              ),
              backgroundColor: context.appError,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        resizeToAvoidBottomInset: true,

        appBar: CustomAppBar(
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: 'Add Consultant Doctor',
          showBackButton: true,
          onBackTap: () => Navigator.pop(context),
          actionIcon: Icons.refresh_rounded,
          // onActionIconTap: _fetchActivities,
        ),

        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      _basicDetails(),
                      const SizedBox(height: 11),
                      _locationDetails(),
                      const SizedBox(height: 11),
                      _addressDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _bottomButton(),
      ),
    );
  }
}
