import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/core/location_tracking/app_database.dart';
import 'package:solufine/core/location_tracking/location_repository.dart';
import 'package:solufine/core/utility/appdialog.dart';
import 'package:solufine/core/utility/device_info_util.dart';
import 'package:solufine/core/utility/location_util.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/utility/cameracapturepage.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/di/leave_list_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';

import '../bloc/add_dealer_visit_bloc.dart';
import '../bloc/add_dealer_visit_event.dart';
import '../bloc/add_dealer_visit_state.dart';

class AddDealerVisitPage extends StatefulWidget {
  final String dealerId;
  final String dealerName;

  const AddDealerVisitPage({
    super.key,
    required this.dealerId,
    this.dealerName = '',
  });

  @override
  State<AddDealerVisitPage> createState() => _AddDealerVisitPageState();
}

class _AddDealerVisitPageState extends State<AddDealerVisitPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF0A9F4D);

  static const Color darkGreen = Color(0xFF087A3A);

  static const Color lightGreen = Color(0xFFEAF8F0);

  static const Color backgroundColor = Color(0xFFF6F8F7);

  static const Color textColor = Color(0xFF202522);

  // ============================================================
  // CONTROLLERS
  // ============================================================
  final TextEditingController remarkController = TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool _isSubmitting = false;
  bool _submissionSent = false;
  bool _submissionCompleted = false;

  DateTime? nextFollowUpDate;
  String? imagePath;
  String selectedFollowUpType = 'Select Follow Up Type';

  String? selectedPurposeId;

  late AddDealerVisitBlock dealerVisitBloc;

  // ============================================================
  // API PARAMETERS
  // ============================================================

  String userId = '';
  String amount = '';

  String latitude = '';

  String longitude = '';

  String networkLatitude = '';

  String networkLongitude = '';

  String gpsLatitude = '';

  String gpsLongitude = '';

  String geoAddress = '';

  String strNetworkInfo = '';

  String strBatteryInfo = '';

  String activityId = '';

  // ============================================================
  // STATIC DATA
  // ============================================================
  final List<String> followUpTypes = [
    'Select Follow Up Type',
    'Phone',
    'Visit',
  ];

  final List<String> purposeTypes = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];

  final List<String> lastRemarks = [
    'Item 0',
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
    'Item 7',
    'Item 8',
    'Item 9',
    'Item 10',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    dealerVisitBloc = sl<AddDealerVisitBlock>();

    _loadUserId();
    _loadDeviceData();
    _getPurposeData();
  }

  Future<void> _loadUserId() async {
    final userData = await SecureStorage.instance.getUserData();

    userId = (userData?['user_id']?.toString() ?? '');
    print('User99: $userId');

    // punchVehicleId = userData?['vehicle_type_id']?.toString();

    if (!mounted || userId == null) return;
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================
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

  Future<void> _loadDeviceData() async {
    try {
      debugPrint('==========================================');
      debugPrint('        LOADING DEVICE DATA');
      debugPrint('==========================================');

      // ==========================================================
      // 1. BATTERY INFO
      // ==========================================================

      final String batteryInfo = await DeviceInfoUtil.instance.getBatteryInfo();

      strBatteryInfo = batteryInfo;

      // ==========================================================
      // 2. NETWORK INFO
      // ==========================================================

      final String networkInfo = await DeviceInfoUtil.instance.getNetworkInfo();

      strNetworkInfo = networkInfo;

      // ==========================================================
      // 3. LOCATION
      // ==========================================================

      final position = await LocationUtil.instance.getCurrentLocation();

      if (position == null) {
        debugPrint('Location not available');

        latitude = '';
        longitude = '';
        gpsLatitude = '';
        gpsLongitude = '';
        networkLatitude = '';
        networkLongitude = '';
        geoAddress = '';

        if (mounted) {
          setState(() {});
        }

        return;
      }

      // ==========================================================
      // 4. LATITUDE / LONGITUDE
      // ==========================================================

      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      // ==========================================================
      // 5. GPS LOCATION
      // ==========================================================

      gpsLatitude = latitude;
      gpsLongitude = longitude;

      // ==========================================================
      // 6. NETWORK LOCATION
      // ==========================================================
      //
      // Same behavior as your existing working code.
      //

      networkLatitude = latitude;
      networkLongitude = longitude;

      // ==========================================================
      // 7. GEO ADDRESS
      // ==========================================================

      geoAddress = await LocationUtil.instance.getAddress(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
    }
  }

  void _getPurposeData() {
    dealerVisitBloc.add(GetPurposeEvent(""));
  }

  void _getFollowupData() {
    dealerVisitBloc.add(GetFollowupEvent(""));
  }
  // ============================================================
  // DISPOSE
  // ============================================================

  Future<String> _getStoredLocations() async {
    try {
      final int? parsedUserId = int.tryParse(userId);

      if (parsedUserId == null) {
        debugPrint('LOCATION: Invalid userId = $userId');
        return '[]';
      }

      final LocationRepository repository = sl<LocationRepository>();

      final List<LocationHistoryData> locations = await repository
          .getAllLocations(parsedUserId);

      debugPrint('========================================');
      debugPrint('DEALER VISIT - STORED LOCATIONS');
      debugPrint('TOTAL LOCATIONS: ${locations.length}');
      debugPrint('========================================');

      for (final location in locations) {
        debugPrint(
          'ID: ${location.id} | '
          'Lat: ${location.latitude} | '
          'Lng: ${location.longitude} | '
          'Time: ${location.capturedAt} | '
          'Accuracy: ${location.accuracy} | '
          'Provider: ${location.provider} | '
          'Address: ${location.geoAddress} | '
          'Distance: ${location.distance}',
        );
      }

      // ============================================================
      // CREATE DATA FOR STORE LOCATION API
      // ============================================================

      final List<Map<String, dynamic>> locationList = locations.map((location) {
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'time': location.capturedAt,
          'accuracy': location.accuracy,
          'provider': location.provider,
          'address': location.geoAddress,
          'distance': location.distance,
        };
      }).toList();

      // ============================================================
      // JSON ARRAY -> STRING
      // ============================================================

      final String strAllLocations = jsonEncode(locationList);

      debugPrint('========================================');
      debugPrint('STR ALL LOCATIONS');
      debugPrint('TOTAL: ${locations.length}');
      debugPrint(strAllLocations);
      debugPrint('========================================');

      return strAllLocations;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GET STORED LOCATIONS ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('========================================');

      return '[]';
    }
  }

  @override
  void dispose() {
    remarkController.dispose();

    dealerVisitBloc.close();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectNextFollowUpDate() async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: nextFollowUpDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      nextFollowUpDate = selected;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting ||
        _submissionCompleted ||
        dealerVisitBloc.state.addLeaveStatus == AddDealerVisitStatus.loading) {
      return;
    }
    if (widget.dealerId.trim().isEmpty) {
      _showError('Dealer ID is empty');
      return;
    }
    if (nextFollowUpDate == null) {
      _showError('Please select next follow-up date');
      return;
    }

    // ==========================================================
    // 2. FOLLOW UP TYPE VALIDATION
    // ==========================================================
    if (selectedFollowUpType.trim().isEmpty ||
        selectedFollowUpType == 'Select Follow Up Type') {
      _showError('Please select follow up type');
      return;
    }

    // ==========================================================
    // 3. PURPOSE VALIDATION
    // ==========================================================
    if (selectedPurposeId == null ||
        selectedPurposeId!.trim().isEmpty ||
        selectedPurposeId == '0') {
      _showError('Please select purpose type');
      return;
    }

    // ==========================================================
    // 4. REMARK VALIDATION
    // ==========================================================
    final String remark = remarkController.text.trim();

    if (remark.isEmpty) {
      _showError('Please enter remark');
      return;
    }

    // ==========================================================
    // 5. IMAGE VALIDATION
    // ==========================================================
    if (imagePath == null) {
      _showError('Please upload image');
      return;
    }

    // Lock synchronously before collecting device data.
    setState(() => _isSubmitting = true);
    try {
      await _loadDeviceData();
      if (!mounted) return;

      // ==========================================================
      // 7. FORMAT DATE
      // ==========================================================
      final String formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(nextFollowUpDate!);

      // ==========================================================
      // 8. DEBUG LOG
      // ==========================================================
      debugPrint('==========================================');
      debugPrint('          ADD DEALER VISIT');
      debugPrint('==========================================');

      debugPrint('user_id          : $userId');
      debugPrint('outlet_id        : ${widget.dealerId}');
      debugPrint('purposeId        : $selectedPurposeId');
      debugPrint('amount           : $amount');
      debugPrint('followUpDate     : $formattedDate');
      debugPrint('followUpType     : $selectedFollowUpType');
      debugPrint('remark           : $remark');

      debugPrint('------------------------------------------');
      debugPrint('LOCATION DATA');
      debugPrint('------------------------------------------');

      debugPrint('latitude         : $latitude');
      debugPrint('longitude        : $longitude');

      debugPrint('networkLatitude  : $networkLatitude');
      debugPrint('networkLongitude : $networkLongitude');

      debugPrint('gpsLatitude      : $gpsLatitude');
      debugPrint('gpsLongitude     : $gpsLongitude');

      debugPrint('geoAddress       : $geoAddress');

      debugPrint('------------------------------------------');
      debugPrint('DEVICE DATA');
      debugPrint('------------------------------------------');

      debugPrint('networkInfo      : $strNetworkInfo');
      debugPrint('batteryInfo      : $strBatteryInfo');

      debugPrint('------------------------------------------');
      debugPrint('OTHER DATA');
      debugPrint('------------------------------------------');

      debugPrint('activityId       : $activityId');
      debugPrint('dealerImage      : ${imagePath}');

      debugPrint('==========================================');

      // ==========================================================
      // 9. SEND BLOC EVENT
      // ==========================================================
      _submissionSent = true;
      dealerVisitBloc.add(
        AddDealerRemarkSubmitEvent(
          userId: userId,
          outletId: widget.dealerId,
          purposeId: selectedPurposeId!,
          amount: amount,
          followUpDate: formattedDate,
          followUpType: selectedFollowUpType,
          remark: remark,

          // Location
          latitude: latitude,
          longitude: longitude,

          // Network location
          networkLatitude: networkLatitude,
          networkLongitude: networkLongitude,

          // GPS location
          gpsLatitude: gpsLatitude,
          gpsLongitude: gpsLongitude,

          // Address
          geoAddress: geoAddress,

          // Device information
          strNetworkInfo: strNetworkInfo,
          strBatteryInfo: strBatteryInfo,

          // Activity
          activityId: activityId,

          // IMPORTANT:
          // If your event has dealerImage, pass it here:
          //
          imagePath: imagePath,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submissionSent = false;
      });
      _showError('Unable to submit dealer visit. Please try again.');
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        backgroundColor: Colors.red.shade600,

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(12),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: dealerVisitBloc,

      child: BlocConsumer<AddDealerVisitBlock, AddDealerVisitState>(
        listener: (context, state) async {
          if (!_isSubmitting || !_submissionSent) return;
          // ======================================================
          // SUCCESS
          // ======================================================

          if (state.addLeaveStatus == AddDealerVisitStatus.dealerAddedSuccess) {
            setState(() {
              _submissionCompleted = true;
              _isSubmitting = false;
              _submissionSent = false;
            });
            debugPrint('DAILY TRAN ID FROM STATE: ${state.dailyTranId}');

            final String strAllLocations = await _getStoredLocations();
            if (!mounted || !context.mounted) return;
            debugPrint('========================================');
            debugPrint('CALLING STORE TRACK LOCATION API');
            debugPrint('USER ID: $userId');
            debugPrint('DAILY TRAN ID: ${state.dailyTranId}');
            debugPrint('STR ALL LOCATIONS: $strAllLocations');
            debugPrint('========================================');

            context.read<QuickAcessBloc>().add(
              StoreTrackLocation(userId, state.dailyTranId!, strAllLocations),
            );

            AppDialog.show(
              context: context,
              type: DialogType.success,
              title: 'Successful',
              message: 'Dealer Visit Successfully.',
              buttonText: 'OK',
              onButtonPressed: () {
                context.go('/visits');
              },
            );
          }

          // ======================================================
          // FAILURE
          // ======================================================

          if (state.addLeaveStatus == AddDealerVisitStatus.failure) {
            setState(() {
              _isSubmitting = false;
              _submissionSent = false;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'Unable to add dealer visit',
                      ),
                    ),
                  ],
                ),

                backgroundColor: Colors.red.shade600,

                behavior: SnackBarBehavior.floating,

                margin: const EdgeInsets.all(12),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          debugPrint('PURPOSE LENGTH = ${state.purpose.length}');

          debugPrint('PURPOSE DATA = ${state.purpose}');

          final bool isLoading =
              _isSubmitting ||
              state.addLeaveStatus == AddDealerVisitStatus.loading;

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: CustomAppBar(
              title: 'Dealer Follow-up',
              // subtitle: 'Add farmer follow-up',
              showBackButton: true,
              onBackTap: () => Navigator.pop(context),
            ),

            /*
            appBar: AppBar(
              elevation: 0,

              backgroundColor: primaryGreen,

              foregroundColor: Colors.white,

              centerTitle: false,

              titleSpacing: 0,

              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: Colors.white,
                ),

                onPressed: () {
                  context.go(AppRouter.home);
                },
              ),

              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dealer Visit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),

                  Text(
                    'Add follow-up details',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(.75),
                    ),
                  ),
                ],
              ),
            ),
            */

            // ====================================================
            // BODY
            // ====================================================
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.only(left: 16, right: 16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          SizedBox(height: 14.h),
                          _buildHistoryStrip(),
                          const SizedBox(height: 18),

                          // ======================================
                          // FOLLOW-UP DETAILS
                          // ======================================
                          _sectionTitle(
                            Icons.event_note_rounded,
                            'Follow-up Details',
                          ),

                          const SizedBox(height: 7),

                          _buildDateField(),

                          const SizedBox(height: 9),

                          _buildDropdown(
                            label: 'FOLLOW UP TYPE *',

                            value: selectedFollowUpType,

                            items: followUpTypes,

                            icon: Icons.sync_rounded,

                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                selectedFollowUpType = value;
                              });
                            },
                          ),

                          const SizedBox(height: 9),

                          _buildPurposeDropdown(state),
                          const SizedBox(height: 14),

                          // ======================================
                          // REMARK
                          // ======================================
                          _sectionTitle(
                            Icons.edit_note_rounded,
                            'Visit Remark',
                          ),

                          const SizedBox(height: 7),

                          _buildRemarkField(),

                          const SizedBox(height: 14),

                          // ======================================
                          // LAST REMARKS
                          // ======================================
                          // _sectionTitle(Icons.history_rounded, 'Last Remarks'),

                          //  const SizedBox(height: 6),

                          //  _buildLastRemarks(),

                          // const SizedBox(height: 14),

                          // ======================================
                          // DEALER IMAGE
                          // ======================================t
                          _buildImagePicker(),

                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // BOTTOM BUTTON
                  // =================================================
                  _buildSubmitButton(isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFollowupHistory() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _FollowupHistoryDialog(
          dealerId: widget.dealerId,
          dealerName: widget.dealerName,
        );
      },
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
                      'View previous dealer follow-ups',
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

  // ============================================================
  // DEALER HEADER
  // ============================================================

  Widget _buildDealerHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade200),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),

            blurRadius: 8,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius: BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.storefront_rounded,

              color: primaryGreen,

              size: 23,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'DEALER',

                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.dealerName.isEmpty ? 'Dealer' : widget.dealerName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius: BorderRadius.circular(20),
            ),

            child: const Text(
              'VISIT',

              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: primaryGreen,
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

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 17, color: primaryGreen),

        const SizedBox(width: 6),

        Text(
          title,

          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    final bool selected = nextFollowUpDate != null;

    return InkWell(
      onTap: _selectNextFollowUpDate,

      borderRadius: BorderRadius.circular(11),

      child: Container(
        height: 58,

        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(11),

          border: Border.all(
            color: selected
                ? primaryGreen.withOpacity(.35)
                : Colors.grey.shade200,
          ),
        ),

        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,

              decoration: BoxDecoration(
                color: selected ? lightGreen : Colors.grey.shade100,

                borderRadius: BorderRadius.circular(8),
              ),

              child: Icon(
                Icons.calendar_today_rounded,

                size: 17,

                color: selected ? primaryGreen : Colors.grey.shade500,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'NEXT FOLLOW-UP DATE *',

                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    selected
                        ? DateFormat('dd MMM yyyy').format(nextFollowUpDate!)
                        : 'Select follow-up date',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,

                      color: selected ? textColor : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.calendar_month_rounded,

              size: 19,

              color: primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeDropdown(AddDealerVisitState state) {
    final purposes = state.purpose;

    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(11, 5, 7, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 17,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PURPOSE TYPE *',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                    color: Colors.black45,
                  ),
                ),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPurposeId,

                      isExpanded: true,

                      isDense: true,

                      hint: Text(
                        'Select Purpose',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),

                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: primaryGreen,
                      ),

                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),

                      onChanged: purposes.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                selectedPurposeId = value;
                              });
                            },

                      items: purposes.map((purpose) {
                        return DropdownMenuItem<String>(
                          value: purpose.purposeId,
                          child: Text(
                            purpose.purpose,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 58,

      padding: const EdgeInsets.fromLTRB(11, 5, 7, 2),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius: BorderRadius.circular(8),
            ),

            child: Icon(icon, size: 17, color: primaryGreen),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                    color: Colors.black45,
                  ),
                ),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,

                      isExpanded: true,

                      isDense: true,

                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: primaryGreen,
                      ),

                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),

                      onChanged: onChanged,

                      items: items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,

                          child: Text(item),
                        );
                      }).toList(),
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

  // ============================================================
  // REMARK
  // ============================================================

  Widget _buildRemarkField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: TextField(
        controller: remarkController,

        maxLines: 3,

        textCapitalization: TextCapitalization.sentences,

        style: const TextStyle(fontSize: 13, color: textColor),

        decoration: InputDecoration(
          hintText: 'Enter visit remark...',

          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),

          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 11, right: 3, top: 9),

            child: Icon(Icons.edit_note_rounded, color: primaryGreen, size: 21),
          ),

          prefixIconConstraints: const BoxConstraints(minWidth: 40),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.fromLTRB(4, 10, 10, 10),
        ),
      ),
    );
  }

  // ============================================================
  // LAST REMARKS
  // ============================================================

  Widget _buildLastRemarks() {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(maxHeight: 150),

      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: ListView.separated(
        shrinkWrap: true,

        physics: const BouncingScrollPhysics(),

        itemCount: lastRemarks.length,

        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),

        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  height: 6,
                  width: 6,

                  margin: const EdgeInsets.only(top: 5, right: 8),

                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),

                Expanded(
                  child: Text(
                    lastRemarks[index],

                    style: const TextStyle(fontSize: 11, color: textColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // IMAGE SECTION
  // ============================================================
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
                  onTap: _captureImage,
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
      onTap: _captureImage,
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
              'Tap to take a photo',
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

  Future<void> _captureImage() async {
    FocusScope.of(context).unfocus();
    try {
      final capturedPath = await Navigator.of(context, rootNavigator: true)
          .push<String>(
            MaterialPageRoute(builder: (_) => const CameraCapturePage()),
          );

      if (capturedPath == null || !mounted) return;

      setState(() {
        imagePath = capturedPath;
      });
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');
      if (mounted) {
        _showMessage('Unable to capture image');
      }
    }
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 9),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),

            blurRadius: 10,

            offset: const Offset(0, -3),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 44,
          width: double.infinity,

          child: ElevatedButton(
            onPressed: isLoading || _submissionCompleted ? null : _submit,

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,

              disabledBackgroundColor: Colors.grey.shade400,

              foregroundColor: Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: isLoading
                ? const SizedBox(
                    height: 19,
                    width: 19,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18),

                      SizedBox(width: 7),

                      Text(
                        'SUBMIT VISIT',

                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _FollowupHistoryDialog extends StatefulWidget {
  final String dealerId;
  final String dealerName;

  const _FollowupHistoryDialog({
    required this.dealerId,
    required this.dealerName,
  });

  @override
  State<_FollowupHistoryDialog> createState() => _FollowupHistoryDialogState();
}

class _FollowupHistoryDialogState extends State<_FollowupHistoryDialog> {
  late AddDealerVisitBlock dealerVisitBloc;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // CREATE DEALER FOLLOW-UP BLOC
    // ============================================================

    dealerVisitBloc = sl<AddDealerVisitBlock>();

    debugPrint('HISTORY DEALER ID => ${widget.dealerId}');

    // ============================================================
    // LOAD DEALER FOLLOW-UP HISTORY
    // ============================================================

    dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));
  }

  @override
  void dispose() {
    dealerVisitBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: dealerVisitBloc,
      child: Dialog(
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
              // ====================================================
              // HEADER
              // ====================================================
              _buildHeader(context),

              // ====================================================
              // HISTORY LIST
              // ====================================================
              Expanded(
                child: BlocBuilder<AddDealerVisitBlock, AddDealerVisitState>(
                  builder: (context, state) {
                    // ==============================================
                    // LOADING
                    // ==============================================

                    if (state.addLeaveStatus == AddDealerVisitStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF087F5B),
                        ),
                      );
                    }

                    final followups = state.followupList;

                    debugPrint(
                      'Dealer Followup History Count: '
                      '${followups.length}',
                    );

                    // ==============================================
                    // EMPTY
                    // ==============================================

                    if (followups.isEmpty) {
                      return _buildEmpty();
                    }

                    // ==============================================
                    // LIST
                    // ==============================================

                    return RefreshIndicator(
                      color: const Color(0xFF087F5B),
                      onRefresh: () async {
                        dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));

                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: followups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = followups[index];

                          return _buildHistoryItem(item, index + 1);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  'Dealer Follow-up History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                // if (widget.dealerName.isNotEmpty)
                //   Text(
                //     widget.dealerName,
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(.85),
                //       fontSize: 11.5,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   )
                // else
                //   Text(
                //     'Dealer ID: ${widget.dealerId}',
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(.8),
                //       fontSize: 11.5,
                //     ),
                //   ),
              ],
            ),
          ),

          // =======================================================
          // REFRESH
          // =======================================================
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),

          // =======================================================
          // CLOSE
          // =======================================================
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HISTORY ITEM
  // ===============================================================

  Widget _buildHistoryItem(DealerFollowupListEntity item, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDCE5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // DATE + TIME
          // ========================================================
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    // DATE
                    if (item.followupDate.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
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
                              item.followupDate,
                              style: const TextStyle(
                                color: Color(0xFF087F5B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // TIME
                    if (item.followupTime.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6F5),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Color(0xFF7A8983),
                            ),

                            const SizedBox(width: 5),

                            Text(
                              item.followupTime,
                              style: const TextStyle(
                                color: Color(0xFF7A8983),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 28,
                width: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF087F5B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ========================================================
          // EMPLOYEE
          // ========================================================
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            title: 'Employee',
            value: item.admName.isEmpty ? '-' : item.admName,
          ),

          const SizedBox(height: 11),

          // ========================================================
          // DEALER
          // ========================================================
          _buildInfoRow(
            icon: Icons.storefront_outlined,
            title: 'Dealer',
            value: item.outletName.isEmpty ? '-' : item.outletName,
          ),

          const SizedBox(height: 13),

          // ========================================================
          // REMARK
          // ========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17,
                      color: Color(0xFF087F5B),
                    ),

                    SizedBox(width: 7),

                    Text(
                      'Remark',
                      style: TextStyle(
                        color: Color(0xFF087F5B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  item.followupRemark.isEmpty
                      ? 'No remark'
                      : item.followupRemark,
                  style: const TextStyle(
                    color: Color(0xFF40534B),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // INFO ROW
  // ===============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF087C3A)),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // EMPTY
  // ===============================================================

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
              'No previous follow-ups found for this dealer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8983), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
