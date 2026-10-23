import 'dart:async';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';
import '../../domain/entities/add_schedule_request.dart';
import '../bloc/add_schedule_submit_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/theme/app_theme_context.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/crop_entity.dart';
import '../../domain/entities/schedule_farmer_entity.dart';
import '../../domain/entities/farmer_plot_entity.dart';

import '../bloc/farmer_schedule_bloc.dart';
import '../bloc/farmer_schedule_event.dart';
import '../bloc/farmer_schedule_state.dart';

class FarmerSchedulePage extends StatefulWidget {
  const FarmerSchedulePage({super.key});

  @override
  State<FarmerSchedulePage> createState() => _FarmerSchedulePageState();
}

class _FarmerSchedulePageState extends State<FarmerSchedulePage> {
  Color get _themeTint => Color.alphaBlend(
    context.primaryColor.withValues(alpha: 0.08),
    context.cardBackgroundColor,
  );

  final TextEditingController farmerController = TextEditingController();
  final TextEditingController cropController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  Timer? farmerTimer;
  Timer? cropTimer;

  // Product autocomplete: loaded only after typing.
  Timer? productTimer;
  int _productSearchVersion = 0;
  bool productLoading = false;
  bool showProductSuggestions = false;
  List<String> productSuggestions = [];

  String selectedType = 'Select Type';
  String selectedQuantityUnit = 'Select Unit';
  String selectedWaterUnit = 'Select Unit';

  final List<String> typeList = ['Select Type', 'Spray', 'Drip'];

  final List<String> quantityUnits = ['Select Unit', 'Ltr', 'Ml', 'Kg', 'Gm'];

  final List<String> waterUnits = ['Select Unit', 'Ltr'];

  String _employeeId = '';
  bool _employeeLoading = true;
  bool _submittingSchedule = false;
  late final AddScheduleSubmitBloc _submitBloc;
  StreamSubscription<AddScheduleSubmitState>? _submitSubscription;
  bool _scheduleSubmitted = false;
  String _selectedCropId = '';
  AddScheduleDetail? _pendingDetail;
  final List<AddScheduleDetail> _currentDetails = [];
  DateTime? _pendingSectionDate;
  List<AddScheduleDetail>? _pendingSectionDetails;
  final List<_SavedScheduleSection> _savedSections = [];

  // Pending UI entries are committed only when the existing BLoC
  // confirms that AddScheduleLine / SaveScheduleSection succeeded.
  String _normalizedUnit(String unit) {
    switch (unit.toLowerCase().trim()) {
      case 'kg':
        return 'Kg';
      case 'gm':
        return 'Gm';
      case 'ml':
        return 'Ml';
      case 'ltr':
        return 'Ltr';

      default:
        return unit.trim();
    }
  }

  void _resetLocalScheduleData() {
    _selectedCropId = '';
    _pendingDetail = null;
    _currentDetails.clear();
    _pendingSectionDate = null;
    _pendingSectionDetails = null;
    _savedSections.clear();
    _scheduleSubmitted = false;
    _submitBloc.add(ResetAddScheduleSubmit());
  }

  @override
  void initState() {
    super.initState();
    _submitBloc = GetIt.instance<AddScheduleSubmitBloc>();
    _submitSubscription = _submitBloc.stream.listen((submission) {
      if (!mounted) return;
      setState(() {
        _submittingSchedule =
            submission.status == AddScheduleSubmitStatus.loading;
        if (submission.status == AddScheduleSubmitStatus.success)
          _scheduleSubmitted = true;
      });
      if (submission.status == AddScheduleSubmitStatus.success) {
        _showSubmissionSuccessDialog(submission.message);
      } else if (submission.status == AddScheduleSubmitStatus.failure) {
        _showMessage(submission.message);
      }
    });
    _loadEmployeeId();
  }

  Future<void> _showSubmissionSuccessDialog(String message) async {
    final acknowledged = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Schedule submitted'),
          content: Text(
            message.trim().isEmpty
                ? 'Schedule submitted successfully.'
                : message,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || acknowledged != true) return;
    context.read<FarmerScheduleBloc>().add(ClearSubmittedSchedules());
    setState(_resetLocalScheduleData);
  }

  Future<void> _loadEmployeeId() async {
    try {
      final userData = await SecureStorage.instance.getUserData();
      if (!mounted) return;
      setState(() {
        _employeeId = (userData?['user_id'] ?? userData?['userId'] ?? '')
            .toString()
            .trim();
        _employeeLoading = false;
      });
      final farmer = context.read<FarmerScheduleBloc>().state.selectedFarmer;
      if (farmer != null) _loadPlotsForFarmer(farmer);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _employeeLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to read employee ID: $e')));
    }
  }

  void _loadPlotsForFarmer(ScheduleFarmerEntity farmer) {
    if (_employeeLoading) return;
    if (_employeeId.isEmpty || _employeeId == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login again.')));
      return;
    }
    context.read<FarmerScheduleBloc>().add(
      LoadFarmerPlots(empId: _employeeId, farmerId: farmer.farmerId),
    );
  }

  Future<void> _openPlotRegistration(ScheduleFarmerEntity farmer) async {
    await context.pushNamed<bool>('plotRegistration', extra: farmer);
    if (!mounted) return;
    _clearSelectedFarmer();
  }

  @override
  void dispose() {
    farmerTimer?.cancel();
    cropTimer?.cancel();
    productTimer?.cancel();
    _productSearchVersion++;
    _submitSubscription?.cancel();
    _submitBloc.close();

    farmerController.dispose();
    cropController.dispose();
    productController.dispose();
    quantityController.dispose();
    waterController.dispose();
    remarkController.dispose();

    super.dispose();
  }

