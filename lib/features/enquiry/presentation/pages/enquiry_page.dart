import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:solufine/features/enquiry/domain/entities/district_entity.dart';
import 'package:solufine/features/enquiry/domain/entities/state_entity.dart';
import 'package:solufine/features/enquiry/domain/entities/taluka_entity.dart';
import 'package:solufine/features/enquiry/presentation/bloc/enquiry_bloc.dart';
import 'package:solufine/features/enquiry/presentation/bloc/enquiry_event.dart';
import 'package:solufine/features/enquiry/presentation/bloc/enquiry_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnquiryPage extends StatefulWidget {
  final String productId;
  final String productName;

  const EnquiryPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _mobileController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _villageController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  // ============================================================
  // SELECTED VALUES
  // ============================================================

  String? selectedStateId;
  String? selectedDistrictId;
  String? selectedTalukaId;

  String userId = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    debugPrint('======================================');
    debugPrint('PRODUCT ENQUIRY PAGE');
    debugPrint('PRODUCT ID   : ${widget.productId}');
    debugPrint('PRODUCT NAME : ${widget.productName}');
    debugPrint('======================================');

    _loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      final storedUserId =
          userData?['user_id']?.toString().trim() ?? '';

      debugPrint(
        'STORED USER ID = $storedUserId',
      );

      // if (storedUserId.isEmpty) {
      //   debugPrint(
      //     'ERROR: USER ID IS EMPTY',
      //   );

      //   if (mounted) {
      //     _showMessage(
      //       'User ID not found. Please login again.',
      //       isError: true,
      //     );
      //   }

      //   return;
      // }

      if (!mounted) return;

      setState(() {
        userId = storedUserId;
      });

      debugPrint(
        'PRODUCT ENQUIRY USER ID = $userId',
      );

      // ========================================================
      // GET STATES
      // ========================================================

      debugPrint('======================================');
      debugPrint('GET STATES');
      debugPrint('USER ID: $userId');
      debugPrint('======================================');

      context.read<EnquiryBloc>().add(
        GetStatesEvent(
          userId: userId,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'LOAD USER ERROR = $e',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        _showMessage(
          'Unable to load user information',
          isError: true,
        );
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
Widget build(BuildContext context) {
  return BlocListener<EnquiryBloc, EnquiryState>(
    listenWhen: (previous, current) {
      // Listen ONLY when submit status changes.
      return previous.submitStatus != current.submitStatus;
    },
    listener: (context, state) {
      // ------------------------------------------------------
      // SUBMIT SUCCESS
      // ------------------------------------------------------

      if (state.submitStatus == SubmitEnquiryStatus.success) {
        _showSuccessDialog(
          state.submitMessage.isNotEmpty
              ? state.submitMessage
              : 'Enquiry submitted successfully.',
        );
        return;
      }

      // ------------------------------------------------------
      // SUBMIT ERROR
      // ------------------------------------------------------

      if (state.submitStatus == SubmitEnquiryStatus.error) {
        _showErrorSnackBar(
          state.submitMessage.isNotEmpty
              ? state.submitMessage
              : 'Something went wrong.',
        );
        return;
      }
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF6F9F7),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductCard(),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  icon: Icons.person_outline_rounded,
                  title: 'Contact Details',
                  subtitle: 'Enter your basic contact information',
                ),

                const SizedBox(height: 14),

                _buildContactFields(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.location_on_outlined,
                  title: 'Location Details',
                  subtitle: 'Select your location',
                ),

                const SizedBox(height: 14),

                _buildLocationFields(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.description_outlined,
                  title: 'Enquiry Details',
                  subtitle: 'Tell us what you would like to know',
                ),

                const SizedBox(height: 14),

                _buildEnquiryFields(),

                const SizedBox(height: 28),

                _buildSubmitButton(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
     title: 'Product Enquiry',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
       
      );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard() {
    final productName =
        widget.productName.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F7ED),
            Color(0xFFF5FBF7),
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFD5ECDD),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color:
                  AppColors.accentGreen,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Product',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  productName.isNotEmpty
                      ? productName
                      : 'Product Enquiry',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    color:
                        Color(0xFF1D2A22),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFD8F0DF),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Text(
              'ENQUIRY',
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF087C3A),
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFE3F3E8),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color:
                AppColors.accentGreen,
            size: 21,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF202A24),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTACT FIELDS
  // ============================================================

  Widget _buildContactFields() {
    return Column(
      children: [
        CustomTextFormField(
          controller:
              _nameController,
          hintText:
              'Enter your name',
          labelText: 'Name *',
          prefixIcon:
              Icons.person_outline_rounded,
          suffixIcon: null,
          keyboardType:
              TextInputType.name,
          validator:
              _validateName,
        ),

        const SizedBox(height: 14),

        CustomTextFormField(
          controller:
              _mobileController,
          hintText:
              'Enter 10 digit mobile number',
          labelText:
              'Mobile Number *',
          prefixIcon:
              Icons.phone_outlined,
          suffixIcon: null,
          keyboardType:
              TextInputType.phone,
          maxLength: 10,
          validator:
              _validateMobile,
          onChanged: (value) {
            if (value.length > 10) {
              _mobileController.text =
                  value.substring(0, 10);

              _mobileController.selection =
                  TextSelection.fromPosition(
                TextPosition(
                  offset:
                      _mobileController
                          .text
                          .length,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 14),

        CustomTextFormField(
          controller:
              _emailController,
          hintText:
              'Enter email address',
          labelText: 'Email',
          prefixIcon:
              Icons.email_outlined,
          suffixIcon: null,
          keyboardType:
              TextInputType.emailAddress,
          validator:
              _validateEmail,
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION FIELDS
  // ============================================================

  Widget _buildLocationFields() {
    return BlocBuilder<
        EnquiryBloc,
        EnquiryState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildStateDropdown(state),

            const SizedBox(height: 14),

            _buildDistrictDropdown(state),

            const SizedBox(height: 14),

            _buildTalukaDropdown(state),

            const SizedBox(height: 14),

            CustomTextFormField(
              controller:
                  _villageController,
              hintText:
                  'Enter village name',
              labelText: 'Village *',
              prefixIcon: Icons
                  .holiday_village_outlined,
              suffixIcon: null,
              keyboardType:
                  TextInputType.text,
              validator:
                  _validateVillage,
            ),

            const SizedBox(height: 14),

            CustomTextFormField(
              controller:
                  _addressController,
              hintText:
                  'Enter complete address',
              labelText: 'Address *',
              prefixIcon: Icons
                  .location_on_outlined,
              suffixIcon: null,
              keyboardType:
                  TextInputType.streetAddress,
              maxLines: 3,
              validator:
                  _validateAddress,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATE DROPDOWN
  // ============================================================

  Widget _buildStateDropdown(
    EnquiryState state,
  ) {
    final List<StateEntity> states =
        state.states;

    final validValue = states.any(
      (item) =>
          item.id.trim() ==
          selectedStateId?.trim(),
    )
        ? selectedStateId
        : null;

    debugPrint(
      '========== STATE DROPDOWN ==========',
    );
    debugPrint(
      'State Status: ${state.stateStatus}',
    );
    debugPrint(
      'States Count: ${states.length}',
    );

    for (final item in states) {
      debugPrint(
        'STATE ITEM -> '
        'ID=${item.id}, '
        'NAME=${item.name}',
      );
    }

    debugPrint(
      'Selected State: $selectedStateId',
    );
    debugPrint(
      'Valid Value: $validValue',
    );
    debugPrint(
      '====================================',
    );

    final bool isLoading =
        state.stateStatus ==
            EnquiryStatus.loading;

    return _buildDropdownContainer(
      child:
          DropdownButtonFormField<String>(
        value: validValue,
        isExpanded: true,

        icon: _dropdownIcon(
          isLoading,
        ),

        decoration:
            _dropdownDecoration(
          icon: Icons.map_outlined,
          label: 'State *',
          hint: isLoading
              ? 'Loading states...'
              : states.isEmpty
                  ? 'No states available'
                  : 'Select state',
        ),

        items: states
            .where(
              (item) =>
                  item.id
                      .trim()
                      .isNotEmpty &&
                  item.id.trim() != '0' &&
                  item.name
                      .trim()
                      .isNotEmpty,
            )
            .map(
              (StateEntity item) {
                return DropdownMenuItem<
                    String>(
                  value: item.id.trim(),
                  child: Text(
                    item.name.trim(),
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      color:
                          Color(0xFF202A24),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                );
              },
            )
            .toList(),

        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Please select state';
          }

          return null;
        },

        onChanged: isLoading
            ? null
            : states.isEmpty
                ? null
                : (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return;
                    }

                    final String stateId =
                        value.trim();

                    debugPrint(
                      'SELECTED STATE ID = $stateId',
                    );

                    setState(() {
                      selectedStateId =
                          stateId;

                      selectedDistrictId =
                          null;

                      selectedTalukaId =
                          null;
                    });

                    context
                        .read<EnquiryBloc>()
                        .add(
                          GetDistrictsEvent(
                            userId: userId,
                            stateId: stateId,
                          ),
                        );
                  },
      ),
    );
  }

  // ============================================================
  // DISTRICT DROPDOWN
  // ============================================================

  Widget _buildDistrictDropdown(
    EnquiryState state,
  ) {
    final List<DistrictEntity> districts =
        state.districts;

    final validValue = districts.any(
      (item) =>
          item.id.trim() ==
          selectedDistrictId?.trim(),
    )
        ? selectedDistrictId
        : null;

    final bool isLoading =
        state.districtStatus ==
            EnquiryStatus.loading;

    final bool disabled =
        selectedStateId == null ||
        selectedStateId!.trim().isEmpty ||
        isLoading;

    return _buildDropdownContainer(
      child:
          DropdownButtonFormField<String>(
        value: validValue,
        isExpanded: true,

        icon: _dropdownIcon(
          isLoading,
        ),

        decoration:
            _dropdownDecoration(
          icon:
              Icons.location_city_outlined,
          label: 'District *',
          hint: selectedStateId == null
              ? 'Select state first'
              : isLoading
                  ? 'Loading districts...'
                  : districts.isEmpty
                      ? 'No districts available'
                      : 'Select district',
        ),

        items: districts
            .where(
              (item) =>
                  item.id
                      .trim()
                      .isNotEmpty &&
                  item.id.trim() != '0' &&
                  item.name
                      .trim()
                      .isNotEmpty,
            )
            .map(
              (DistrictEntity item) {
                return DropdownMenuItem<
                    String>(
                  value: item.id.trim(),
                  child: Text(
                    item.name.trim(),
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      color:
                          Color(0xFF202A24),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                );
              },
            )
            .toList(),

        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Please select district';
          }

          return null;
        },

        onChanged: disabled
            ? null
            : (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return;
                }

                final String districtId =
                    value.trim();

                debugPrint(
                  'SELECTED DISTRICT ID = '
                  '$districtId',
                );

                setState(() {
                  selectedDistrictId =
                      districtId;

                  selectedTalukaId =
                      null;
                });

                context
                    .read<EnquiryBloc>()
                    .add(
                      GetTalukasEvent(
                        userId: userId,
                        districtId:
                            districtId,
                      ),
                    );
              },
      ),
    );
  }

  // ============================================================
  // TALUKA DROPDOWN
  // ============================================================

  Widget _buildTalukaDropdown(
    EnquiryState state,
  ) {
    final List<TalukaEntity> talukas =
        state.talukas;

    final validValue = talukas.any(
      (item) =>
          item.talukaId.trim() ==
          selectedTalukaId?.trim(),
    )
        ? selectedTalukaId
        : null;

    final bool isLoading =
        state.talukaStatus ==
            EnquiryStatus.loading;

    final bool disabled =
        selectedDistrictId == null ||
        selectedDistrictId!.trim().isEmpty ||
        isLoading;

    return _buildDropdownContainer(
      child:
          DropdownButtonFormField<String>(
        value: validValue,
        isExpanded: true,

        icon: _dropdownIcon(
          isLoading,
        ),

        decoration:
            _dropdownDecoration(
          icon: Icons
              .account_balance_outlined,
          label: 'Taluka *',
          hint: selectedDistrictId == null
              ? 'Select district first'
              : isLoading
                  ? 'Loading talukas...'
                  : talukas.isEmpty
                      ? 'No talukas available'
                      : 'Select taluka',
        ),

        items: talukas
            .where(
              (item) =>
                  item.talukaId
                      .trim()
                      .isNotEmpty &&
                  item.talukaId.trim() != '0' &&
                  item.name
                      .trim()
                      .isNotEmpty,
            )
            .map(
              (TalukaEntity item) {
                return DropdownMenuItem<
                    String>(
                  value:
                      item.talukaId.trim(),
                  child: Text(
                    item.name.trim(),
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      color:
                          Color(0xFF202A24),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                );
              },
            )
            .toList(),

        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Please select taluka';
          }

          return null;
        },

        onChanged: disabled
            ? null
            : (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return;
                }

                final String talukaId =
                    value.trim();

                debugPrint(
                  'SELECTED TALUKA ID = '
                  '$talukaId',
                );

                setState(() {
                  selectedTalukaId =
                      talukaId;
                });
              },
      ),
    );
  }

  // ============================================================
  // ENQUIRY FIELDS
  // ============================================================

  Widget _buildEnquiryFields() {
    return CustomTextFormField(
      controller:
          _messageController,
      hintText:
          'Write your enquiry here...',
      labelText:
          'Message / Remark *',
      prefixIcon:
          Icons.chat_bubble_outline_rounded,
      suffixIcon: null,
      keyboardType:
          TextInputType.multiline,
      maxLines: 5,
      maxLength: 500,
      validator:
          _validateMessage,
    );
  }

  // ============================================================
  // DROPDOWN CONTAINER
  // ============================================================

  Widget _buildDropdownContainer({
    required Widget child,
  }) {
    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // ============================================================
  // DROPDOWN DECORATION
  // ============================================================

  InputDecoration _dropdownDecoration({
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      labelStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
        fontWeight:
            FontWeight.w400,
      ),

      floatingLabelStyle:
          const TextStyle(
        color:
            AppColors.accentGreen,
        fontSize: 14,
        fontWeight:
            FontWeight.w600,
      ),

      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 15,
        fontWeight:
            FontWeight.w400,
      ),

      prefixIcon: Padding(
        padding:
            const EdgeInsets.all(10),
        child: Container(
          decoration:
              const BoxDecoration(
            shape: BoxShape.circle,
            color:
                Color(0xFFE4F4E9),
          ),
          child: Icon(
            icon,
            color:
                AppColors.accentGreen,
            size: 22,
          ),
        ),
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color:
              Color(0xFF087C3A),
          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN ICON
  // ============================================================

  Widget _dropdownIcon(
    bool loading,
  ) {
    if (loading) {
      return const Padding(
        padding:
            EdgeInsets.only(right: 14),
        child: SizedBox(
          height: 18,
          width: 18,
          child:
              CircularProgressIndicator(
            strokeWidth: 2,
            color:
                AppColors.accentGreen,
          ),
        ),
      );
    }

    return const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Colors.grey,
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return BlocBuilder<
        EnquiryBloc,
        EnquiryState>(
      buildWhen:
          (previous, current) =>
              previous.submitStatus !=
              current.submitStatus,
      builder: (context, state) {
        final bool isLoading =
            state.submitStatus ==
                SubmitEnquiryStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : _submitEnquiry,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.accentGreen,
              foregroundColor:
                  Colors.white,
              disabledBackgroundColor:
                  AppColors.accentGreen
                      .withOpacity(.55),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            child: AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey(
                        'loading',
                      ),
                      height: 23,
                      width: 23,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Row(
                      key: ValueKey(
                        'submit',
                      ),
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          size: 20,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Submit Enquiry',
                          style:
                              TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SUBMIT ENQUIRY
  // ============================================================

  void _submitEnquiry() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    // ----------------------------------------------------------
    // USER ID
    // ----------------------------------------------------------

    // if (userId.trim().isEmpty) {
    //   _showErrorSnackBar(
    //     'User ID not found. Please login again.',
    //   );
    //   return;
    // }

    // ----------------------------------------------------------
    // STATE
    // ----------------------------------------------------------

    if (selectedStateId == null ||
        selectedStateId!.trim().isEmpty ||
        selectedStateId == '0') {
      _showErrorSnackBar(
        'Please select state.',
      );
      return;
    }

    // ----------------------------------------------------------
    // DISTRICT
    // ----------------------------------------------------------

    if (selectedDistrictId == null ||
        selectedDistrictId!
            .trim()
            .isEmpty ||
        selectedDistrictId == '0') {
      _showErrorSnackBar(
        'Please select district.',
      );
      return;
    }

    // ----------------------------------------------------------
    // TALUKA
    // ----------------------------------------------------------

    if (selectedTalukaId == null ||
        selectedTalukaId!
            .trim()
            .isEmpty ||
        selectedTalukaId == '0') {
      _showErrorSnackBar(
        'Please select taluka.',
      );
      return;
    }

    // ----------------------------------------------------------
    // PRODUCT
    // ----------------------------------------------------------

    final String productName =
        widget.productName.trim();

    if (productName.isEmpty) {
      _showErrorSnackBar(
        'Product name is missing.',
      );
      return;
    }

    // ==========================================================
    // PARAMETERS
    // ==========================================================

    final Map<String, String> params = {
      'userId': userId.trim(),

      'productId':
          widget.productId.trim(),

      'product_name':
          productName,

      'name':
          _nameController.text.trim(),

      'mobileNo':
          _mobileController.text.trim(),

      'email':
          _emailController.text.trim(),

      'stateId':
          selectedStateId!.trim(),

      'districtId':
          selectedDistrictId!.trim(),

      'talukaId':
          selectedTalukaId!.trim(),

      'village':
          _villageController.text.trim(),

      'city':
          _villageController.text.trim(),

      'address':
          _addressController.text.trim(),

      'message':
          _messageController.text.trim(),
    };

    // ==========================================================
    // DEBUG
    // ==========================================================

    debugPrint(
      '======================================',
    );

    debugPrint(
      'SUBMIT ENQUIRY',
    );

    debugPrint(
      'USER ID      : $userId',
    );

    debugPrint(
      'PRODUCT ID   : ${widget.productId}',
    );

    debugPrint(
      'PRODUCT NAME : $productName',
    );

    debugPrint(
      'STATE ID     : $selectedStateId',
    );

    debugPrint(
      'DISTRICT ID  : $selectedDistrictId',
    );

    debugPrint(
      'TALUKA ID    : $selectedTalukaId',
    );

    debugPrint(
      'REQUEST DATA : $params',
    );

    debugPrint(
      '======================================',
    );

    // ==========================================================
    // SEND
    // ==========================================================

    context.read<EnquiryBloc>().add(
      SubmitEnquiryEvent(
        params: params,
      ),
    );
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _validateName(
    String? value,
  ) {
    final name =
        value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your name';
    }

    return null;
  }

  String? _validateMobile(
    String? value,
  ) {
    final mobile =
        value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Please enter mobile number';
    }

    if (!RegExp(r'^\d{10}$')
        .hasMatch(mobile)) {
      return 'Mobile number must be 10 digits';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validateVillage(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter village';
    }

    return null;
  }

  String? _validateAddress(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter address';
    }

    return null;
  }

  String? _validateMessage(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your enquiry';
    }

    return null;
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showSuccessDialog(
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(
            24,
            26,
            24,
            20,
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      Color(0xFFE2F5E8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color:
                      AppColors.accentGreen,
                  size: 38,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Enquiry Submitted',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF202A24),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width:
                    double.infinity,
                height: 46,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();

                    Navigator.of(
                      context,
                    ).pop();
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors
                            .accentGreen,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Done',
                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showErrorSnackBar(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          margin:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          backgroundColor:
              const Color(0xFFB3261E),
          elevation: 4,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.red
            : const Color(0xff0F8A4B),
        content:
            Text(message),
      ),
    );
  }
}