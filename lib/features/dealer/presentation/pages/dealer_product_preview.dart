import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/appdialog.dart';
import 'package:solufine/core/utility/location_util.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_button.dart';

import 'package:solufine/features/dealer/data/models/dealer_products.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_state.dart';
import 'package:solufine/features/place_order/domain/entities/dealer_entity.dart';

class DealerProductPreviewPage extends StatefulWidget {
  final DealerEntity dealer;

  final List<DealerStockProductModel> products;

  /// key = productDetailsId
  /// value = entered quantity
  final Map<String, int> productQuantities;

  const DealerProductPreviewPage({
    super.key,
    required this.dealer,
    required this.products,
    required this.productQuantities,
  });

  @override
  State<DealerProductPreviewPage> createState() =>
      _DealerProductPreviewPageState();
}

class _DealerProductPreviewPageState extends State<DealerProductPreviewPage> {
  String userId = '';

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final ScrollController productScrollController = ScrollController();

  final TextEditingController remarkController = TextEditingController();

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // ===========================================================================
  // CAMERA
  // ===========================================================================

  final ImagePicker _imagePicker = ImagePicker();

  String? dealerImagePath;

  // ===========================================================================
  // LOCATION
  // ===========================================================================

  String address = '';

  // ===========================================================================
  // SUBMIT STATE
  // ===========================================================================

  bool isLoading = false;

