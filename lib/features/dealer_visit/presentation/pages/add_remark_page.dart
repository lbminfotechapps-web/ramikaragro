import 'package:solufine/core/theme/typography/app_text_styles.dart';
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
import 'package:solufine/core/theme/app_theme_context.dart';
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

  Color get primaryGreen => context.primaryColor;

  Color get darkGreen => context.primaryColor;

  Color get lightGreen => context.primaryColor.withValues(alpha: 0.1);

  Color get backgroundColor => context.backgroundColor;

  Color get textColor => context.primaryTextColor;

  // ============================================================
  // CONTROLLERS
  // ============================================================
  final _fieldKeys = {
    for (final name in ['date', 'type', 'purpose', 'remark', 'photo'])
      name: GlobalKey(),
  };
  final _fieldFocus = {
    for (final name in ['date', 'type', 'purpose', 'remark', 'photo'])
      name: FocusNode(),
  };

  void _focusInvalidField(String name) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _fieldFocus[name]!.requestFocus();
      final fieldContext = _fieldKeys[name]!.currentContext;
      if (fieldContext != null) {
        Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 300),
          alignment: 0.2,
        );
      }
    });
  }

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
          content: Text(message, style: AppTextStyles.body),
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
    for (final node in _fieldFocus.values) {
      node.dispose();
    }
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
          data: Theme.of(context).copyWith(colorScheme: context.appColors),
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
      _focusInvalidField('date');
      return;
    }

    // ==========================================================
    // 2. FOLLOW UP TYPE VALIDATION
    // ==========================================================
    if (selectedFollowUpType.trim().isEmpty ||
        selectedFollowUpType == 'Select Follow Up Type') {
      _showError('Please select follow up type');
      _focusInvalidField('type');
      return;
    }

    // ==========================================================
    // 3. PURPOSE VALIDATION
    // ==========================================================
    if (selectedPurposeId == null ||
        selectedPurposeId!.trim().isEmpty ||
        selectedPurposeId == '0') {
      _showError('Please select purpose type');
      _focusInvalidField('purpose');
      return;
    }

    // ==========================================================
    // 4. REMARK VALIDATION
    // ==========================================================
    final String remark = remarkController.text.trim();

    if (remark.isEmpty) {
      _showError('Please enter remark');
      _focusInvalidField('remark');
      return;
    }

    // ==========================================================
    // 5. IMAGE VALIDATION
    // ==========================================================
    if (imagePath == null) {
      _showError('Please upload image');
      _focusInvalidField('photo');
      return;
    }

    FocusScope.of(context).unfocus();

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
            Icon(
              Icons.error_outline_rounded,
              color: context.appColors.onError,
              size: 20,
            ),

            const SizedBox(width: 8),

            Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
          ],
        ),

        backgroundColor: context.appColors.error,

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
                    Icon(
                      Icons.error_outline_rounded,
                      color: context.appColors.onError,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'Unable to add dealer visit',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),

                backgroundColor: context.appColors.error,

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
                  Text(
                    'Dealer Visit',
                    style: AppTextStyles.sectionTitle,
                  ),

                  Text(
                    'Add follow-up details',
                    style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(.75)),
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
      color: context.cardBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _showFollowupHistory,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: context.primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-up History',
                      style: AppTextStyles.listTitle.copyWith(
                        color: context.cardTextColor,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'View previous dealer follow-ups',
                      style: AppTextStyles.caption.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.primaryColor,
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
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: context.borderColor),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .025),

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

            child: Icon(
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
                Text(
                  'DEALER',

                  style: AppTextStyles.badge.copyWith(
                    letterSpacing: .8,
                    color: context.secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.dealerName.isEmpty ? 'Dealer' : widget.dealerName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.labelLarge.copyWith(color: textColor),
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

            child: Text(
              'VISIT',

              style: AppTextStyles.labelSmall.copyWith(color: primaryGreen),
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

        Text(title, style: AppTextStyles.listTitle.copyWith(color: textColor)),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    final bool selected = nextFollowUpDate != null;

    return InkWell(
      key: _fieldKeys['date'],
      focusNode: _fieldFocus['date'],
      onTap: _selectNextFollowUpDate,

      borderRadius: BorderRadius.circular(11),

      child: Container(
        height: 58,

        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: context.cardBackgroundColor,

          borderRadius: BorderRadius.circular(11),

          border: Border.all(
            color: selected
                ? primaryGreen.withOpacity(.35)
                : context.borderColor,
          ),
        ),

        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,

              decoration: BoxDecoration(
                color: selected ? lightGreen : context.appTheme.inputBackground,

                borderRadius: BorderRadius.circular(8),
              ),

              child: Icon(
                Icons.calendar_today_rounded,

                size: 17,

                color: selected ? primaryGreen : context.secondaryTextColor,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'NEXT FOLLOW-UP DATE *',

                    style: AppTextStyles.badge.copyWith(
                      letterSpacing: .6,
                      color: context.secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    selected
                        ? DateFormat('dd MMM yyyy').format(nextFollowUpDate!)
                        : 'Select follow-up date',

                    style: AppTextStyles.label.copyWith(
                      color: selected ? textColor : context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.calendar_month_rounded, size: 19, color: primaryGreen),
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
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.borderColor),
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
            child: Icon(Icons.flag_rounded, size: 17, color: primaryGreen),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PURPOSE TYPE *',
                  style: AppTextStyles.badge.copyWith(
                    letterSpacing: .6,
                    color: context.secondaryTextColor,
                  ),
                ),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: _fieldKeys['purpose'],
                      focusNode: _fieldFocus['purpose'],
                      value: selectedPurposeId,

                      isExpanded: true,

                      isDense: true,

                      hint: Text(
                        'Select Purpose',
                        style: AppTextStyles.label.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),

                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: primaryGreen,
                      ),

                      style: AppTextStyles.label.copyWith(color: textColor),

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
                            style: AppTextStyles.body,
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
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: context.borderColor),
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

                  style: AppTextStyles.badge.copyWith(
                    letterSpacing: .6,
                    color: context.secondaryTextColor,
                  ),
                ),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: _fieldKeys['type'],
                      focusNode: _fieldFocus['type'],
                      value: value,

                      isExpanded: true,

                      isDense: true,

                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: primaryGreen,
                      ),

                      style: AppTextStyles.label.copyWith(color: textColor),

                      onChanged: onChanged,

                      items: items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,

                          child: Text(item, style: AppTextStyles.body),
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
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: context.borderColor),
      ),

      child: TextField(
        key: _fieldKeys['remark'],
        focusNode: _fieldFocus['remark'],
        controller: remarkController,

        maxLines: 3,

        textCapitalization: TextCapitalization.sentences,

        style: AppTextStyles.input.copyWith(color: textColor),

        decoration: InputDecoration(
          hintText: 'Enter visit remark...',

          hintStyle: AppTextStyles.inputHint.copyWith(
            color: context.secondaryTextColor,
          ),

          prefixIcon: Padding(
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
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: context.borderColor),
      ),

      child: ListView.separated(
        shrinkWrap: true,

        physics: const BouncingScrollPhysics(),

        itemCount: lastRemarks.length,

        separatorBuilder: (_, __) =>
            Divider(height: 1, color: context.appTheme.inputBackground),

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

                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),

                Expanded(
                  child: Text(
                    lastRemarks[index],

                    style: AppTextStyles.caption.copyWith(color: textColor),
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
      key: _fieldKeys['photo'],
      focusNode: _fieldFocus['photo'],
      onTap: _captureImage,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                color: context.primaryColor,
                size: 27,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Add Image',
              style: AppTextStyles.cardTitle.copyWith(
                color: context.cardTextColor,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Tap to take a photo',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
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
      color: context.primaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: context.onPrimaryColor, size: 21),
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
        color: context.cardBackgroundColor,

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .07),

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

              disabledBackgroundColor: context.secondaryTextColor,

              foregroundColor: context.onPrimaryColor,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: isLoading
                ? SizedBox(
                    height: 19,
                    width: 19,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.onPrimaryColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18),

                      SizedBox(width: 7),

                      Text(
                        'SUBMIT VISIT',

                        style: AppTextStyles.labelLarge.copyWith(
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
            color: context.backgroundColor,
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
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.primaryColor,
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
                      color: context.primaryColor,
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
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.history_rounded,
              color: context.onPrimaryColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dealer Follow-up History',
                  style: AppTextStyles.dialogTitle.copyWith(
                    color: context.onPrimaryColor,
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
            icon: Icon(Icons.refresh_rounded, color: context.onPrimaryColor),
          ),

          // =======================================================
          // CLOSE
          // =======================================================
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close_rounded, color: context.onPrimaryColor),
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
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .035),
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
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: context.primaryColor,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              item.followupDate,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: context.primaryColor,
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
                          color: context.appTheme.inputBackground,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: context.secondaryTextColor,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              item.followupTime,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: context.secondaryTextColor,
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
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.primaryColor,
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
              color: context.appTheme.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17,
                      color: context.primaryColor,
                    ),

                    SizedBox(width: 7),

                    Text(
                      'Remark',
                      style: AppTextStyles.label.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  item.followupRemark.isEmpty
                      ? 'No remark'
                      : item.followupRemark,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.cardTextColor,
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
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: context.primaryColor),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.cardTextColor,
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 55,
              color: context.secondaryTextColor,
            ),

            SizedBox(height: 14),

            Text(
              'No Follow-up History',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.cardTextColor,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'No previous follow-ups found for this dealer.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
