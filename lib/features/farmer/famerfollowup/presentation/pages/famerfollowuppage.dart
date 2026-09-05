import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/famerfollowup_bloc.dart';
import '../bloc/famerfollowup_event.dart';
import '../bloc/famerfollowup_state.dart';

class FamerFollowupPage extends StatefulWidget {
  final int farmerId = 12;
  final String userId = "4";

  const FamerFollowupPage({super.key});

  @override
  State<FamerFollowupPage> createState() => _FamerFollowupPageState();
}

class _FamerFollowupPageState extends State<FamerFollowupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController followUpDateController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? selectedFollowUpType;
  String? imagePath;

  final List<String> followUpTypes = [
    'Call',
    'Visit',
    'Meeting',
    'Demo',
    'Other',
  ];

  @override
  void dispose() {
    followUpDateController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // DATE PICKER
  // ----------------------------------------------------------

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF087F5B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF172B24),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        followUpDateController.text =
            '${selectedDate.day.toString().padLeft(2, '0')}-'
            '${selectedDate.month.toString().padLeft(2, '0')}-'
            '${selectedDate.year}';
      });
    }
  }

  // ----------------------------------------------------------
  // IMAGE PICKER
  // ----------------------------------------------------------

  Future<void> _captureImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  // ----------------------------------------------------------
  // IMAGE OPTIONS
  // ----------------------------------------------------------

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Follow-up Image',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _imageOption(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _captureImage();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _imageOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromGallery();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCEBE5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF087F5B)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SUBMIT
  // ----------------------------------------------------------

  void _submitFollowup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedFollowUpType == null) {
      _showMessage('Please select follow-up type');
      return;
    }

    if (followUpDateController.text.trim().isEmpty) {
      _showMessage('Please select next follow-up date');
      return;
    }

    context.read<FamerfollowupBloc>().add(
      SubmitFollowupEvent(
        farmerId: widget.farmerId,
        userId: widget.userId,

        followUpDate: followUpDateController.text.trim(),
        followUpType: selectedFollowUpType!,
        remark: remarkController.text.trim(),

        // Replace these with your actual location values.
        latitude: 0.0,
        longitude: 0.0,

        networkLatitude: 0.0,
        networkLongitude: 0.0,

        gpsLatitude: 0.0,
        gpsLongitude: 0.0,

        geoAddress: '',
        networkInfo: '',
        batteryInfo: '',
        differenceByAndroid: '0',

        statusOfFarmer: '',
        activityId: '6',

        imagePath: imagePath,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamerfollowupBloc, FamerfollowupState>(
      listener: (context, state) {
        if (state is FamerfollowupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF087F5B),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pop(context);
        }

        if (state is FamerfollowupFailure) {
          _showMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),

        // ----------------------------------------------------
        // APP BAR
        // ----------------------------------------------------
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF172B24),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Follow-up',
                style: TextStyle(
                  color: Color(0xFF172B24),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Add farmer follow-up',
                style: TextStyle(
                  color: Color(0xFF7A8983),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------------------------
        // BODY
        // ----------------------------------------------------
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),

                  const SizedBox(height: 18),

                  // Follow-up details
                  _sectionTitle(
                    icon: Icons.event_note_rounded,
                    title: 'Follow-up Details',
                  ),

                  const SizedBox(height: 12),

                  _buildFollowUpType(),

                  const SizedBox(height: 14),

                  _buildDateField(),

                  const SizedBox(height: 14),

                  _buildRemarkField(),

                  const SizedBox(height: 22),

                  // Image
                  _sectionTitle(
                    icon: Icons.photo_camera_back_rounded,
                    title: 'Follow-up Image',
                  ),

                  const SizedBox(height: 12),

                  _buildImagePicker(),

                  const SizedBox(height: 24),

                  // Info
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ),

        // ----------------------------------------------------
        // BOTTOM SUBMIT BUTTON
        // ----------------------------------------------------
        bottomSheet: BlocBuilder<FamerfollowupBloc, FamerfollowupState>(
          builder: (context, state) {
            final bool loading = state is FamerfollowupLoading;

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submitFollowup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087F5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 21,
                              ),
                              SizedBox(width: 9),
                              Text(
                                'Submit Follow-up',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER CARD
  // ==========================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F5B), Color(0xFF0B9A70)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_pin_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Farmer Follow-up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Record your next interaction',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.82),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F3EE),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF087F5B)),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172B24),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FOLLOW-UP TYPE
  // ==========================================================

  Widget _buildFollowUpType() {
    return DropdownButtonFormField<String>(
      value: selectedFollowUpType,

      decoration: _inputDecoration(
        label: 'Follow-up Type',
        icon: Icons.call_merge_rounded,
      ),

      hint: const Text(
        'Select follow-up type',
        style: TextStyle(color: Color(0xFF9AA6A1), fontSize: 14),
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF087F5B),
      ),

      items: followUpTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedFollowUpType = value;
        });
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select follow-up type';
        }
        return null;
      },
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Widget _buildDateField() {
    return TextFormField(
      controller: followUpDateController,
      readOnly: true,
      onTap: _selectDate,

      decoration: _inputDecoration(
        label: 'Next Follow-up Date',
        icon: Icons.calendar_today_rounded,
        suffix: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Color(0xFF8C9994),
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select next follow-up date';
        }
        return null;
      },
    );
  }

  // ==========================================================
  // REMARK
  // ==========================================================

  Widget _buildRemarkField() {
    return TextFormField(
      controller: remarkController,
      maxLines: 5,
      minLines: 4,
      textInputAction: TextInputAction.newline,

      decoration: _inputDecoration(
        label: 'Remark',
        icon: Icons.notes_rounded,
        alignLabelWithHint: true,
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter remark';
        }

        if (value.trim().length < 3) {
          return 'Remark is too short';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // IMAGE PICKER
  // ==========================================================

  Widget _buildImagePicker() {
    if (imagePath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(imagePath!),
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _imageActionButton(
                  icon: Icons.refresh_rounded,
                  onTap: _showImageOptions,
                ),
                const SizedBox(width: 8),
                _imageActionButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () {
                    setState(() {
                      imagePath = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _showImageOptions,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8E5E0), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: Color(0xFF087F5B),
                size: 27,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Add Image',
              style: TextStyle(
                color: Color(0xFF172B24),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Camera or gallery',
              style: TextStyle(color: Color(0xFF8A9792), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(.60),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  // ==========================================================
  // INFO CARD
  // ==========================================================

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCEBE5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF087F5B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add the next follow-up date and a clear remark so the farmer interaction can be tracked properly.',
              style: TextStyle(
                color: Color(0xFF557068),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignLabelWithHint,

      prefixIcon: Icon(icon, color: const Color(0xFF087F5B), size: 20),

      suffixIcon: suffix,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      labelStyle: const TextStyle(color: Color(0xFF75847E), fontSize: 13.5),

      hintStyle: const TextStyle(color: Color(0xFF9AA6A1), fontSize: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE5E1)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE5E1)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF087F5B), width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