  bool _submissionSent = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadUserId();
  }

  // ===========================================================================
  // TOTAL QUANTITY
  // ===========================================================================

  int get totalQuantity {
    int total = 0;

    for (final product in widget.products) {
      final String key = product.productDetailsId;

      total += widget.productQuantities[key] ?? 0;
    }

    return total;
  }

  // ===========================================================================
  // USER ID
  // ===========================================================================

  Future<void> _loadUserId() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      if (!mounted) {
        return;
      }

      setState(() {
        userId = userData?['user_id']?.toString() ?? '';
      });

      debugPrint('USER ID: $userId');
    } catch (e) {
      debugPrint('LOAD USER ID ERROR: $e');
    }
  }

  // ===========================================================================
  // CAMERA IMAGE
  // ===========================================================================

  Future<void> _captureDealerImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        dealerImagePath = image.path;
      });

      debugPrint('DEALER IMAGE: ${image.path}');
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Unable to open camera');
    }
  }

  // ===========================================================================
  // REMOVE IMAGE
  // ===========================================================================

  void _removeImage() {
    setState(() {
      dealerImagePath = null;
    });
  }

  // ===========================================================================
  // GEO ADDRESS
  // ===========================================================================

  Future<void> getGeoAddress() async {
    try {
      final position = await LocationUtil.instance.getCurrentLocation();

      if (position == null) {
        debugPrint('LOCATION NOT AVAILABLE');

        return;
      }

      address = await LocationUtil.instance.getAddress(
        position.latitude,
        position.longitude,
      );

      debugPrint('GEO ADDRESS: $address');
    } catch (e) {
      debugPrint('GET GEO ADDRESS ERROR: $e');

      // Do not stop stock submission
      // if address fails.
      address = '';
    }
  }

  // ===========================================================================
  // CLEAR SIGNATURE
  // ===========================================================================

  void _clearSignature() {
    signatureController.clear();

    setState(() {});
  }

  // ===========================================================================
  // SUBMIT STOCK
  // ===========================================================================

  Future<void> _submitStock() async {
    // Prevent double click
    if (isLoading) {
      return;
    }

    // =======================================================================
    // 1. DEALER VALIDATION
    // =======================================================================

    final String dealerId = widget.dealer.id.toString().trim();

    if (dealerId.isEmpty) {
      _showMessage('Dealer ID not found');

      return;
    }

    // =======================================================================
    // 2. USER VALIDATION
    // =======================================================================

    if (userId.trim().isEmpty) {
      _showMessage('User ID not found');

      return;
    }

    // =======================================================================
    // 3. PRODUCTS
    // =======================================================================

    if (widget.products.isEmpty) {
      _showMessage('No selected products found');

      return;
    }

    // =======================================================================
    // 4. IMAGE
    // =======================================================================

    if (dealerImagePath == null || dealerImagePath!.trim().isEmpty) {
      _showMessage('Please capture dealer image');

      return;
    }

    // =======================================================================
    // 5. SIGNATURE
    // =======================================================================

    if (signatureController.isEmpty) {
      _showMessage('Please add dealer signature');

      return;
    }

    try {
      // =====================================================================
      // 6. PRODUCT JSON
      // =====================================================================

      final List<Map<String, dynamic>> productJsonList = [];

      for (final product in widget.products) {
        final int quantity =
            widget.productQuantities[product.productDetailsId] ?? 0;

        if (quantity <= 0) {
          continue;
        }

        productJsonList.add({
          'productDetailsId': product.productDetailsId,

          'qty': quantity.toString(),

          'packing': product.packing,

          'unitId': product.unitId,

          'unit': product.unit,

          'rateWithGst': product.rateWithGst,

          'unitsPerCase': product.unitsPerCase,

          'statewiseDetId': product.statewiseDetId,

          'productId': product.productId,

          'productName': product.productName,

          'orderQtyFlag': product.orderQtyFlag,
        });
      }

      // =====================================================================
      // 7. VALID PRODUCT
      // =====================================================================

      if (productJsonList.isEmpty) {
        _showMessage('No valid product quantity found');

        return;
      }

      // =====================================================================
      // 8. JSON STRING
      // =====================================================================

      final String jsonData = jsonEncode(productJsonList);

      // =====================================================================
      // 9. SIGNATURE BYTES
      // =====================================================================

      final Uint8List? signatureBytes = await signatureController.toPngBytes();

      if (signatureBytes == null || signatureBytes.isEmpty) {
        _showMessage('Unable to read dealer signature');

        return;
      }

      // =====================================================================
      // 10. SAVE SIGNATURE
      // =====================================================================

      final Directory tempDirectory = await getTemporaryDirectory();

      final String signaturePath =
          '${tempDirectory.path}/'
          'dealer_signature_'
          '${DateTime.now().millisecondsSinceEpoch}.png';

      final File signatureFile = File(signaturePath);

      await signatureFile.writeAsBytes(signatureBytes, flush: true);

      if (!await signatureFile.exists()) {
        _showMessage('Unable to save dealer signature');

        return;
      }

      // =====================================================================
      // 11. GEO ADDRESS
      // =====================================================================

      await getGeoAddress();

      if (!mounted) {
        return;
      }

      // =====================================================================
      // 12. DEALER IMAGE
      // =====================================================================

      final String dealerImage = dealerImagePath!.trim();

      // =====================================================================
      // 13. DEBUG
      // =====================================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('FINAL DEALER STOCK SUBMIT');
      debugPrint('========================================');

      debugPrint('Dealer ID      : $dealerId');

      debugPrint('User ID        : $userId');

      debugPrint('Dealer Image   : $dealerImage');

      debugPrint('Signature      : ${signatureFile.path}');

      debugPrint('Geo Address    : $address');

      debugPrint('Remark         : ${remarkController.text.trim()}');

      debugPrint('JSON DATA      : $jsonData');

      debugPrint('Product Count  : ${productJsonList.length}');

      debugPrint('========================================');

      // =====================================================================
      // 14. IMPORTANT
      //
      // Turn loader ON ONLY AFTER all local validation/file work succeeds.
      // =====================================================================

      setState(() {
        isLoading = true;

        _submissionSent = true;
      });

      // =====================================================================
      // 15. DISPATCH API EVENT
      // =====================================================================

      context.read<DealerListBloc>().add(
        AddDealerStock(
          dealerId: dealerId,

          userId: userId,

          geoAddress: address,

          dealerImage: dealerImage,

          jsonData: jsonData,

          digitalSignature: signatureFile.path,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('========================================');

      debugPrint('SUBMIT STOCK ERROR');

      debugPrint('ERROR: $e');

      debugPrint('STACK: $stackTrace');

      debugPrint('========================================');

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;

        _submissionSent = false;
      });

      _showMessage('Unable to submit stock');
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  Future<void> _showSuccessDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: Container(
            padding: EdgeInsets.all(20.w),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(20.r),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // =================================================
                // SUCCESS ICON
                // =================================================
                Container(
                  width: 72.w,
                  height: 72.w,

                  decoration: const BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),

                  alignment: Alignment.center,

                  child: Container(
                    width: 52.w,
                    height: 52.w,

                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.check_rounded,
                      size: 32.sp,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Stock Submitted',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'Dealer stock has been submitted successfully.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,

                  height: 45.h,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      if (mounted) {
                        context.go(AppRouter.home);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),

                    child: Text(
                      'OK',

                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    remarkController.dispose();
    signatureController.dispose();
    productScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: CustomAppBar(
        title: 'Stock Preview',
        showBackButton: true,
        onBackTap: () {
          Navigator.pop(context);
        },
      ),

      body: BlocConsumer<DealerListBloc, DealerListState>(
        // ===================================================================
        // LISTENER
        // ===================================================================
        listener: (context, state) async {
          debugPrint('========================================');

          debugPrint('DEALER PREVIEW STATE: ${state.status}');

          debugPrint('IS LOADING: $isLoading');

          debugPrint('SUBMISSION SENT: $_submissionSent');

          debugPrint('========================================');

          // Ignore unrelated DealerListBloc states.
          if (!_submissionSent) {
            return;
          }

          // ===============================================================
          // SUCCESS
          // ===============================================================

          if (state.status == DealerListStatus.addDealerStockSuccess) {
            debugPrint('DEALER STOCK SUCCESS RECEIVED');

            if (!mounted) {
              return;
            }

            setState(() {
              isLoading = false;

              _submissionSent = false;
            });

            await _showSuccessDialog();

            return;
          }

          // ===============================================================
          // FAILURE
          // ===============================================================

          if (state.status == DealerListStatus.failure) {
            debugPrint('DEALER STOCK FAILURE RECEIVED');

            if (!mounted) {
              return;
            }

            setState(() {
              isLoading = false;

              _submissionSent = false;
            });

            _showMessage(
              state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage!
                  : 'Submission failed',
            );
          }
        },

        // ===================================================================
        // BUILDER
        // ===================================================================
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 110.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =======================================================
                  // DEALER
                  // =======================================================
                  _buildDealerCard(),

                  SizedBox(height: 12.h),

                  // =======================================================
                  // SUMMARY
                  // =======================================================
                  _buildSummary(),

                  SizedBox(height: 10.h),

                  // =======================================================
                  // PRODUCT TITLE
                  // =======================================================
                  _buildSectionTitle(
                    icon: Icons.inventory_2_rounded,

                    title: 'Selected Products',

                    subtitle: '${widget.products.length} products selected',
                  ),

                  SizedBox(height: 8.h),

                  // =======================================================
                  // PRODUCTS
                  // =======================================================
                  Container(
                    width: double.infinity,

                    constraints: BoxConstraints(maxHeight: 280.h),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(14.r),

                      border: Border.all(color: const Color(0xFFE5EAE6)),
                    ),

                    child: widget.products.length <= 3
                        // =================================================
                        // SMALL PRODUCT LIST
                        // =================================================
                        ? Padding(
                            padding: EdgeInsets.all(8.w),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                for (
                                  int index = 0;
                                  index < widget.products.length;
                                  index++
                                ) ...[
                                  Builder(
                                    builder: (context) {
                                      final product = widget.products[index];

                                      final int quantity =
                                          widget.productQuantities[product
                                              .productDetailsId] ??
                                          0;

                                      return _buildProductCard(
                                        product,
                                        quantity,
                                        index,
                                      );
                                    },
                                  ),

                                  if (index < widget.products.length - 1)
                                    SizedBox(height: 7.h),
                                ],
                              ],
                            ),
                          )
                        // =================================================
                        // SCROLL PRODUCT LIST
                        // =================================================
                        : Scrollbar(
                            controller: productScrollController,

                            thumbVisibility: true,

                            child: ListView.separated(
                              controller: productScrollController,

                              padding: EdgeInsets.all(8.w),

                              physics: const BouncingScrollPhysics(),

                              itemCount: widget.products.length,

                              separatorBuilder: (_, __) {
                                return SizedBox(height: 7.h);
                              },

                              itemBuilder: (context, index) {
                                final product = widget.products[index];

                                final int quantity =
                                    widget.productQuantities[product
                                        .productDetailsId] ??
                                    0;

                                return _buildProductCard(
                                  product,
                                  quantity,
                                  index,
                                );
                              },
                            ),
                          ),
                  ),

                  SizedBox(height: 16.h),

                  // =======================================================
                  // PHOTO + SIGNATURE
                  // =======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ===================================================
                      // DEALER IMAGE
                      // ===================================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildSmallSectionTitle(
                              icon: Icons.camera_alt_rounded,

                              title: 'Dealer Image *',
                            ),

                            SizedBox(height: 6.h),

                            _buildCompactImageSection(),
                          ],
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // ===================================================
                      // SIGNATURE
                      // ===================================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildSmallSectionTitle(
                              icon: Icons.draw_rounded,

                              title: 'Signature *',
                            ),

                            SizedBox(height: 6.h),

                            _buildCompactSignatureSection(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),

        child: SizedBox(
          width: double.infinity,

          child: CustomButton(
            text: 'Submit Stock',

            onPressed: isLoading ? () {} : _submitStock,

            isLoading: isLoading,

            width: double.infinity,

            height: 52,

            borderRadius: 22,

            backgroundColor: const Color(0xFF087C3A),

            textColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(7.r),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14.sp, color: AppColors.primary),
        ),

        SizedBox(width: 6.w),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactImageSection() {
    return Container(
      width: double.infinity,
      height: 145.h,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE4EAE5)),
      ),

      clipBehavior: Clip.antiAlias,

      child: dealerImagePath != null && dealerImagePath!.isNotEmpty
          ? Stack(
              fit: StackFit.expand,
              children: [
                // ======================================================
                // IMAGE
                // ======================================================
                Image.file(File(dealerImagePath!), fit: BoxFit.cover),

                // ======================================================
                // DARK GRADIENT
                // ======================================================
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // ======================================================
                // CHANGE PHOTO
                // ======================================================
                Positioned(
                  left: 6.w,
                  bottom: 6.h,
                  child: InkWell(
                    onTap: _captureDealerImage,
                    borderRadius: BorderRadius.circular(7.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Retake',
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ======================================================
                // DELETE
                // ======================================================
                Positioned(
                  right: 6.w,
                  top: 6.h,
                  child: InkWell(
                    onTap: _removeImage,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          // ============================================================
          // EMPTY CAMERA
          // ============================================================
          : InkWell(
              onTap: _captureDealerImage,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,

                    decoration: const BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),

                    alignment: Alignment.center,

                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 7.h),

                  Text(
                    'Capture Photo',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    'Tap to open camera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCompactSignatureSection() {
    return Container(
      width: double.infinity,
      height: 145.h,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE4EAE5)),
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          // ============================================================
          // SIGNATURE PAD
          // ============================================================
          Expanded(
            child: Signature(
              controller: signatureController,
              backgroundColor: Colors.white,
            ),
          ),

          // ============================================================
          // BOTTOM
          // ============================================================
          Container(
            height: 32.h,

            padding: EdgeInsets.symmetric(horizontal: 7.w),

            decoration: const BoxDecoration(
              color: Color(0xFFF7F9F7),
              border: Border(top: BorderSide(color: Color(0xFFE7ECE8))),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.gesture_rounded,
                  size: 13.sp,
                  color: AppColors.textSecondary,
                ),

                SizedBox(width: 4.w),

                Expanded(
                  child: Text(
                    'Sign here',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                InkWell(
                  onTap: _clearSignature,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 13.sp,
                          color: Colors.redAccent,
                        ),

                        SizedBox(width: 2.w),

                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
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

  Widget _buildDealerCard() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(12.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14.r),

        border: Border.all(color: const Color(0xFFE5EAE6)),
      ),

      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,

            decoration: const BoxDecoration(
              color: AppColors.lightGreen,

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.storefront_rounded,

              color: AppColors.primary,

              size: 21.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Dealer',
                  style: TextStyle(
                    fontSize: 9.sp,

                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  widget.dealer.name,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 13.sp,

                    fontWeight: FontWeight.w800,

                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle_rounded,

            color: AppColors.primary,

            size: 20.sp,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUMMARY
  // ===========================================================================

  Widget _buildSummary() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

      decoration: BoxDecoration(
        color: AppColors.lightGreen,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),

      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              title: '${widget.products.length}',
              subtitle: 'Products',
              icon: Icons.inventory_2_outlined,
            ),
          ),

          Container(
            height: 32.h,
            width: 1,
            color: AppColors.primary.withOpacity(0.15),
          ),

          Expanded(
            child: _summaryItem(
              title: '$totalQuantity',
              subtitle: 'Total Qty',
              icon: Icons.numbers_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),

        SizedBox(width: 6.w),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),

            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // PRODUCT
  // ===========================================================================

  Widget _buildProductCard(
    DealerStockProductModel product,
    int quantity,
    int index,
  ) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(11.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(color: const Color(0xFFE5EAE6)),
      ),

      child: Row(
        children: [
          // NUMBER
          Container(
            width: 28.w,
            height: 28.w,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: AppColors.lightGreen,

              borderRadius: BorderRadius.circular(8.r),
            ),

            child: Text(
              '${index + 1}',

              style: TextStyle(
                color: AppColors.primary,

                fontSize: 10.sp,

                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          SizedBox(width: 9.w),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  product.productName,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 12.sp,

                    fontWeight: FontWeight.w800,

                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 5.h),

                Wrap(
                  spacing: 5.w,

                  runSpacing: 4.h,

                  children: [
                    _infoBadge('${product.packing} ${product.unit}'),

                    _infoBadge('${product.unitsPerCase} / Case'),

                    // if (product.rateWithGst.isNotEmpty)
                    //   _infoBadge('₹${product.rateWithGst}'),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // QUANTITY
          Container(
            constraints: BoxConstraints(minWidth: 52.w),

            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),

            decoration: BoxDecoration(
              color: AppColors.primary,

              borderRadius: BorderRadius.circular(9.r),
            ),

            child: Column(
              children: [
                Text(
                  'CASE',

                  style: TextStyle(
                    fontSize: 7.sp,

                    fontWeight: FontWeight.w600,

                    color: Colors.white.withOpacity(0.75),
                  ),
                ),

                Text(
                  '$quantity',

                  style: TextStyle(
                    fontSize: 14.sp,

                    fontWeight: FontWeight.w900,

                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),

      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F3),

        borderRadius: BorderRadius.circular(5.r),
      ),

      child: Text(
        text,

        style: TextStyle(
          fontSize: 8.5.sp,

          fontWeight: FontWeight.w600,

          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRemarkField() {
    return TextField(
      controller: remarkController,

      maxLines: 3,

      minLines: 2,

      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),

      decoration: InputDecoration(
        hintText: 'Enter remark...',

        hintStyle: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),

        filled: true,

        fillColor: Colors.white,

        contentPadding: EdgeInsets.all(12.w),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),

          borderSide: const BorderSide(color: Color(0xFFE5EAE6)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),

          borderSide: const BorderSide(color: Color(0xFFE5EAE6)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),

          borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 31.w,
          height: 31.w,

          decoration: BoxDecoration(
            color: AppColors.lightGreen,

            borderRadius: BorderRadius.circular(8.r),
          ),

          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: TextStyle(
                  fontSize: 12.sp,

                  fontWeight: FontWeight.w800,

                  color: AppColors.textPrimary,
                ),
              ),

              Text(
                subtitle,

                style: TextStyle(
                  fontSize: 9.sp,

                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
