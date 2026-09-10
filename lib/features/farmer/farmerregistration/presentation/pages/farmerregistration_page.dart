import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/state_event.dart';
import 'package:demo/features/farmer/farmerregistration/presentation/bloc/states_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerregistrationPage extends StatefulWidget {
  const FarmerregistrationPage({super.key});

  @override
  State<FarmerregistrationPage> createState() => _FarmerregistrationPageState();
}

class _FarmerregistrationPageState extends State<FarmerregistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController farmerNameController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController alternateMobileController =
      TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController villageController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String? _selectedStateId;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  // ============================================================
  // GET USER ID
  // ============================================================

  Future<void> getUserId() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = userData?['user_id']?.toString();

    if (!mounted || userId == null || userId.isEmpty) {
      return;
    }

    context.read<StateBloc>().add(StateListEvent(userId: userId));
  }

  Future<void> _loadStates() async {
    await getUserId();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStateId == null || _selectedStateId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select state')));
      return;
    }

    print('================================');
    print('FARMER REGISTRATION');
    print('================================');
    print('Farmer Name: ${farmerNameController.text}');
    print('Contact Person: ${contactPersonController.text}');
    print('Address: ${addressController.text}');
    print('Mobile: ${mobileController.text}');
    print('Alternate Mobile: ${alternateMobileController.text}');
    print('Email: ${emailController.text}');
    print('Village: ${villageController.text}');
    print('State ID: $_selectedStateId');
    print('================================');

    // Add your registration Bloc event here.
  }

  // ============================================================
  // DISPOSE
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Farmer Registration',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: BlocBuilder<StateBloc, StatsState>(
        builder: (context, state) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // FARMER NAME
                    // ==================================================
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // CONTACT PERSON
                    // ==================================================
                    CustomTextFormField(
                      controller: contactPersonController,
                      hintText: 'Contact Person Name',
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // ADDRESS
                    // ==================================================
                    CustomTextFormField(
                      controller: addressController,
                      hintText: 'Address',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // MOBILE
                    // ==================================================
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // ALTERNATE MOBILE
                    // ==================================================
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // EMAIL
                    // ==================================================
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // VILLAGE
                    // ==================================================
                    CustomTextFormField(
                      controller: villageController,
                      hintText: 'Village',
                      prefixIcon: Icons.location_city_outlined,
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // STATE LABEL
                    // ==================================================
                    const Text(
                      'State *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // STATE DROPDOWN
                    // ==================================================
                    DropdownMenu<String>(
                      width: double.infinity,
                      hintText: 'Select State',
                      initialSelection: _selectedStateId,

                      leadingIcon: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF087C3A),
                      ),

                      onSelected: (value) {
                        setState(() {
                          _selectedStateId = value;
                        });

                        debugPrint('Selected state ID: $_selectedStateId');
                      },

                      dropdownMenuEntries: state.statentity
                          .map(
                            (item) => DropdownMenuEntry<String>(
                              value: item.stateId,
                              label: item.stateName,
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SUBMIT BUTTON
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF087C3A),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'Register Farmer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
