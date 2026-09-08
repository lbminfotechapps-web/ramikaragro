import 'dart:io';

import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/farmer/famerfollowup/data/model/followuplist_model.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_bloc.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_event.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/bloc/famerfollowup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class FamerFollowupPage extends StatefulWidget {
  final String farmerId;

  const FamerFollowupPage({super.key, required this.farmerId});

  @override
  State<FamerFollowupPage> createState() => _FamerFollowupPageState();
}

class _FamerFollowupPageState extends State<FamerFollowupPage> {
  final _formKey = GlobalKey<FormState>();
  final Geocoding _geocoding = Geocoding();
  final TextEditingController followUpDateController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? selectedFollowUpType;
  String? imagePath;
  String? userId;

  double? latitude;
  double? longitude;

  String geoAddress = '';

  bool isLocationLoading = false;

  final List<String> followUpTypes = [
    'Call',
    'Visit',
    'Meeting',
    'Demo',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    debugPrint('FARMER ID: ${widget.farmerId}');

    _loadUserData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    followUpDateController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  // ==========================================================
  // GET USER DATA
  // ==========================================================

  Future<void> _loadUserData() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      debugPrint('USER DATA: $userData');

      if (!mounted) return;

      setState(() {
        userId = userData?['user_id']?.toString();
      });

      debugPrint('LOGGED IN USER ID: $userId');
    } catch (e) {
      debugPrint('GET USER DATA ERROR: $e');

      if (!mounted) return;

      setState(() {
        userId = null;
      });
    }
  }

  // ==========================================================
  // CURRENT LOCATION
  // ==========================================================

  Future<void> _getCurrentLocation() async {
    try {
      if (!mounted) return;

      setState(() {
        isLocationLoading = true;
      });

      // ------------------------------------------------------
      // Check GPS / Location Service
      // ------------------------------------------------------

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            isLocationLoading = false;
          });

          _showMessage('Please enable location/GPS');
        }

        await Geolocator.openLocationSettings();
        return;
      }

      // ------------------------------------------------------
      // Check Permission
      // ------------------------------------------------------

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              isLocationLoading = false;
            });

            _showMessage('Location permission denied');
          }

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            isLocationLoading = false;
          });

          _showMessage(
            'Location permission permanently denied. '
            'Please enable it from Settings.',
          );
        }

        await Geolocator.openAppSettings();
        return;
      }

      // ------------------------------------------------------
      // Get Current GPS Location
      // ------------------------------------------------------

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      debugPrint('CURRENT LATITUDE: $latitude');
      debugPrint('CURRENT LONGITUDE: $longitude');

      // ------------------------------------------------------
      // Convert Lat/Long to Address
      // ------------------------------------------------------

      try {
        final List<Placemark> placemarks = await _geocoding
            .placemarkFromCoordinates(latitude!, longitude!);

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;

          final List<String?> addressParts = [
            place.name,
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ];

          geoAddress = addressParts
              .where((element) => element != null && element.trim().isNotEmpty)
              .map((element) => element!.trim())
              .join(', ');

          debugPrint('CURRENT ADDRESS: $geoAddress');
        }
      } catch (e) {
        debugPrint('ADDRESS ERROR: $e');

        geoAddress = 'Lat: $latitude, Long: $longitude';
      }

      if (!mounted) return;

      setState(() {
        isLocationLoading = false;
      });
    } catch (e) {
      debugPrint('LOCATION ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLocationLoading = false;
      });

      _showMessage('Unable to get current location');
    }
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

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

  // ==========================================================
  // IMAGE PICKER - CAMERA
  // ==========================================================

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');

      if (mounted) {
        _showMessage('Unable to capture image');
      }
    }
  }

  // ==========================================================
  // IMAGE PICKER - GALLERY
  // ==========================================================

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('GALLERY ERROR: $e');

      if (mounted) {
        _showMessage('Unable to select image');
      }
    }
  }

  // ==========================================================
  // IMAGE OPTIONS
  // ==========================================================

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

  // ==========================================================
  // SUBMIT
  // ==========================================================

  void _submitFollowup() {
    // --------------------------------------------------------
    // Validate Form
    // --------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // --------------------------------------------------------
    // Follow-up Type
    // --------------------------------------------------------

    if (selectedFollowUpType == null || selectedFollowUpType!.isEmpty) {
      _showMessage('Please select follow-up type');
      return;
    }

    // --------------------------------------------------------
    // Date
    // --------------------------------------------------------

    if (followUpDateController.text.trim().isEmpty) {
      _showMessage('Please select next follow-up date');
      return;
    }

    // --------------------------------------------------------
    // User ID
    // --------------------------------------------------------

    if (userId == null || userId!.trim().isEmpty) {
      _showMessage('User information not available');
      return;
    }

    // --------------------------------------------------------
    // Farmer ID
    // --------------------------------------------------------

    if (widget.farmerId.trim().isEmpty) {
      _showMessage('Farmer ID not available');
      return;
    }

    // --------------------------------------------------------
    // Location
    // --------------------------------------------------------

    if (latitude == null || longitude == null) {
      _showMessage('Getting current location. Please try again.');

      _getCurrentLocation();
      return;
    }

    debugPrint('================ FOLLOW-UP SUBMIT ================');

    debugPrint('FARMER ID: ${widget.farmerId}');

    debugPrint('USER ID: $userId');

    debugPrint(
      'FOLLOW-UP DATE: '
      '${followUpDateController.text.trim()}',
    );

    debugPrint('FOLLOW-UP TYPE: $selectedFollowUpType');

    debugPrint('REMARK: ${remarkController.text.trim()}');

    debugPrint('LATITUDE: $latitude');

    debugPrint('LONGITUDE: $longitude');

    debugPrint('ADDRESS: $geoAddress');

    debugPrint('IMAGE: $imagePath');

    debugPrint('===================================================');

    // --------------------------------------------------------
    // Dispatch Event
    // --------------------------------------------------------

    context.read<FamerfollowupBloc>().add(
      SubmitFollowupEvent(
        farmerId: widget.farmerId,
        userId: userId!,

        followUpDate: followUpDateController.text.trim(),

        followUpType: selectedFollowUpType!,

        remark: remarkController.text.trim(),

        latitude: latitude!,

        longitude: longitude!,

        networkLatitude: latitude!,

        networkLongitude: longitude!,

        gpsLatitude: latitude!,

        gpsLongitude: longitude!,

        geoAddress: geoAddress,

        networkInfo: '',

        batteryInfo: '',

        differenceByAndroid: '0',

        statusOfFarmer: '',

        activityId: '6',

        imagePath: imagePath,
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamerfollowupBloc, FamerfollowupState>(
      listener: (context, state) {
        // ----------------------------------------------------
        // SUCCESS
        // ----------------------------------------------------

        if (state.status == FamerfollowupStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Record Submitted Successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF087F5B),
                margin: EdgeInsets.all(16),
              ),
            );

          context.go(AppRouter.home);
        }

        // ----------------------------------------------------
        // FAILURE
        // ----------------------------------------------------

        if (state.status == FamerfollowupStatus.failure) {
          _showMessage(state.errorMessage ?? 'Failed to submit record');
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),

        // ====================================================
        // APP BAR
        // ====================================================
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

        // ====================================================
        // BODY
        // ====================================================
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistoryStrip(),
                  const SizedBox(height: 18),

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

                  _sectionTitle(
                    icon: Icons.photo_camera_back_rounded,
                    title: 'Follow-up Image',
                  ),

                  const SizedBox(height: 12),

                  _buildImagePicker(),

                  const SizedBox(height: 24),

                  _buildLocationCard(),

                  const SizedBox(height: 16),

                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ),

        // ====================================================
        // BOTTOM SUBMIT BUTTON
        // ====================================================
        bottomSheet: BlocBuilder<FamerfollowupBloc, FamerfollowupState>(
          builder: (context, state) {
            final bool loading = state.status == FamerfollowupStatus.loading;

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
                      disabledBackgroundColor: const Color(0xFF9DBDB1),
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

  Widget _buildHistoryStrip() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _showFollowupHistory,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE5E1)),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF087F5B),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-up History',
                      style: TextStyle(
                        color: Color(0xFF172B24),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'View previous farmer follow-ups',
                      style: TextStyle(
                        color: Color(0xFF7A8983),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF087F5B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFollowupHistory() {
    context.read<FamerfollowupBloc>().add(
      GetRemarkHistoryEvent(farmerId: widget.farmerId),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<FamerfollowupBloc>(),
          child: _FollowupHistoryDialog(farmerId: widget.farmerId),
        );
      },
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
  // LOCATION CARD
  // ==========================================================

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF087F5B),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    color: Color(0xFF172B24),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                if (isLocationLoading)
                  const Row(
                    children: [
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF087F5B),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Getting location...',
                        style: TextStyle(
                          color: Color(0xFF7A8983),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else if (latitude != null && longitude != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${latitude!.toStringAsFixed(6)}, '
                        '${longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(
                          color: Color(0xFF087F5B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (geoAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          geoAddress,
                          style: const TextStyle(
                            color: Color(0xFF7A8983),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  const Text(
                    'Location not available',
                    style: TextStyle(color: Color(0xFF9AA6A1), fontSize: 12),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: isLocationLoading ? null : _getCurrentLocation,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF087F5B),
              size: 20,
            ),
          ),
        ],
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

class _FollowupHistoryDialog extends StatelessWidget {
  final String farmerId;

  const _FollowupHistoryDialog({required this.farmerId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),

            Expanded(
              child: BlocBuilder<FamerfollowupBloc, FamerfollowupState>(
                builder: (context, state) {
                  if (state.historyStatus == FollowupHistoryStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF087F5B),
                      ),
                    );
                  }

                  if (state.historyStatus == FollowupHistoryStatus.failure) {
                    return _buildError(context, state.historyError);
                  }

                  if (state.historyList.isEmpty) {
                    return _buildEmpty();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.historyList[index];

                      return _buildHistoryItem(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 10, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF087F5B), Color(0xFF0B9A70)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow-up History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Farmer ID: $farmerId',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(RemarkListModel item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DATE + TIME
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F0),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF087F5B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.fldDate,
                      style: const TextStyle(
                        color: Color(0xFF087F5B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Color(0xFF8A9792),
              ),

              const SizedBox(width: 4),

              Text(
                item.fldTime,
                style: const TextStyle(
                  color: Color(0xFF7A8983),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ADMIN
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Color(0xFF087F5B),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  item.fldAdmName.isEmpty ? '-' : item.fldAdmName,
                  style: const TextStyle(
                    color: Color(0xFF172B24),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // OUTLET
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 18,
                color: Color(0xFF087F5B),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  item.fldFarmerName.isEmpty ? '-' : item.fldFarmerName,
                  style: const TextStyle(
                    color: Color(0xFF53645D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // REMARK
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 17,
                  color: Color(0xFF087F5B),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    item.fldRemark.isEmpty ? 'No remark' : item.fldRemark,
                    style: const TextStyle(
                      color: Color(0xFF40534B),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 55,
              color: Color(0xFFB4C3BD),
            ),

            SizedBox(height: 14),

            Text(
              'No Follow-up History',
              style: TextStyle(
                color: Color(0xFF172B24),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'No previous follow-ups found for this farmer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8983), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load history',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 5),

            Text(
              error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A8983), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
