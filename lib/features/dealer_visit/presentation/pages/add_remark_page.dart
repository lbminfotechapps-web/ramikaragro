import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:demo/core/utility/device_info_util.dart';
import 'package:demo/core/utility/location_util.dart';

import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:demo/core/di/leave_list_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';

import '../bloc/add_dealer_visit_bloc.dart';
import '../bloc/add_dealer_visit_event.dart';
import '../bloc/add_dealer_visit_state.dart';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';


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

  DateTime? nextFollowUpDate;

  String selectedFollowUpType = 'Select Follow Up Type';

  String? selectedPurposeId;
  File? dealerImage;

  late AddDealerVisitBlock dealerVisitBloc;

  final ImagePicker _imagePicker = ImagePicker();

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
final List<String> followUpTypes = ['Select Follow Up Type','Phone','Visit',
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

    // punchVehicleId = userData?['vehicle_type_id']?.toString();

    if (!mounted || userId == null) return;
  }
  // ============================================================
  // INITIAL DATA
  // ============================================================

Future<void> _loadDeviceData() async {
  try {
    debugPrint('==========================================');
    debugPrint('        LOADING DEVICE DATA');
    debugPrint('==========================================');

    // ==========================================================
    // 1. BATTERY INFO
    // ==========================================================

    final String batteryInfo =
        await DeviceInfoUtil.instance.getBatteryInfo();

    strBatteryInfo = batteryInfo;

    // ==========================================================
    // 2. NETWORK INFO
    // ==========================================================

    final String networkInfo =
        await DeviceInfoUtil.instance.getNetworkInfo();

    strNetworkInfo = networkInfo;

    // ==========================================================
    // 3. LOCATION
    // ==========================================================

    final position =
        await LocationUtil.instance.getCurrentLocation();

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

    // ==========================================================
    // 8. DEBUG
    // ==========================================================

    debugPrint('==========================================');
    debugPrint('             DEVICE DATA');
    debugPrint('==========================================');

    debugPrint('latitude          : $latitude');
    debugPrint('longitude         : $longitude');

    debugPrint('networkLatitude   : $networkLatitude');
    debugPrint('networkLongitude  : $networkLongitude');

    debugPrint('gpsLatitude       : $gpsLatitude');
    debugPrint('gpsLongitude      : $gpsLongitude');

    debugPrint('geoAddress        : $geoAddress');

    debugPrint('networkInfo       : $strNetworkInfo');

    debugPrint('batteryInfo       : $strBatteryInfo');

    debugPrint('==========================================');

    if (mounted) {
      setState(() {});
    }
  } catch (e, stackTrace) {
    debugPrint('==========================================');
    debugPrint('DEVICE DATA ERROR');
    debugPrint('==========================================');
    debugPrint('ERROR: $e');
    debugPrint('STACK: $stackTrace');
    debugPrint('==========================================');
  }
}
void _getPurposeData() {
  dealerVisitBloc.add(
    GetPurposeEvent(""),
  );
}
  // ============================================================
  // DISPOSE
  // ============================================================

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

  // ============================================================
  // IMAGE
  // ============================================================

  Future<void> _takeDealerImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) return;

      setState(() {
        dealerImage = File(image.path);
      });
    } catch (e) {
      _showError('Unable to open camera');
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

 Future<void> _submit() async {
  // ==========================================================
  // 1. DATE VALIDATION
  // ==========================================================
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
  if (dealerImage == null) {
    _showError('Please upload image');
    return;
  }

  // ==========================================================
  // 6. GET LATEST DEVICE / LOCATION DATA
  // ==========================================================
  //
  // This refreshes:
  // latitude
  // longitude
  // networkLatitude
  // networkLongitude
  // gpsLatitude
  // gpsLongitude
  // geoAddress
  // strNetworkInfo
  // strBatteryInfo
  //
  // immediately before sending the API request.
  //
  await _loadDeviceData();

  // ==========================================================
  // 7. FORMAT DATE
  // ==========================================================
  final String formattedDate =
      DateFormat('yyyy-MM-dd').format(nextFollowUpDate!);

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
  debugPrint('dealerImage      : ${dealerImage!.path}');

  debugPrint('==========================================');

  // ==========================================================
  // 9. SEND BLOC EVENT
  // ==========================================================
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
      // dealerImage: dealerImage!,
    ),
  );
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
        listener: (context, state) {
          // ======================================================
          // SUCCESS
          // ======================================================

          if (state.addLeaveStatus == AddDealerVisitStatus.success) {
            final puposeData=state.purpose;
          

            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        state.successMessage ??
                            'Dealer visit added successfully',
                      ),
                    ),
                  ],
                ),

                backgroundColor: primaryGreen,

                behavior: SnackBarBehavior.floating,

                margin: const EdgeInsets.all(12),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                context.pop(true);
              }
            });
          }

          // ======================================================
          // FAILURE
          // ======================================================

          if (state.addLeaveStatus == AddDealerVisitStatus.failure) {
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

            debugPrint(
    'PURPOSE LENGTH = ${state.purpose.length}',
  );

  debugPrint(
    'PURPOSE DATA = ${state.purpose}',
  );

  
          final bool isLoading =
              state.addLeaveStatus == AddDealerVisitStatus.loading;

          return Scaffold(
            backgroundColor: backgroundColor,

            // ====================================================
            // APP BAR
            // ====================================================
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

            // ====================================================
            // BODY
            // ====================================================
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ======================================
                          // DEALER HEADER
                          // ======================================

                          _buildDealerHeader(),

                          const SizedBox(height: 14),

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
                          _sectionTitle(Icons.history_rounded, 'Last Remarks'),

                          const SizedBox(height: 6),

                          _buildLastRemarks(),

                          const SizedBox(height: 14),

                          // ======================================
                          // DEALER IMAGE
                          // ======================================
                          _buildImageSection(),

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



Widget _buildPurposeDropdown(
  AddDealerVisitState state,
) {
  final purposes = state.purpose;
  

  return Container(
    height: 58,
    padding: const EdgeInsets.fromLTRB(
      11,
      5,
      7,
      2,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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

  Widget _buildImageSection() {
    return InkWell(
      onTap: _takeDealerImage,

      borderRadius: BorderRadius.circular(11),

      child: Container(
        width: double.infinity,

        height: dealerImage == null ? 55 : 100,

        decoration: BoxDecoration(
          color: lightGreen,

          borderRadius: BorderRadius.circular(11),

          border: Border.all(color: primaryGreen.withOpacity(.12)),
        ),

        child: dealerImage == null
            ? Row(
                children: [
                  const SizedBox(width: 12),

                  const Icon(
                    Icons.camera_alt_rounded,
                    color: primaryGreen,
                    size: 19,
                  ),

                  const SizedBox(width: 9),

                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'IMAGE OF DEALER *',

                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                            color: primaryGreen,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Tap to capture dealer image',

                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: primaryGreen,
                  ),

                  const SizedBox(width: 12),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: Stack(
                  fit: StackFit.expand,

                  children: [
                    Image.file(dealerImage!, fit: BoxFit.cover),

                    Positioned(
                      right: 8,
                      top: 8,

                      child: Container(
                        padding: const EdgeInsets.all(7),

                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
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
            onPressed: isLoading ? null : _submit,

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