  // ============================================================
  // FARMER SEARCH
  // ============================================================

  void _clearFarmerSearch() {
    farmerTimer?.cancel();
    farmerController.clear();
  }

  void _clearSelectedFarmer() {
    _clearFarmerSearch();
    cropTimer?.cancel();
    cropController.clear();
    productController.clear();
    _clearProductSuggestions();
    quantityController.clear();
    waterController.clear();
    remarkController.clear();
    context.read<FarmerScheduleBloc>().add(ClearSelectedFarmer());
    setState(() {
      _resetLocalScheduleData();
      selectedType = 'Select Type';
      selectedQuantityUnit = 'Select Unit';
      selectedWaterUnit = 'Select Unit';
    });
  }

  void _searchFarmer(String value) {
    farmerTimer?.cancel();

    final String search = value.trim();

    if (search.length < 3) {
      return;
    }

    farmerTimer = Timer(Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      context.read<FarmerScheduleBloc>().add(FarmerSearchChanged(search));
    });
  }

  // ============================================================
  // CROP SEARCH
  // ============================================================

  void _searchCrop(String value) {
    cropTimer?.cancel();

    final String search = value.trim();

    if (search.length < 3) {
      return;
    }

    cropTimer = Timer(Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      context.read<FarmerScheduleBloc>().add(CropSearchChanged(search));
    });
  }

  // ============================================================
  // PRODUCT AUTOCOMPLETE (manual entry always allowed)
  // ============================================================

  void _clearProductSuggestions() {
    productTimer?.cancel();
    _productSearchVersion++;
    if (!mounted) return;
    setState(() {
      productSuggestions = [];
      productLoading = false;
      showProductSuggestions = false;
    });
  }

  void _searchProduct(String value) {
    productTimer?.cancel();
    final query = value.trim();
    final version = ++_productSearchVersion;

    if (query.isEmpty) {
      setState(() {
        productSuggestions = [];
        productLoading = false;
        showProductSuggestions = false;
      });
      return;
    }

    setState(() {
      productLoading = true;
      productSuggestions = [];
      showProductSuggestions = true;
    });

    productTimer = Timer(Duration(milliseconds: 500), () async {
      try {
        // Reuse the app's configured DioClient from GetIt.
        final dioClient = GetIt.I<DioClient>();
        final response = await dioClient.client.post<dynamic>(
          ApiClient.getProductListForSchedule,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
          ),
        );

        dynamic data = response.data;
        if (data is String) data = jsonDecode(data.trim());
        if (data is! Map || ![true, 1, 'true'].contains(data['status'])) {
          throw FormatException('Product API returned an error.');
        }
        final result = data['result'];
        if (result is! List) {
          throw FormatException('Product result is not a list.');
        }

        final seen = <String>{};
        final matches = <String>[];
        for (final item in result) {
          if (item is! Map) continue;
          final raw = (item['fld_product_name'] ?? '').toString();
          final name = raw.split('*_*').first.trim();
          if (name.isNotEmpty &&
              name.toLowerCase().contains(query.toLowerCase()) &&
              seen.add(name.toLowerCase())) {
            matches.add(name);
          }
        }
        if (!mounted || version != _productSearchVersion) return;
        setState(() {
          productSuggestions = matches;
          productLoading = false;
        });
      } catch (error) {
        debugPrint('Product autocomplete error: $error');
        if (!mounted || version != _productSearchVersion) return;
        setState(() {
          productSuggestions = [];
          productLoading = false;
        });
        // Keep manual entry usable even if the API fails.
      }
    });
  }

  Widget _buildProductSuggestions() {
    if (!showProductSuggestions || productSuggestions.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      constraints: BoxConstraints(maxHeight: 190.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: productSuggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final name = productSuggestions[index];
          return InkWell(
            onTap: () {
              productController.text = name;
              productController.selection = TextSelection.collapsed(
                offset: name.length,
              );
              _clearProductSuggestions();
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(name, style: TextStyle(fontSize: 11.sp)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        backgroundColor: context.primaryColor,

        titleStyle: AppTextStyles.appBarTitle.copyWith(
          color: context.onPrimaryColor,
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),

        title: 'Schedule',

        showBackButton: true,
      ),

      body: BlocConsumer<FarmerScheduleBloc, FarmerScheduleState>(
        listener: (context, state) {
          if (state.message == 'Schedule added.') {
            if (!state.isFailure && _pendingDetail != null) {
              _currentDetails.add(_pendingDetail!);
            }
            _pendingDetail = null;
          }
          if (state.message == 'Schedule added to list.') {
            if (!state.isFailure &&
                _pendingSectionDate != null &&
                _pendingSectionDetails != null &&
                _pendingSectionDetails!.isNotEmpty) {
              _savedSections.add(
                _SavedScheduleSection(
                  date: _pendingSectionDate!,
                  details: List.unmodifiable(_pendingSectionDetails!),
                ),
              );
              _currentDetails.clear();
            }
            _pendingSectionDate = null;
            _pendingSectionDetails = null;
          }
          if (!state.isFailure && state.message == 'Schedule added.') {
            productController.clear();
            _clearProductSuggestions();
            quantityController.clear();
            waterController.clear();
            remarkController.clear();
            setState(() {
              selectedType = 'Select Type';
              selectedQuantityUnit = 'Select Unit';
              selectedWaterUnit = 'Select Unit';
            });
          }
          if (!state.isFailure && state.message == 'Schedule added to list.') {
            cropController.clear();
          }
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,

                  backgroundColor: state.isFailure
                      ? context.appColors.error
                      : context.primaryColor,

                  content: Text(state.message),
                ),
              );

            context.read<FarmerScheduleBloc>().add(ClearScheduleMessage());
          }
        },

        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 16.h),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _buildFarmerSection(state),

                SizedBox(height: 12.h),

                if (state.selectedFarmer?.hasRegisteredPlots == true)
                  _buildScheduleForm(state),

                if (state.selectedFarmer?.hasRegisteredPlots == true &&
                    state.schedules.isNotEmpty) ...[
                  SizedBox(height: 12.h),

                  _buildScheduleList(state),

                  SizedBox(height: 12.h),
                ],
                if (state.selectedFarmer?.hasRegisteredPlots == true) ...[
                  SizedBox(height: 12.h),
                  _buildScheduleActions(state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FARMER SECTION
  // ============================================================

  Widget _buildFarmerSection(FarmerScheduleState state) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: _title(Icons.person_search_rounded, 'Select Farmer '),
              ),
              SizedBox(width: 8.w),
              FilledButton.icon(
                onPressed: () => context.push(AppRouter.scheduleList),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
                  elevation: 2,
                  shadowColor: context.primaryColor.withOpacity(0.25),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  minimumSize: Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(Icons.calendar_month_rounded, size: 16.sp),
                label: Text('View Schedule'),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          TextField(
            controller: farmerController,

            onChanged: _searchFarmer,

            textInputAction: TextInputAction.search,

            decoration:
                _inputDecoration(
                  'Search Farmer Name',
                  Icons.search_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: 'Clear farmer search',
                    icon: Icon(Icons.clear),
                    onPressed: _submittingSchedule
                        ? null
                        : _clearSelectedFarmer,
                  ),
                  helperText: 'Search after 3 characters. Wait for 2 seconds.',

                  helperStyle: TextStyle(
                    fontSize: 9.sp,
                    color: context.appColors.error,
                  ),
                ),
          ),

          if (state.farmerLoading)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: LinearProgressIndicator(),
            ),

          if (!state.farmerLoading && state.farmers.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
              child: Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 16.sp,
                    color: context.primaryColor,
                  ),

                  SizedBox(width: 5.w),

                  Text(
                    '${state.farmers.length} farmers found',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

          if (state.farmers.isNotEmpty) _buildFarmerSuggestions(state.farmers),

          if (state.selectedFarmer != null) ...[
            _buildSelectedFarmer(state.selectedFarmer!),
            SizedBox(height: 10.h),
            if (state.selectedFarmer!.hasRegisteredPlots)
              _buildFarmerPlotSection(state)
            else if (state.selectedFarmer!.farmerPlotStatus == 0)
              _buildRegisterPlotSection(state.selectedFarmer!),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED FARMER
  // ============================================================

  Widget _buildSelectedFarmer(ScheduleFarmerEntity farmer) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(top: 10.h),

      padding: EdgeInsets.all(12.w),

      decoration: BoxDecoration(
        color: _themeTint,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: context.borderColor),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 38.w,
            height: 38.w,

            decoration: BoxDecoration(
              color: context.cardBackgroundColor,

              borderRadius: BorderRadius.circular(10.r),
            ),

            child: Icon(Icons.person_rounded, color: context.primaryColor),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  farmer.farmerName,

                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (farmer.talukaName.isNotEmpty) ...[
                  SizedBox(height: 3.h),

                  Text(
                    'Taluka: ${farmer.talukaName}',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Icon(Icons.check_circle_rounded, color: context.primaryColor),
        ],
      ),
    );
  }

  // ============================================================
  // FARMER SUGGESTIONS
  // ============================================================

  Widget _buildFarmerSuggestions(List<ScheduleFarmerEntity> farmers) {
    return Container(
      width: double.infinity,

      constraints: BoxConstraints(maxHeight: 280.h),

      margin: EdgeInsets.only(top: 5.h),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: context.borderColor),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.04),

            blurRadius: 8,

            offset: Offset(0, 3),
          ),
        ],
      ),

      child: ListView.separated(
        shrinkWrap: true,

        padding: EdgeInsets.zero,

        itemCount: farmers.length,

        separatorBuilder: (context, index) {
          return Divider(height: 1, color: context.borderColor);
        },

        itemBuilder: (context, index) {
          final ScheduleFarmerEntity farmer = farmers[index];

          final String firstLetter = farmer.farmerName.trim().isNotEmpty
              ? farmer.farmerName.trim()[0].toUpperCase()
              : '?';

          return Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: () {
                _resetLocalScheduleData();
                farmerController.text = farmer.farmerName;

                farmerController.selection = TextSelection.fromPosition(
                  TextPosition(offset: farmerController.text.length),
                );

                farmerTimer?.cancel();
                context.read<FarmerScheduleBloc>().add(FarmerSelected(farmer));
                // Always verify against plot API. The farmer status can be stale.
                _loadPlotsForFarmer(farmer);

                FocusScope.of(context).unfocus();
              },

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CircleAvatar(
                      radius: 20.r,

                      backgroundColor: _themeTint,

                      child: Text(
                        firstLetter,

                        style: TextStyle(
                          fontSize: 14.sp,

                          fontWeight: FontWeight.w700,

                          color: context.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            farmer.farmerName,

                            style: TextStyle(
                              fontSize: 12.5.sp,

                              fontWeight: FontWeight.w600,

                              color: context.primaryTextColor,
                            ),
                          ),

                          if (farmer.talukaName.isNotEmpty) ...[
                            SizedBox(height: 3.h),

                            Row(
                              children: [
                                Icon(
                                  Icons.location_city_outlined,
                                  size: 12.sp,
                                  color: context.secondaryTextColor,
                                ),

                                SizedBox(width: 4.w),

                                Expanded(
                                  child: Text(
                                    'Taluka: ${farmer.talukaName}',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: context.secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (farmer.address.isNotEmpty) ...[
                            SizedBox(height: 3.h),

                            Text(
                              farmer.address,

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 9.sp,

                                height: 1.3,

                                color: context.secondaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.secondaryTextColor,
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

  // ============================================================
  // FARMER PLOTS - API BACKED
  // ============================================================
  Widget _buildFarmerPlotSection(FarmerScheduleState state) {
    final farmer = state.selectedFarmer!;
    final selectedId =
        state.selectedPlot != null &&
            state.plots.any((p) => p.plotId == state.selectedPlot!.plotId)
        ? state.selectedPlot!.plotId
        : null;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _themeTint,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  Icons.landscape_outlined,
                  color: context.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Plot ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: context.primaryTextColor,
                      ),
                    ),
                    Text(
                      'Registered plots for this farmer',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!state.plotLoading)
                Text(
                  '${state.plots.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.primaryColor,
                  ),
                ),
              IconButton(
                tooltip: 'Refresh plots',
                onPressed: state.plotLoading
                    ? null
                    : () => _loadPlotsForFarmer(farmer),
                icon: Icon(Icons.refresh_rounded, color: context.primaryColor),
              ),
            ],
          ),
          if (state.plotLoading) LinearProgressIndicator(),
          if (state.plotError.isNotEmpty) ...[
            Text(
              state.plotError,
              style: TextStyle(color: context.appColors.error, fontSize: 11.sp),
            ),
            TextButton(
              onPressed: () => _loadPlotsForFarmer(farmer),
              child: Text('Retry'),
            ),
          ],
          if (!state.plotLoading &&
              state.plotError.isEmpty &&
              state.plots.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No registered plots found.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          if (!state.plotLoading && state.plots.isNotEmpty)
            DropdownButtonFormField<String>(
              // Key forces a fresh dropdown when the farmer changes.
              key: ValueKey(farmer.farmerId),
              value: selectedId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Plot Name *',
                prefixIcon: Icon(
                  Icons.grass_rounded,
                  color: context.primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
                isDense: true,
              ),
              items: state.plots
                  .map(
                    (plot) => DropdownMenuItem<String>(
                      value: plot.plotId,
                      child: Text(
                        plot.plotName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                final plot = state.plots.firstWhere((p) => p.plotId == id);
                _resetLocalScheduleData();
                context.read<FarmerScheduleBloc>().add(
                  FarmerPlotSelected(plot),
                );
              },
            ),
          SizedBox(height: 12.h),
          _buildRegisterPlotSection(farmer),
          if (state.selectedPlot != null) ...[
            SizedBox(height: 10.h),
            _buildSelectedPlotDetails(state.selectedPlot!),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedPlotDetails(FarmerPlotEntity plot) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: _themeTint,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: context.primaryColor,
                size: 18,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  plot.plotName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _plotInfo('CROP', plot.cropName)),
              SizedBox(width: 8.w),
              Expanded(child: _plotInfo('SOWING DATE', plot.sowingDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _plotInfo(String label, String value) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, color: context.secondaryTextColor),
          ),
          SizedBox(height: 3.h),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterPlotSection(ScheduleFarmerEntity farmer) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _openPlotRegistration(farmer),
        style: FilledButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: context.onPrimaryColor,
          minimumSize: Size.fromHeight(48),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          textStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        icon: Icon(Icons.add_circle_outline_rounded, size: 21),
        label: Text('Add Plot'),
      ),
    );
  }

  // ============================================================
  // SCHEDULE FORM
  // ============================================================

  Widget _buildScheduleForm(FarmerScheduleState state) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _title(Icons.calendar_month_rounded, 'Schedule Date'),

          SizedBox(height: 12.h),

          // ======================================================
          // DATE
          // ======================================================
          InkWell(
            borderRadius: BorderRadius.circular(11.r),

            onTap: () => _selectDate(state),

            child: InputDecorator(
              decoration: _inputDecoration(
                'Schedule Date *',
                Icons.calendar_today_rounded,
              ),

              child: Text(
                state.selectedDate == null
                    ? 'Select Schedule Date'
                    : DateFormat('dd/MM/yyyy').format(state.selectedDate!),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'Note: Doses for 200 liters',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // ======================================================
          // CROP - NEW FARMER STYLE DESIGN
          // ======================================================
          SizedBox(height: 10.h),

          // ======================================================
          // PRODUCT + TYPE
          // ======================================================
          Row(
            children: [
              Expanded(
                flex: 6,

                child: TextField(
                  controller: productController,
                  onChanged: _searchProduct,

                  decoration:
                      _inputDecoration(
                        'Product Name',
                        Icons.inventory_2_outlined,
                      ).copyWith(
                        suffixIcon: productLoading
                            ? Padding(
                                padding: EdgeInsets.all(13),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                flex: 4,

                child: _dropdown(
                  label: 'Type *',
                  value: selectedType,

                  values: typeList,

                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? 'Select Type';
                    });
                  },
                ),
              ),
            ],
          ),

          _buildProductSuggestions(),

          SizedBox(height: 10.h),

          // ======================================================
          // QUANTITY
          // ======================================================
          Row(
            children: [
              Expanded(
                flex: 6,

                child: TextField(
                  controller: quantityController,

                  keyboardType: TextInputType.numberWithOptions(decimal: true),

                  decoration: _inputDecoration(
                    'Quantity',
                    Icons.numbers_rounded,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                flex: 4,

                child: _dropdown(
                  label: 'Unit *',
                  value: selectedQuantityUnit,

                  values: quantityUnits,

                  onChanged: (value) {
                    setState(() {
                      selectedQuantityUnit = value ?? 'Select Unit';
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ======================================================
          // WATER
          // ======================================================
          Row(
            children: [
              Expanded(
                flex: 6,

                child: TextField(
                  controller: waterController,

                  keyboardType: TextInputType.numberWithOptions(decimal: true),

                  decoration: _inputDecoration(
                    'Water',
                    Icons.water_drop_outlined,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                flex: 4,

                child: _dropdown(
                  label: 'Unit *',
                  value: selectedWaterUnit,

                  values: waterUnits,

                  onChanged: (value) {
                    setState(() {
                      selectedWaterUnit = value ?? 'Select Unit';
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ======================================================
          // REMARK
          // ======================================================
          TextField(
            controller: remarkController,

            maxLines: 2,

            decoration: _inputDecoration('Enter Remark', Icons.notes_rounded),
          ),

          SizedBox(height: 12.h),

          // ======================================================
          // ADD SCHEDULE BUTTON
          // ======================================================
          SizedBox(
            width: double.infinity,

            height: 46.h,

            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryColor),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),

              onPressed: _addScheduleLine,

              icon: Icon(Icons.add_rounded),

              label: Text('Add Schedule'),
            ),
          ),

          // ======================================================
          // CURRENT SCHEDULE PREVIEW
          // ======================================================
          if (state.currentSchedule.isNotEmpty) ...[
            SizedBox(height: 12.h),

            _buildCurrentProducts(state),

            SizedBox(height: 10.h),

            SizedBox(
              width: double.infinity,

              height: 48.h,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,

                  foregroundColor: context.onPrimaryColor,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),

                onPressed: () {
                  final current = context.read<FarmerScheduleBloc>().state;
                  _pendingSectionDate = current.selectedDate;
                  _pendingSectionDetails = List.of(_currentDetails);
                  context.read<FarmerScheduleBloc>().add(SaveScheduleSection());
                },

                icon: Icon(Icons.add_circle_outline_rounded),

                label: Text('Add Crop Schedule'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // CROP SECTION
  // SAME DESIGN STYLE AS FARMER
  // ============================================================

  Widget _buildCurrentProducts(FarmerScheduleState state) {
    final busy =
        _submittingSchedule ||
        _scheduleSubmitted ||
        _pendingDetail != null ||
        _pendingSectionDetails != null;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current Schedule',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${state.currentScheduleLines.length} products',
                style: TextStyle(fontSize: 10.sp, color: context.primaryColor),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Review products, then tap Add Crop Schedule.',
            style: TextStyle(
              fontSize: 10.sp,
              color: context.secondaryTextColor,
            ),
          ),
          ...state.currentScheduleLines.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = index < _currentDetails.length
                ? _currentDetails[index]
                : null;
            final remarkStart = entry.value.indexOf('\nRemark : ');
            return Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 2.w, 8.h),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail?.productName ?? entry.value,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: context.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete ${detail?.productName ?? "product"}',
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: context.appColors.error,
                          size: 20,
                        ),
                        onPressed: busy || detail == null
                            ? null
                            : () {
                                setState(() => _currentDetails.removeAt(index));
                                context.read<FarmerScheduleBloc>().add(
                                  RemoveCurrentScheduleProduct(index),
                                );
                              },
                      ),
                    ],
                  ),
                  if (detail != null)
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 4.h,
                      children: [
                        Text(
                          detail.productType,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Qty: ${detail.productQty} ${detail.unit}',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        Text(
                          'Water: ${detail.waterQty} ${detail.waterUnit}',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ],
                    ),
                  if (remarkStart >= 0) ...[
                    SizedBox(height: 5.h),
                    Text(
                      entry.value.substring(remarkStart + 1),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCropSection(FarmerScheduleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // SEARCH
        TextField(
          controller: cropController,

          onChanged: _searchCrop,

          textInputAction: TextInputAction.search,

          decoration: _inputDecoration('Search Crop Name', Icons.grass_rounded)
              .copyWith(
                helperText: 'Search after 3 characters. Wait for 2 seconds.',

                helperStyle: TextStyle(
                  fontSize: 9.sp,
                  color: context.appColors.error,
                ),
              ),
        ),

        // LOADING
        if (state.cropLoading)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: LinearProgressIndicator(),
          ),

        // RESULT COUNT
        if (!state.cropLoading && state.crops.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 4.h),

            child: Row(
              children: [
                Icon(
                  Icons.grass_rounded,
                  size: 16.sp,
                  color: context.primaryColor,
                ),

                SizedBox(width: 5.w),

                Text(
                  '${state.crops.length} crops found',

                  style: TextStyle(
                    fontSize: 11.sp,

                    fontWeight: FontWeight.w600,

                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
          ),

        // RESULT LIST
        if (state.crops.isNotEmpty) _buildCropSuggestions(state.crops),

        // SELECTED CROP
        if (state.selectedCropName.trim().isNotEmpty)
          _buildSelectedCrop(state.selectedCropName),
      ],
    );
  }

  // ============================================================
  // SELECTED CROP
  // ============================================================

  Widget _buildSelectedCrop(String cropName) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(top: 10.h),

      padding: EdgeInsets.all(12.w),

      decoration: BoxDecoration(
        color: _themeTint,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: context.borderColor),
      ),

      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,

            decoration: BoxDecoration(
              color: context.cardBackgroundColor,

              borderRadius: BorderRadius.circular(10.r),
            ),

            child: Icon(Icons.grass_rounded, color: context.primaryColor),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Selected Crop',

                  style: TextStyle(
                    fontSize: 9.sp,
                    color: context.secondaryTextColor,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  cropName,

                  style: TextStyle(
                    fontSize: 13.sp,

                    fontWeight: FontWeight.w700,

                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.check_circle_rounded, color: context.primaryColor),
        ],
      ),
    );
  }

  // ============================================================
  // CROP SUGGESTIONS
  // ============================================================

  Widget _buildCropSuggestions(List<CropEntity> crops) {
    return Container(
      width: double.infinity,

      constraints: BoxConstraints(maxHeight: 280.h),

      margin: EdgeInsets.only(top: 5.h),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: context.borderColor),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.04),

            blurRadius: 8,

            offset: Offset(0, 3),
          ),
        ],
      ),

      child: ListView.separated(
        shrinkWrap: true,

        padding: EdgeInsets.zero,

        itemCount: crops.length,

        separatorBuilder: (context, index) {
          return Divider(height: 1, color: context.borderColor);
        },

        itemBuilder: (context, index) {
          final CropEntity crop = crops[index];

          return Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: () {
                _selectedCropId = crop.cropId;
                cropController.text = crop.cropName;

                cropController.selection = TextSelection.fromPosition(
                  TextPosition(offset: cropController.text.length),
                );

                context.read<FarmerScheduleBloc>().add(
                  CropSelected(crop.cropName),
                );

                FocusScope.of(context).unfocus();
              },

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,

                      backgroundColor: _themeTint,

                      child: Icon(
                        Icons.grass_rounded,

                        size: 20.sp,

                        color: context.primaryColor,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            crop.cropName,

                            style: TextStyle(
                              fontSize: 12.5.sp,

                              fontWeight: FontWeight.w600,

                              color: context.primaryTextColor,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            'Tap to select crop',

                            style: TextStyle(
                              fontSize: 9.sp,

                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.secondaryTextColor,
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

  // ============================================================
  // ADD PRODUCT SCHEDULE
  // ============================================================

  void _addScheduleLine() {
    final state = context.read<FarmerScheduleBloc>().state;
    if (_submittingSchedule || _scheduleSubmitted) return;
    if (state.selectedFarmer == null || state.selectedPlot == null) {
      // _showMessage('Select a farmer and registered plot first.');
      _showMessage('Select a plot first.');
      return;
    }
    if (state.selectedDate == null) {
      _showMessage('Please select a schedule date.');
      return;
    }
    if (productController.text.trim().isEmpty) {
      _showMessage('Enter product name.');
      return;
    }
    if (selectedType == 'Select Type') {
      _showMessage('Select product type.');
      return;
    }
    if ((double.tryParse(quantityController.text.trim()) ?? 0) <= 0) {
      _showMessage('Enter a valid quantity greater than zero.');
      return;
    }
    if (selectedQuantityUnit == 'Select Unit') {
      _showMessage('Select quantity unit.');
      return;
    }
    if ((double.tryParse(waterController.text.trim()) ?? 0) <= 0) {
      _showMessage('Enter a valid water quantity greater than zero.');
      return;
    }
    if (selectedWaterUnit == 'Select Unit') {
      _showMessage('Select water unit.');
      return;
    }
    if (_pendingDetail != null) {
      _showMessage('Wait for the previous product to be added.');
      return;
    }
    _pendingDetail = AddScheduleDetail(
      productName: productController.text.trim(),
      cropId: state.selectedPlot!.cropId,
      productType: selectedType,
      productQty: quantityController.text.trim(),
      unit: _normalizedUnit(selectedQuantityUnit),
      waterQty: waterController.text.trim(),
      waterUnit: _normalizedUnit(selectedWaterUnit),
      remark: remarkController.text.trim(),
    );
    context.read<FarmerScheduleBloc>().add(
      AddScheduleLine(
        productName: productController.text,

        type: selectedType,

        quantity: quantityController.text,

        quantityUnit: selectedQuantityUnit,

        water: waterController.text,

        waterUnit: selectedWaterUnit,

        remark: remarkController.text,
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate(FarmerScheduleState state) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,

      initialDate: state.selectedDate ?? now,

      firstDate: DateTime(now.year, now.month, now.day),

      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (picked != null && mounted) {
      context.read<FarmerScheduleBloc>().add(ScheduleDateChanged(picked));
    }
  }

  // ============================================================
  // COMPACT SCHEDULE LIST
  // ============================================================

  // Extracts values only when the schedule text explicitly includes labels.
  // Unlabelled schedule text is retained verbatim instead of guessing fields.
  Map<String, String> _parseScheduleFields(String schedule) {
    final result = <String, String>{};
    final labels = <String, String>{
      'product': 'Product',
      'product name': 'Product',
      'type': 'Type',
      'quantity': 'Quantity',
      'water': 'Water',
      'remark': 'Remark',
      'remarks': 'Remark',
    };

    final regex = RegExp(
      r'(product name|product|type|quantity|water|remarks|remark)\s*[:：-]\s*',
      caseSensitive: false,
    );
    final matches = regex.allMatches(schedule).toList();
    if (matches.isEmpty) return result;

    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final nextStart = i + 1 < matches.length
          ? matches[i + 1].start
          : schedule.length;
      final key = labels[match.group(1)!.toLowerCase()]!;
      final value = schedule.substring(match.end, nextStart).trim();
      if (value.isNotEmpty) result[key] = value;
    }
    return result;
  }

  Widget _scheduleDetail({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.065),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleContent(String schedule) {
    final fields = _parseScheduleFields(schedule);
    if (fields.isEmpty) {
      // Preserve unknown BLoC string formats without mislabelling values.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCHEDULE DETAILS',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: context.secondaryTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            schedule,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.5,
              color: context.primaryTextColor,
            ),
          ),
        ],
      );
    }

    Widget field(String label, IconData icon, Color color) {
      return _scheduleDetail(
        label: label,
        value: fields[label] ?? '-',
        icon: icon,
        color: color,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fields.containsKey('Product')) ...[
          field(
            'Product',
            Icons.inventory_2_outlined,
            context.appColors.secondary,
          ),
          SizedBox(height: 6.h),
        ],
        if (fields.containsKey('Type')) ...[
          field('Type', Icons.spa_outlined, context.primaryColor),
          SizedBox(height: 6.h),
        ],
        if (fields.containsKey('Quantity') || fields.containsKey('Water'))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fields.containsKey('Quantity'))
                Expanded(
                  child: field(
                    'Quantity',
                    Icons.scale_outlined,
                    context.appColors.tertiary,
                  ),
                ),
              if (fields.containsKey('Quantity') && fields.containsKey('Water'))
                SizedBox(width: 7.w),
              if (fields.containsKey('Water'))
                Expanded(
                  child: field(
                    'Water',
                    Icons.water_drop_outlined,
                    context.appColors.secondary,
                  ),
                ),
            ],
          ),
        if (fields.containsKey('Remark')) ...[
          SizedBox(height: 6.h),
          field('Remark', Icons.notes_rounded, context.secondaryTextColor),
        ],
      ],
    );
  }

  Widget _buildScheduleList(FarmerScheduleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_rounded, color: context.primaryColor, size: 22),
            SizedBox(width: 8.w),
            Text(
              'Schedule List',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _themeTint,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${state.schedules.length}',
                style: TextStyle(
                  color: context.primaryColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        ...List.generate(state.schedules.length, (index) {
          final item = state.schedules[index];

          // Read labeled fields from existing schedule string.
          final fields = _parseScheduleFields(item.schedule);

          final product = fields['Product'] ?? '';
          final type = fields['Type'] ?? '';
          final quantity = fields['Quantity'] ?? '';
          final water = fields['Water'] ?? '';
          final remark = fields['Remark'] ?? '';

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: context.borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CROP HEADER
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: _themeTint,
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Icon(
                        Icons.spa_outlined,
                        color: context.primaryColor,
                        size: 19,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.cropName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: context.primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: context.borderColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.date,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: context.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: context.appColors.error,
                        size: 20,
                      ),
                      onPressed: _submittingSchedule || _scheduleSubmitted
                          ? null
                          : () {
                              if (index < _savedSections.length)
                                _savedSections.removeAt(index);
                              context.read<FarmerScheduleBloc>().add(
                                RemoveScheduleSection(index),
                              );
                            },
                    ),
                  ],
                ),

                SizedBox(height: 9.h),

                Divider(color: context.borderColor, height: 1),

                SizedBox(height: 10.h),

                if (product.isNotEmpty ||
                    quantity.isNotEmpty ||
                    water.isNotEmpty) ...[
                  // PRODUCT + TYPE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRODUCT',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: context.secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              product.isEmpty ? '-' : product,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: context.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (type.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _themeTint,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: context.primaryColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // QUANTITY + WATER
                  Row(
                    children: [
                      Expanded(
                        child: _lightScheduleBox(
                          label: 'QUANTITY',
                          value: quantity.isEmpty ? '-' : quantity,
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Expanded(
                        child: _lightScheduleBox(
                          label: 'WATER',
                          value: water.isEmpty ? '-' : water,
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),

                  if (remark.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          color: context.secondaryTextColor,
                          size: 14,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            'Remark: $remark',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: context.secondaryTextColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else
                  // Fallback for older/unlabeled schedule data
                  Text(
                    item.schedule,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 11.sp,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _lightScheduleBox({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11.sp, color: context.secondaryTextColor),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 7.h),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: context.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WHATSAPP BUTTON
  // ============================================================

  Widget _buildScheduleActions(FarmerScheduleState state) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: Size(0, 48),
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
              ),
              onPressed: _submittingSchedule || _scheduleSubmitted
                  ? null
                  : () => _submitSchedule(state),
              icon: Icon(Icons.check_circle_outline, size: 18),
              label: Text('Submit'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, 48),
                foregroundColor: context.primaryColor,
              ),
              onPressed: () => _shareToWhatsApp(state),
              icon: Icon(Icons.chat_outlined, size: 18),
              label: Text('WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateSchedule(FarmerScheduleState state) {
    String? error;
    if (state.selectedFarmer == null) {
      error = 'Please select a farmer.';
    } else if (!state.selectedFarmer!.hasRegisteredPlots) {
      error = 'Please register a plot first.';
    } else if (state.plotLoading) {
      error = 'Please wait for plots to load.';
    } else if (state.selectedPlot == null ||
        !state.plots.any(
          (plot) =>
              plot.plotId == state.selectedPlot!.plotId &&
              plot.farmerId == state.selectedFarmer!.farmerId,
        )) {
      error = 'Please select a registered plot.';
    } else if (state.currentSchedule.trim().isNotEmpty ||
        productController.text.trim().isNotEmpty ||
        quantityController.text.trim().isNotEmpty ||
        waterController.text.trim().isNotEmpty ||
        remarkController.text.trim().isNotEmpty ||
        state.selectedDate != null) {
      error = 'Finish adding the current crop schedule before continuing.';
    } else if (state.schedules.isEmpty) {
      error = 'Please add at least one crop schedule.';
    }
    if (error != null) {
      _showMessage(error);
      return false;
    }
    return true;
  }

  Future<void> _submitSchedule(FarmerScheduleState state) async {
    if (_submittingSchedule || _scheduleSubmitted || !_validateSchedule(state))
      return;
    if (_currentDetails.isNotEmpty) {
      _showMessage('Finish Add Crop Schedule before submitting.');
      return;
    }
    if (_employeeLoading || _employeeId.isEmpty || _employeeId == '0') {
      _showMessage('Please log in again.');
      return;
    }
    if (_pendingDetail != null || _pendingSectionDetails != null) {
      _showMessage('Please wait for the current schedule to finish saving.');
      return;
    }
    if (_savedSections.length != state.schedules.length ||
        _savedSections.isEmpty) {
      _showMessage(
        'Schedule details are incomplete. Please re-add the schedule entries.',
      );
      return;
    }
    final date = _savedSections.first.date;
    final sameDate = _savedSections.every(
      (entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day,
    );
    if (!sameDate) {
      _showMessage(
        'One submission supports one schedule date. Please submit different dates separately.',
      );
      return;
    }
    final details = _savedSections.expand((entry) => entry.details).toList();
    final request = AddScheduleRequest(
      empId: _employeeId,
      plotId: state.selectedPlot!.plotId,
      farmerId: state.selectedFarmer!.farmerId,
      scheduleDate: date,
      details: List.unmodifiable(details),
    );
    final body = request.toJson();
    debugPrint('ADD SCHEDULE POST PARAMETERS');
    debugPrint('empId: ${body['empId']}');
    debugPrint('plotId: ${body['plotId']}');
    debugPrint('farmerId: ${body['farmerId']}');
    debugPrint('scheduleDate: ${body['scheduleDate']}');
    debugPrint('details: ${jsonEncode(body['details'])}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Submit schedule?'),
        content: Text(
          'Farmer: ${state.selectedFarmer!.farmerName}\nPlot: ${state.selectedPlot!.plotName}\nDate: ${body['scheduleDate']}\nProducts: ${details.length}\n\nPlease confirm. The schedule will be sent to the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Submit'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _submitBloc.add(SendAddSchedule(request));
  }

  Future<void> _shareToWhatsApp(FarmerScheduleState state) async {
    if (!_validateSchedule(state)) return;
    final ScheduleFarmerEntity? farmer = state.selectedFarmer;

    if (farmer == null) {
      _showMessage('Please select farmer.');
      return;
    }

    if (state.schedules.isEmpty) {
      _showMessage('Please add schedule.');
      return;
    }

    String phone = farmer.mobileNo.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      _showMessage('Farmer mobile number not available.');
      return;
    }

    if (phone.length == 10) {
      phone = '91$phone';
    }

    if (phone.length == 11 && phone.startsWith('0')) {
      phone = '91${phone.substring(1)}';
    }

    final StringBuffer builder = StringBuffer();

    builder.writeln(farmer.farmerName);

    builder.writeln();

    for (final item in state.schedules) {
      builder.writeln('*${item.title}*');

      builder.writeln(item.schedule);

      builder.writeln();

      builder.writeln('-------------------------------------');

      builder.writeln();
    }

    final String message = builder.toString().trim();

    print('WHATSAPP PHONE : $phone');

    print('WHATSAPP MESSAGE : $message');

    final Uri url = Uri.parse(
      'https://wa.me/$phone'
      '?text=${Uri.encodeComponent(message)}',
    );

    try {
      final bool opened = await launchUrl(
        url,

        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage('Unable to open WhatsApp.');
      }
    } catch (e) {
      print('WHATSAPP ERROR : $e');

      if (mounted) {
        _showMessage('Unable to open WhatsApp.');
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _card({required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(padding: EdgeInsets.all(12.w), child: child),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _title(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 36.w,

          height: 36.w,

          decoration: BoxDecoration(
            color: _themeTint,

            borderRadius: BorderRadius.circular(10.r),
          ),

          child: Icon(icon, size: 19.sp, color: context.primaryColor),
        ),

        SizedBox(width: 9.w),

        Text(
          title,

          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final requiredField = [
      'Search Farmer Name',
      'Search Crop Name',
      'Product Name',
      'Quantity',
      'Water',
    ].contains(hint);
    final displayLabel = requiredField ? '$hint *' : hint;
    return InputDecoration(
      hintText: displayLabel,
      labelText:
          ['Product Name', 'Quantity', 'Water', 'Enter Remark'].contains(hint)
          ? displayLabel
          : (requiredField ? displayLabel : null),
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      hintStyle: TextStyle(
        fontSize: 11.5.sp,
        color: context.secondaryTextColor,
      ),

      prefixIcon: Icon(icon, size: 19.sp, color: context.secondaryTextColor),

      isDense: true,

      filled: true,

      fillColor: context.appColors.surfaceContainerLow,

      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),

        borderSide: BorderSide(color: context.borderColor),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),

        borderSide: BorderSide(color: context.borderColor),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),

        borderSide: BorderSide(color: context.primaryColor, width: 1.3),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,

      isExpanded: true,

      decoration: InputDecoration(
        labelText: label,
        isDense: true,

        filled: true,

        fillColor: context.appColors.surfaceContainerLow,

        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(11.r)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),

          borderSide: BorderSide(color: context.borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.r),

          borderSide: BorderSide(color: context.primaryColor),
        ),
      ),

      items: values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,

              child: Text(
                item,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(fontSize: 11.sp),
              ),
            ),
          )
          .toList(),

      onChanged: onChanged,
    );
  }
}

class _SavedScheduleSection {
  final DateTime date;
  final List<AddScheduleDetail> details;
  const _SavedScheduleSection({required this.date, required this.details});
}
