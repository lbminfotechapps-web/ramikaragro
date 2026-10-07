import 'dart:io';
import 'dart:typed_data';

import 'package:solufine/core/utility/app_tutorial_service.dart';
import 'package:solufine/core/utility/widgets/tutorial_description.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:solufine/core/di/place_order_target_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';

import 'package:solufine/features/place_order/domain/entities/category_entity.dart';
import 'package:solufine/features/place_order/domain/entities/dealer_entity.dart';
import 'package:solufine/features/place_order/domain/entities/godown_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:solufine/features/place_order/domain/repositories/product_rate_repository.dart';
import 'package:solufine/features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';

import 'package:solufine/features/place_order/presentation/bloc/place_order_bloc.dart';
import 'package:solufine/features/place_order/presentation/bloc/place_order_event.dart';
import 'package:solufine/features/place_order/presentation/bloc/place_order_state.dart';

import 'package:solufine/features/place_order/presentation/widgets/dealer_search_field.dart';
import 'package:solufine/features/place_order/presentation/widgets/image_picker_section.dart';
import 'package:solufine/features/place_order/presentation/widgets/modern_dropdown.dart';
import 'package:solufine/features/place_order/presentation/widgets/multi_product_selection_sheet.dart';
import 'package:solufine/features/place_order/presentation/widgets/order_preview_sheet.dart';
import 'package:solufine/features/place_order/presentation/widgets/product_card.dart';
import 'package:solufine/features/place_order/presentation/widgets/signature_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  int? userId;
  bool isLoadingUser = true;
  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  Future<void> _loadUser() async {
    try {
      final storage = SecureStorage.instance;
      final userData = await storage.getUserData();

      if (userData == null) {
        if (!mounted) return;

        setState(() {
          userId = null;
          isLoadingUser = false;
        });

        return;
      }

      final id = int.tryParse(userData['user_id']?.toString() ?? '');

      if (!mounted) return;

      setState(() {
        userId = id;
        isLoadingUser = false;
      });
    } catch (e) {
      debugPrint('PlaceOrder user load error: $e');

      if (!mounted) return;

      setState(() {
        userId = null;
        isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (userId == null || userId! <= 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: const BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off_rounded,
                    size: 50.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'User information not found',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please login again and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) {
        return sl<PlaceOrderBloc>()..add(LoadPlaceOrderEvent(userId: userId!));
      },
      child: _PlaceOrderView(userId: userId!),
    );
  }
}

// =============================================================================
// PLACE ORDER VIEW
// =============================================================================

class _PlaceOrderView extends StatefulWidget {
  final int userId;

  const _PlaceOrderView({required this.userId});

  @override
  State<_PlaceOrderView> createState() => _PlaceOrderViewState();
}

class _PlaceOrderViewState extends State<_PlaceOrderView> {
  final GlobalKey _orderDealerKey = GlobalKey();
  final GlobalKey _orderGodownKey = GlobalKey();
  final GlobalKey _orderProductAddKey = GlobalKey();
  final GlobalKey _orderDetailsKey = GlobalKey();
  bool _orderTutorialPending = false;
  bool _orderSetupTutorialFinished = false;
  bool _orderProductsTutorialFinished = false;

  TargetFocus _orderTutorialTarget({
    required String id,
    required GlobalKey key,
    required String title,
    required String description,
    required bool isLast,
    ContentAlign align = ContentAlign.bottom,
  }) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      paddingFocus: 6,
      enableOverlayTab: false,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: align,
          child: TutorialDescription(
            step: 'Place Order',
            title: title,
            description: description,
            isLast: isLast,
          ),
        ),
      ],
    );
  }

  void _showOrderTutorialIfNeeded({required bool hasProducts}) {
    if (_orderTutorialPending || _orderProductsTutorialFinished) return;
    if (_orderSetupTutorialFinished && !hasProducts) return;
    _orderTutorialPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        final productStage = _orderSetupTutorialFinished;
        final keys = productStage
            ? [_orderProductAddKey, _orderDetailsKey]
            : [_orderDealerKey, _orderGodownKey];
        if (keys.any((key) => key.currentContext == null)) return;
        // The product button may be below the visible part of the page.
        await Scrollable.ensureVisible(
          keys.first.currentContext!,
          alignment: 0.1,
          duration: const Duration(milliseconds: 300),
        );
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted || keys.any((key) => key.currentContext == null)) return;
        final targets = productStage
            ? [
                _orderTutorialTarget(
                  id: 'order_product_add',
                  key: _orderProductAddKey,
                  title: 'Add a Product',
                  description:
                      'Tap Add to choose product packing and rates, then enter the quantity for your order. Use More to add another packing.',
                  isLast: false,
                ),
                _orderTutorialTarget(
                  id: 'order_details',
                  key: _orderDetailsKey,
                  title: 'Add Order Details',
                  description:
                      'Tap Add Details to attach an image and capture the signature before previewing your order.',
                  isLast: true,
                  align: ContentAlign.top,
                ),
              ]
            : [
                _orderTutorialTarget(
                  id: 'order_dealer',
                  key: _orderDealerKey,
                  title: 'Search for a Dealer',
                  description:
                      'Search for the dealer and select them from the results to place their order.',
                  isLast: false,
                ),
                _orderTutorialTarget(
                  id: 'order_godown',
                  key: _orderGodownKey,
                  title: 'Select a Godown',
                  description:
                      'Choose the godown that will supply the products for this order.',
                  isLast: true,
                ),
              ];
        final finished = await AppTutorialService.showPlaceOrderTutorial(
          context: context,
          targets: targets,
          productStage: productStage,
        );
        if (!mounted) return;
        if (finished) {
          setState(() {
            if (productStage) {
              _orderProductsTutorialFinished = true;
            } else {
              _orderSetupTutorialFinished = true;
            }
            _orderTutorialPending = false;
          });
        }
      } finally {
        _orderTutorialPending = false;
      }
    });
  }


  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController dealerController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  final TextEditingController productSearchController = TextEditingController();

  String productSearchText = '';

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  // ===========================================================================
  // SELECTED DATA
  // ===========================================================================

  DealerEntity? selectedDealer;

  GodownEntity? selectedGodown;

  /// IMPORTANT:
  /// Multiple categories are now supported.
  final List<CategoryEntity> selectedCategories = [];

  String? imagePath;

  Uint8List? signatureBytes;

  // ===========================================================================
  // ALL PRODUCTS FROM SELECTED CATEGORIES
  // ===========================================================================

  ///
  /// Therefore we keep our own accumulated list here.
  final List<ProductEntity> allCategoryProducts = [];

  void _loadAllProducts() {
    debugPrint('========================================');
    debugPrint('LOAD ALL PRODUCTS');
    debugPrint('CATEGORY ID = EMPTY');
    debugPrint('========================================');

    context.read<PlaceOrderBloc>().add(const GetProductsEvent(categoryId: ''));
  }

  // ===========================================================================
  // PRODUCT -> SELECTED RATES
  // ===========================================================================

  final Map<String, List<ProductRateEntity>> selectedRates = {};

  // ===========================================================================
  // RATE SHEET
  // ===========================================================================

  bool isOpeningRateSelector = false;

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  bool isShowingSuccessDialog = false;

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    AppTutorialService.dismissPlaceOrderTutorial();
    dealerController.dispose();
    remarkController.dispose();
    productSearchController.dispose();
    signatureController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // CLEAR PRODUCTS
  // ===========================================================================

  void _clearAllSelectedProducts() {
    final bloc = context.read<PlaceOrderBloc>();
    final currentState = bloc.state;

    for (final product in allCategoryProducts) {
      final String productId = product.id.toString();

      final Map<String, int> packingQuantities =
          currentState.packingQuantities[productId] ?? <String, int>{};

      final bool hasQuantity = packingQuantities.values.any(
        (quantity) => quantity > 0,
      );

      if (hasQuantity) {
        bloc.add(RemoveProductEvent(productId: product.id));
      }
    }

    if (mounted) {
      setState(() {
        selectedRates.clear();
        allCategoryProducts.clear();
      });
    } else {
      selectedRates.clear();
      allCategoryProducts.clear();
    }
  }

  // ===========================================================================
  // ADD PRODUCTS FROM CURRENT BLOC STATE
  // ===========================================================================

  void _mergeCurrentProducts(List<ProductEntity> products) {
    bool changed = false;

    for (final product in products) {
      final String productId = product.id.toString();

      final bool alreadyExists = allCategoryProducts.any(
        (element) => element.id.toString() == productId,
      );

      if (!alreadyExists) {
        allCategoryProducts.add(product);
        changed = true;
      }
    }

    if (changed && mounted) {
      setState(() {});
    }
  }

  List<ProductEntity> _getFilteredProducts() {
    final String search = productSearchText.trim().toLowerCase();

    // No search text means show all products.
    if (search.isEmpty) {
      return allCategoryProducts;
    }

    return allCategoryProducts.where((product) {
      final String productName = product.name.trim().toLowerCase();

      return productName.contains(search);
    }).toList();
  }

  // ===========================================================================
  // SEARCH DEALER
  // ===========================================================================

  void _searchDealer(String value) {
    final searchText = value.trim();

    if (searchText.isEmpty) {
      return;
    }

    context.read<PlaceOrderBloc>().add(
      SearchDealerEvent(userId: widget.userId, searchText: searchText),
    );
  }

  void _selectDealer(DealerEntity dealer) {
    _clearAllSelectedProducts();

    setState(() {
      selectedDealer = dealer;
      dealerController.text = dealer.name;
      selectedCategories.clear();
    });

    debugPrint('Dealer selected: ${dealer.id} - ${dealer.name}');

    // Reload all products because clear function removes them.
    _loadAllProducts();
  }

  void _clearDealer() {
    _clearAllSelectedProducts();

    setState(() {
      selectedDealer = null;
      dealerController.clear();
      selectedCategories.clear();
    });

    _loadAllProducts();
  }

  // ===========================================================================
  // SELECT GODOWN
  // ===========================================================================

  void _selectGodown(GodownEntity godown) {
    setState(() {
      selectedGodown = godown;
    });

    debugPrint('Godown selected: ${godown.id} - ${godown.name}');
  }

  // ===========================================================================
  // SELECT CATEGORY
  // ===========================================================================

  // ===========================================================================
  // REMOVE CATEGORY
  // ===========================================================================

  void _removeCategory(CategoryEntity category) {
    final String categoryId = category.id;

    debugPrint('Removing category: $categoryId - ${category.name}');

    setState(() {
      selectedCategories.removeWhere((element) => element.id == categoryId);
    });
  }

  // ===========================================================================
  // CATEGORY CHIPS
  // ===========================================================================

  Widget _buildSelectedCategoryChips() {
    if (selectedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Selected Categories',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: selectedCategories.map((category) {
              return Container(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 5.w,
                  top: 5.h,
                  bottom: 5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () {
                        _removeCategory(category);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchField() {
    return TextField(
      controller: productSearchController,

      onChanged: (value) {
        setState(() {
          productSearchText = value;
        });
      },

      decoration: InputDecoration(
        hintText: 'Search product...',

        prefixIcon: const Icon(Icons.search_rounded),

        suffixIcon: productSearchText.isNotEmpty
            ? IconButton(
                onPressed: () {
                  productSearchController.clear();

                  setState(() {
                    productSearchText = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),

        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildFixedBottomButtons(PlaceOrderState state) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,

        padding: EdgeInsets.fromLTRB(10.w, 9.h, 10.w, 9.h),

        decoration: BoxDecoration(
          color: Colors.white,

          border: Border(top: BorderSide(color: AppColors.border, width: 1)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),

        child: Row(
          children: [
            // =====================================================
            // ADD DETAILS
            // =====================================================
            Expanded(child: _buildAddDetailsButton()),

            SizedBox(width: 8.w),

            // =====================================================
            // PREVIEW
            // =====================================================
            Expanded(child: _buildPreviewButton(state)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CLEAR SIGNATURE
  // ===========================================================================

  // ===========================================================================
  // SIGNATURE CHANGED
  // ===========================================================================

  Future<void> _openAddDetailsDialog() async {
  String? validationMessage;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 20.h,
        ),
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            final bool hasImage =
                imagePath != null &&
                imagePath!.trim().isNotEmpty;

            final bool hasSignature =
                signatureBytes != null &&
                signatureBytes!.isNotEmpty;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 13.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius:
                                BorderRadius.circular(11.r),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: AppColors.primary,
                            size: 21.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Order Details',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Add photo, signature and remark',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                          },
                          borderRadius:
                              BorderRadius.circular(30.r),
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Flexible(
                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // VALIDATION MESSAGE
                          if (validationMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(10.r),
                                border: Border.all(
                                  color:
                                      Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color:
                                        Colors.red.shade700,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      validationMessage!,
                                      style: TextStyle(
                                        color:
                                            Colors.red.shade700,
                                        fontSize: 12.sp,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],

                          // STATUS
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 11.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen
                                  .withOpacity(0.45),
                              borderRadius:
                                  BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.primary
                                    .withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildDetailStatus(
                                  icon:
                                      Icons.photo_camera_rounded,
                                  title: 'Photo',
                                  completed: hasImage,
                                ),
                                Container(
                                  height: 26.h,
                                  width: 1,
                                  color: AppColors.border,
                                ),
                                _buildDetailStatus(
                                  icon: Icons.draw_rounded,
                                  title: 'Signature',
                                  completed: hasSignature,
                                ),
                                Container(
                                  height: 26.h,
                                  width: 1,
                                  color: AppColors.border,
                                ),
                                _buildDetailStatus(
                                  icon: Icons.notes_rounded,
                                  title: 'Remark',
                                  completed: remarkController
                                      .text
                                      .trim()
                                      .isNotEmpty,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 11.h),

                          // PHOTO
                          ImagePickerSection(
                            imagePath: imagePath,
                            onChanged: (path) {
                              imagePath = path;

                              dialogSetState(() {
                                validationMessage = null;
                              });

                              setState(() {});
                            },
                          ),

                          SizedBox(height: 10.h),

                          // SIGNATURE
                          SignatureSection(
                            controller:
                                signatureController,
                            onClear: () {
                              signatureController.clear();
                              signatureBytes = null;

                              dialogSetState(() {
                                validationMessage = null;
                              });

                              setState(() {});
                            },
                            onSignatureChanged: (bytes) {
                              signatureBytes = bytes;

                              dialogSetState(() {
                                validationMessage = null;
                              });

                              setState(() {});
                            },
                          ),

                          SizedBox(height: 10.h),

                          // REMARK
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(14.r),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            AppColors.lightGreen,
                                        borderRadius:
                                            BorderRadius.circular(
                                          9.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.notes_rounded,
                                        color:
                                            AppColors.primary,
                                        size: 17.sp,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Remark',
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        fontWeight:
                                            FontWeight.w800,
                                        color: AppColors
                                            .textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                TextField(
                                  controller:
                                      remarkController,
                                  maxLines: 3,
                                  minLines: 3,
                                  onChanged: (_) {
                                    dialogSetState(() {});
                                  },
                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Enter additional order remark...',
                                    filled: true,
                                    fillColor: const Color(
                                      0xFFFAFCFA,
                                    ),
                                    border:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        11.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BUTTONS
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      12.w,
                      10.h,
                      12.w,
                      12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20.r),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45.h,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        SizedBox(width: 9.w),
                        Expanded(
                          child: SizedBox(
                            height: 45.h,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (imagePath == null ||
                                    imagePath!
                                        .trim()
                                        .isEmpty) {
                                  dialogSetState(() {
                                    validationMessage =
                                        'Please add order photo';
                                  });
                                  return;
                                }

                                if (signatureBytes ==
                                        null ||
                                    signatureBytes!
                                        .isEmpty) {
                                  dialogSetState(() {
                                    validationMessage =
                                        'Please add dealer signature';
                                  });
                                  return;
                                }

                                dialogSetState(() {
                                  validationMessage = null;
                                });

                                setState(() {});

                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              icon: Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 18.sp,
                              ),
                              label: Text(
                                'Save Details',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary,
                                foregroundColor:
                                    Colors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    11.r,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}


  Widget _buildDetailStatus({
    required IconData icon,
    required String title,
    required bool completed,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 27.w,
            height: 27.w,
            decoration: BoxDecoration(
              color: completed ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Icon(
              completed ? Icons.check_rounded : icon,
              size: 14.sp,
              color: completed ? Colors.white : AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: completed ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDetailsButton() {
    final bool hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    final bool hasSignature =
        signatureBytes != null && signatureBytes!.isNotEmpty;

    final bool detailsAdded = hasImage && hasSignature;

    return SizedBox(
      height: 48.h,
      child: OutlinedButton(
        key: _orderDetailsKey,
        onPressed: _openAddDetailsDialog,
        style: OutlinedButton.styleFrom(
          backgroundColor: detailsAdded ? AppColors.lightGreen : Colors.white,
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: detailsAdded
                ? AppColors.primary.withOpacity(0.45)
                : AppColors.border,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              detailsAdded
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 18.sp,
            ),

            SizedBox(width: 6.w),

            Flexible(
              child: Text(
                detailsAdded ? 'Edit Details' : 'Add Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButton(PlaceOrderState state) {
    final bool isSubmitting = state.status == PlaceOrderStatus.submitting;

    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () {
                _submit(state);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        child: isSubmitting
            ? SizedBox(
                width: 19.w,
                height: 19.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_rounded, size: 18.sp),

                  SizedBox(width: 6.w),

                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===========================================================================
  // SAVE DIGITAL SIGNATURE
  // ===========================================================================

  Future<String?> _saveSignatureToFile() async {
    if (signatureBytes == null || signatureBytes!.isEmpty) {
      debugPrint('Digital signature bytes are empty');
      return null;
    }

    try {
      final Directory tempDirectory = await getTemporaryDirectory();

      final String fileName =
          'Signature_${DateTime.now().millisecondsSinceEpoch}.png';

      final String filePath = '${tempDirectory.path}/$fileName';

      final File signatureFile = File(filePath);

      await signatureFile.writeAsBytes(signatureBytes!, flush: true);

      final bool exists = await signatureFile.exists();

      if (!exists) {
        debugPrint('Digital signature file was not created');
        return null;
      }

      debugPrint('Digital signature saved: ${signatureFile.path}');

      return signatureFile.path;
    } catch (e, stackTrace) {
      debugPrint('Save digital signature error: $e');

      debugPrint('$stackTrace');

      return null;
    }
  }

  // ===========================================================================
  // OPEN MULTI PRODUCT RATE SELECTOR
  // ===========================================================================

  Future<void> _openMultiProductSelector({String? initialProductId}) async {
    if (selectedDealer == null) {
      _showMessage('Please select dealer first');
      return;
    }

    // if (selectedCategories.isEmpty) {
    //   _showMessage(
    //     'Please select at least one category',
    //   );
    //   return;
    // }

    if (isOpeningRateSelector) {
      return;
    }

    final List<ProductEntity> currentProducts = List<ProductEntity>.from(
      allCategoryProducts,
    );

    if (currentProducts.isEmpty) {
      _showMessage('No products available');
      return;
    }

    setState(() {
      isOpeningRateSelector = true;
    });

    try {
      final getRatesUseCase = GetProductDetailRatesUseCase(
        repository: sl<ProductRateRepository>(),
      );

      final bloc = context.read<PlaceOrderBloc>();

      final currentState = bloc.state;

      final MultiProductRateSelectionResult? result =
          await showModalBottomSheet<MultiProductRateSelectionResult>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.45),
            builder: (bottomSheetContext) {
              return MultiProductRateBottomSheet(
                products: currentProducts,
                dealerId: selectedDealer!.id.toString(),
                existingRates: {
                  for (final entry in selectedRates.entries)
                    entry.key: List<ProductRateEntity>.from(entry.value),
                },
                existingPackingQuantities: {
                  for (final entry in currentState.packingQuantities.entries)
                    entry.key: Map<String, int>.from(entry.value),
                },
                initialProductId: initialProductId,
                getRatesUseCase: getRatesUseCase,
              );
            },
          );

      if (result == null) {
        return;
      }

      await _processSelectedRates(result: result, products: currentProducts);
    } finally {
      if (mounted) {
        setState(() {
          isOpeningRateSelector = false;
        });
      }
    }
  }

  // ===========================================================================
  // PROCESS SELECTED RATES
  // ===========================================================================

  Future<void> _processSelectedRates({
    required MultiProductRateSelectionResult result,
    required List<ProductEntity> products,
  }) async {
    final bloc = context.read<PlaceOrderBloc>();

    final Map<String, List<ProductRateEntity>> returnedRates =
        result.selectedRates;

    final Map<String, Map<String, int>> returnedPackingQuantities =
        result.packingQuantities;

    // -------------------------------------------------------------------------
    // UPDATE PACKING QUANTITIES
    // -------------------------------------------------------------------------

    for (final entry in returnedPackingQuantities.entries) {
      final String productId = entry.key;

      for (final quantityEntry in entry.value.entries) {
        bloc.add(
          SetPackingQuantityEvent(
            productId: productId,
            productDetailsId: quantityEntry.key,
            quantity: quantityEntry.value,
          ),
        );
      }
    }

    // -------------------------------------------------------------------------
    // SAVE RATES
    // -------------------------------------------------------------------------

    for (final entry in returnedRates.entries) {
      final String productId = entry.key;

      final List<ProductRateEntity> rates = entry.value;

      ProductEntity? product;

      try {
        product = products.firstWhere(
          (element) => element.id.toString() == productId,
        );
      } catch (_) {
        product = null;
      }

      if (product == null) {
        debugPrint('Product not found for ID: $productId');
        continue;
      }

      if (rates.isEmpty) {
        selectedRates.remove(productId);

        bloc.add(RemoveProductEvent(productId: product.id));

        continue;
      }

      selectedRates[productId] = List<ProductRateEntity>.from(rates);

      final Map<String, int> productPackingQuantities =
          returnedPackingQuantities[productId] ?? <String, int>{};

      for (final rate in rates) {
        final String detailsId = rate.productDetailsId.toString();

        if (!productPackingQuantities.containsKey(detailsId)) {
          bloc.add(
            SetPackingQuantityEvent(
              productId: productId,
              productDetailsId: detailsId,
              quantity: 1,
            ),
          );
        }
      }

      final bool hasQuantity = rates.any((rate) {
        final String detailsId = rate.productDetailsId.toString();

        final int quantity = productPackingQuantities[detailsId] ?? 1;

        return quantity > 0;
      });

      if (hasQuantity) {
        bloc.add(AddProductEvent(product: product));
      }
    }

    // -------------------------------------------------------------------------
    // IMPORTANT:
    //
    // Do NOT remove products based only on returnedRates here.
    //
    // The selector can be opened while products from multiple categories
    // are already selected.
    // -------------------------------------------------------------------------

    if (mounted) {
      setState(() {});
    }

    debugPrint('========================================');
    debugPrint('FINAL SELECTED RATES');

    for (final entry in selectedRates.entries) {
      debugPrint(
        'Product ${entry.key} -> '
        '${entry.value.length} rate(s)',
      );
    }

    debugPrint('========================================');
  }

  // ===========================================================================
  // ADD PRODUCT
  // ===========================================================================

  Future<void> _addProduct(ProductEntity product) async {
    if (selectedDealer == null) {
      _showMessage('Please select dealer first');
      return;
    }

    await _openMultiProductSelector(initialProductId: product.id.toString());
  }

  // ===========================================================================
  // DELETE PRODUCT
  // ===========================================================================

  void _deleteProduct(ProductEntity product) {
    final String productId = product.id.toString();

    context.read<PlaceOrderBloc>().add(
      RemoveProductEvent(productId: product.id),
    );

    setState(() {
      selectedRates.remove(productId);
    });
  }

  void _deleteProductPacking({
    required ProductEntity product,
    required ProductRateEntity rate,
  }) {
    final String productId = product.id.toString();

    final String productDetailsId = rate.productDetailsId.toString();

    debugPrint(
      'DELETE PACKING => '
      'Product: $productId, '
      'Packing: $productDetailsId',
    );

    // ============================================================
    // GET CURRENT RATES OF PRODUCT
    // ============================================================

    final List<ProductRateEntity> currentRates = List<ProductRateEntity>.from(
      selectedRates[productId] ?? <ProductRateEntity>[],
    );

    // ============================================================
    // REMOVE ONLY SELECTED PACKING
    // ============================================================

    currentRates.removeWhere(
      (item) => item.productDetailsId.toString() == productDetailsId,
    );

    // ============================================================
    // SET ITS QUANTITY TO ZERO
    // ============================================================

    context.read<PlaceOrderBloc>().add(
      SetPackingQuantityEvent(
        productId: productId,
        productDetailsId: productDetailsId,
        quantity: 0,
      ),
    );

    // ============================================================
    // IF NO PACKING REMAINS
    // REMOVE COMPLETE PRODUCT
    // ============================================================

    if (currentRates.isEmpty) {
      selectedRates.remove(productId);

      context.read<PlaceOrderBloc>().add(
        RemoveProductEvent(productId: product.id),
      );
    } else {
      // SOME PACKINGS STILL REMAIN
      selectedRates[productId] = currentRates;
    }

    setState(() {});

    debugPrint(
      'Remaining packing count: '
      '${currentRates.length}',
    );
  }

  // ===========================================================================
  // GET SELECTED PRODUCTS
  // ===========================================================================

  List<ProductEntity> _getSelectedProducts(PlaceOrderState state) {
    return allCategoryProducts.where((product) {
      final String productId = product.id.toString();

      final Map<String, int> productPackingQuantities =
          state.packingQuantities[productId] ?? <String, int>{};

      final bool hasQuantity = productPackingQuantities.values.any(
        (quantity) => quantity > 0,
      );

      return hasQuantity &&
          selectedRates.containsKey(productId) &&
          selectedRates[productId]!.isNotEmpty;
    }).toList();
  }

  // ===========================================================================
  // SAFE GODOWN VALUE
  // ===========================================================================

  String? _getSafeGodownValue(List<GodownEntity> godowns) {
    if (selectedGodown == null) {
      return null;
    }

    final selectedId = selectedGodown!.id;

    final matchingIds = godowns
        .where((godown) => godown.id == selectedId)
        .map((godown) => godown.id)
        .toSet();

    if (matchingIds.length != 1) {
      return null;
    }

    return selectedId;
  }

  // ===========================================================================
  // CATEGORY DROPDOWN VALUE
  // ===========================================================================

  /// A normal DropdownButton cannot contain multiple values.
  ///
  /// Therefore this dropdown always has value = null after selecting a
  /// category. This allows the user to select another category.
  String? _getCategoryDropdownValue() {
    return null;
  }

  // ===========================================================================
  // UNIQUE GODOWN ITEMS
  // ===========================================================================

  List<DropdownMenuItem<String>> _buildGodownItems(List<GodownEntity> godowns) {
    final Map<String, GodownEntity> uniqueGodowns = {};

    for (final godown in godowns) {
      final id = godown.id.trim();

      if (id.isEmpty) {
        continue;
      }

      uniqueGodowns.putIfAbsent(id, () => godown);
    }

    return uniqueGodowns.values
        .map(
          (godown) => DropdownMenuItem<String>(
            value: godown.id,
            child: Text(
              godown.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // UNIQUE CATEGORY ITEMS
  // ===========================================================================

  List<DropdownMenuItem<String>> _buildCategoryItems(
    List<CategoryEntity> categories,
  ) {
    final Map<String, CategoryEntity> uniqueCategories = {};

    for (final category in categories) {
      final id = category.id.trim();

      if (id.isEmpty) {
        continue;
      }

      uniqueCategories.putIfAbsent(id, () => category);
    }

    return uniqueCategories.values
        .map(
          (category) => DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // CONFIRM ORDER
  // ===========================================================================

  Future<void> _confirmAndSubmitOrder({
    required List<Map<String, dynamic>> selectedProductPayload,
    required List<String> selectedImages,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
          title: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: AppColors.primary,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to submit this order?',
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedDealer?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.warehouse_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedGodown?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                  
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedImages.isNotEmpty
                                ? 'Order photo added'
                                : 'No order photo',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.draw_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            signatureBytes != null && signatureBytes!.isNotEmpty
                                ? 'Dealer signature added'
                                : 'Signature not added',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 44.h,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // =========================================================================
    // SAVE SIGNATURE BEFORE BLOC
    // =========================================================================

    final String? savedSignaturePath = await _saveSignatureToFile();

    if (!mounted) {
      return;
    }

    if (savedSignaturePath == null || savedSignaturePath.isEmpty) {
      _showMessage('Unable to save digital signature');
      return;
    }

    // =========================================================================
    // FINAL DEBUG BEFORE BLOC
    // =========================================================================

    debugPrint('========================================');
    debugPrint('FINAL SUBMIT TO BLOC');

    debugPrint(
      'Products count: '
      '${selectedProductPayload.length}',
    );

    for (final product in selectedProductPayload) {
      debugPrint('SUBMIT DATA: $product');
    }

    debugPrint(
      'Order Image: '
      '${selectedImages.isNotEmpty ? selectedImages.first : 'None'}',
    );

    debugPrint(
      'Digital Signature Path: '
      '$savedSignaturePath',
    );

    debugPrint(
      'Digital Signature Size: '
      '${signatureBytes?.length ?? 0} bytes',
    );

    debugPrint('========================================');

    // =========================================================================
    // SUBMIT
    // =========================================================================

    context.read<PlaceOrderBloc>().add(
      SubmitPlaceOrderEvent(
        userId: widget.userId,
        dealer: selectedDealer!,
        godown: selectedGodown!,
        products: selectedProductPayload,
        remark: remarkController.text.trim(),
        imagePaths: selectedImages,
        signaturePath: savedSignaturePath,
      ),
    );
  }

  // ===========================================================================
  // SUBMIT / PREVIEW
  // ===========================================================================

  Future<void> _submit(PlaceOrderState state) async {
    // -------------------------------------------------------------------------
    // DEALER
    // -------------------------------------------------------------------------

    if (selectedDealer == null) {
      _showMessage('Please select dealer');
      return;
    }

    // -------------------------------------------------------------------------
    // GODOWN
    // -------------------------------------------------------------------------

    if (selectedGodown == null) {
      _showMessage('Please select godown');
      return;
    }

    // -------------------------------------------------------------------------
    // PRODUCTS
    // -------------------------------------------------------------------------

    final List<ProductEntity> selectedProducts = _getSelectedProducts(state);

    if (selectedProducts.isEmpty) {
      _showMessage('Please add at least one product');
      return;
    }

    // -------------------------------------------------------------------------
    // RATE VALIDATION
    // -------------------------------------------------------------------------

    for (final product in selectedProducts) {
      final String productId = product.id.toString();

      final List<ProductRateEntity> productRates =
          selectedRates[productId] ?? <ProductRateEntity>[];

      if (productRates.isEmpty) {
        _showMessage('Please select rate for ${product.name}');
        return;
      }
    }

    // -------------------------------------------------------------------------
    // IMAGE
    // -------------------------------------------------------------------------

    if (imagePath == null || imagePath!.trim().isEmpty) {
      //_showMessage('Please add order photo');
      _showMessage('Please add details');
      return;
    }

    // -------------------------------------------------------------------------
    // SIGNATURE
    // -------------------------------------------------------------------------

    if (signatureBytes == null || signatureBytes!.isEmpty) {
      _showMessage('Please add dealer signature');
      return;
    }

    // -------------------------------------------------------------------------
    // BUILD PRODUCT PAYLOAD
    // -------------------------------------------------------------------------

    final List<Map<String, dynamic>> selectedProductPayload = [];

    for (final product in selectedProducts) {
      final String productId = product.id.toString();

      final List<ProductRateEntity> rates =
          selectedRates[productId] ?? <ProductRateEntity>[];

      final Map<String, int> productPackingQuantities =
          state.packingQuantities[productId] ?? <String, int>{};

      for (final selectedRate in rates) {
        final String productDetailsId = selectedRate.productDetailsId
            .toString();

        final int quantity = productPackingQuantities[productDetailsId] ?? 1;

        // Skip zero quantity lines if any exist.
        if (quantity <= 0) {
          continue;
        }

        final Map<String, dynamic> payload = {
          'productId': product.id,
          'productDetailsId': selectedRate.productDetailsId,
          'quantity': quantity,
          'price': selectedRate.rateWithGst,
          'packing': selectedRate.packing,
          'unit': selectedRate.unit,
          'unitsPerCase': selectedRate.unitsPerCase,
          'gstPercentage': selectedRate.gstPercentage,
          'basicRate': selectedRate.basicRate,
          'mrp': selectedRate.mrp,
        };

        selectedProductPayload.add(payload);
      }
    }

    // -------------------------------------------------------------------------
    // FINAL PRODUCT PAYLOAD VALIDATION
    // -------------------------------------------------------------------------

    if (selectedProductPayload.isEmpty) {
      _showMessage('Please select at least one product rate');
      return;
    }

    // -------------------------------------------------------------------------
    // OPTIONAL CATEGORY
    // -------------------------------------------------------------------------

    final CategoryEntity? previewCategory = selectedCategories.isNotEmpty
        ? selectedCategories.first
        : null;

    // -------------------------------------------------------------------------
    // DEBUG
    // -------------------------------------------------------------------------

    debugPrint('========================================');

    debugPrint('PLACE ORDER');

    debugPrint('Dealer ID: ${selectedDealer!.id}');

    debugPrint('Godown ID: ${selectedGodown!.id}');

    debugPrint('Category Count: ${selectedCategories.length}');

    if (selectedCategories.isEmpty) {
      debugPrint('No category selected');
    } else {
      for (final category in selectedCategories) {
        debugPrint('Category ID: ${category.id}');

        debugPrint('Category Name: ${category.name}');
      }
    }

    debugPrint('Products: ${selectedProducts.length}');

    debugPrint('Rate Lines: ${selectedProductPayload.length}');

    debugPrint('========================================');

    // -------------------------------------------------------------------------
    // PREVIEW
    // -------------------------------------------------------------------------

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),

      builder: (previewContext) {
        return OrderPreviewSheet(
          dealer: selectedDealer!,
          godown: selectedGodown!,

          // CATEGORY IS OPTIONAL
          // category: previewCategory,
          products: selectedProducts,

          selectedRates: selectedRates,

          packingQuantities: state.packingQuantities,

          imagePath: imagePath,

          signatureBytes: signatureBytes,

          remark: remarkController.text.trim(),

          onConfirm: () {
            Navigator.pop(previewContext);

            final List<String> selectedImages = imagePath == null
                ? <String>[]
                : <String>[imagePath!];

            _confirmAndSubmitOrder(
              selectedProductPayload: selectedProductPayload,
              selectedImages: selectedImages,
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  Future<void> _showOrderSuccessDialog() async {
    if (!mounted || isShowingSuccessDialog) {
      return;
    }

    isShowingSuccessDialog = true;

    final bool? goHome = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: EdgeInsets.all(9.w),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Order Placed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your order has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    isShowingSuccessDialog = false;

    if (goHome == true && mounted) {
      context.go(AppRouter.home);
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: CustomAppBar(
        title: 'Place Order',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: BlocConsumer<PlaceOrderBloc, PlaceOrderState>(
        listener: (context, state) {
          // =========================================================
          // MERGE PRODUCTS
          // =========================================================

          if (state.products.isNotEmpty) {
            _mergeCurrentProducts(state.products);
          }

          // =========================================================
          // SUCCESS
          // =========================================================

          if (state.status == PlaceOrderStatus.success) {
            _showOrderSuccessDialog();
            return;
          }

          // =========================================================
          // FAILURE
          // =========================================================

          if (state.status == PlaceOrderStatus.failure) {
            _showMessage(
              state.errorMessage.isEmpty
                  ? 'Something went wrong'
                  : state.errorMessage,
            );
          }
        },

        builder: (context, state) {
          // =========================================================
          // INITIAL LOADING
          // =========================================================

          if (state.status == PlaceOrderStatus.loading &&
              state.dealers.isEmpty &&
              state.godowns.isEmpty &&
              state.categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final String? safeGodownValue = _getSafeGodownValue(state.godowns);

          final List<ProductEntity> filteredProducts = _getFilteredProducts();

          if (state.status == PlaceOrderStatus.loaded) {
            _showOrderTutorialIfNeeded(hasProducts: filteredProducts.isNotEmpty);
          }

          final bool hasSelectedProducts = _getSelectedProducts(
            state,
          ).isNotEmpty;

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              // IMPORTANT:
              // bottom padding gives space above fixed buttons
              padding: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 18.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // DEALER
                  // =================================================
                  DealerSearchField(
                    key: _orderDealerKey,
                    controller: dealerController,
                    dealers: state.dealers,
                    selectedDealer: selectedDealer,
                    onChanged: _searchDealer,
                    onDealerSelected: _selectDealer,
                    onClearSelected: _clearDealer,
                  ),

                  SizedBox(height: 2.h),

                  // =================================================
                  // GODOWN
                  // =================================================
                  ModernDropdown<String>(
                    key: _orderGodownKey,
                    label: 'Godown *',
                    hint: 'Select godown',
                    icon: Icons.warehouse_rounded,
                    value: safeGodownValue,

                    items: _buildGodownItems(state.godowns),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      final matches = state.godowns
                          .where((element) => element.id == value)
                          .toList();

                      if (matches.length != 1) {
                        _showMessage('Invalid godown selection');
                        return;
                      }

                      _selectGodown(matches.first);
                    },
                  ),

                  // =================================================
                  // CATEGORY
                  // =================================================
                  if (selectedCategories.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    _buildSelectedCategoryChips(),
                  ],

                  SizedBox(height: 10.h),

                  // =================================================
                  // PRODUCT SECTION
                  // =================================================
                  Container(
                    padding: EdgeInsets.all(12.w),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // =============================================
                        // PRODUCT HEADER
                        // =============================================
                        Row(
                          children: [
                            Expanded(
                              child: _sectionTitle(
                                title: 'Products',

                                subtitle: selectedCategories.isEmpty
                                    ? '${allCategoryProducts.length} products'
                                    : '${allCategoryProducts.length} products • '
                                          '${selectedCategories.length} categories',

                                icon: Icons.inventory_2_rounded,
                              ),
                            ),

                            SizedBox(width: 5.w),
                     
                          ],
                        ),

                        SizedBox(height: 7.h),

                        // =============================================
                        // SEARCH
                        // =============================================
                        _buildProductSearchField(),

                        // =============================================
                        // SELECTED SUMMARY
                        // =============================================
                        if (hasSelectedProducts) ...[
                          SizedBox(height: 6.h),

                          _buildSelectedProductSummary(state),
                        ],

                        SizedBox(height: 7.h),

                        // =============================================
                        // PRODUCT LIST
                        // =============================================
                        if (state.status == PlaceOrderStatus.loading &&
                            allCategoryProducts.isEmpty)
                          _buildProductLoading()
                        else if (allCategoryProducts.isEmpty)
                          _emptyBox(
                            icon: Icons.inventory_2_outlined,
                            text: 'No products found',
                          )
                        else if (filteredProducts.isEmpty)
                          _emptyBox(
                            icon: Icons.search_off_rounded,
                            text: 'No matching products found',
                          )
                        else
                          ...filteredProducts.map((product) {
                            final String productId = product.id.toString();

                            final List<ProductRateEntity> productRates =
                                selectedRates[productId] ??
                                <ProductRateEntity>[];

                          
                                return ProductCard(
                                  addButtonKey: identical(product, filteredProducts.first)
                                      ? _orderProductAddKey
                                      : null,
                                  product: product,

                                  selectedRates: productRates,

                                  packingQuantities:
                                      state.packingQuantities[productId] ??
                                      <String, int>{},

                                  // ===========================================================
                                  // ADD PRODUCT
                                  // ===========================================================

                                  onAdd: () async {
                                    await _addProduct(product);
                                  },

                                  // ===========================================================
                                  // ADD MORE PACKING
                                  // ===========================================================

                                  onAddMore: () async {
                                    await _openMultiProductSelector(
                                      initialProductId: productId,
                                    );
                                  },

                                  // ===========================================================
                                  // NEW - DIRECT ENTER CASE QUANTITY
                                  // ===========================================================

                                  onQuantityChanged: (
                                    rate,
                                    quantity,
                                  ) {
                                    context.read<PlaceOrderBloc>().add(
                                      SetPackingQuantityEvent(
                                        productId:
                                            product.id.toString(),

                                        productDetailsId:
                                            rate.productDetailsId
                                                .toString(),

                                        quantity: quantity,
                                      ),
                                    );
                                  },

                                  // ===========================================================
                                  // DELETE PARTICULAR PACKING
                                  // ===========================================================

                                  onDeletePacking: (rate) {
                                    _deleteProductPacking(
                                      product: product,
                                      rate: rate,
                                    );
                                  },

                                  // ===========================================================
                                  // DELETE PRODUCT
                                  // ===========================================================

                                  onDelete: () {
                                    _deleteProduct(product);
                                  },
                                );
                                                            
                    



                          }),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // DO NOT PUT ADD DETAILS / PREVIEW HERE
                ],
              ),
            ),
          );
        },
      ),

      // ============================================================
      // FIXED BOTTOM BUTTONS
      // ============================================================
      bottomNavigationBar: BlocBuilder<PlaceOrderBloc, PlaceOrderState>(
        builder: (context, state) {
          return _buildFixedBottomButtons(state);
        },
      ),
    );
  }

  // ===========================================================================
  // SELECTED PRODUCT SUMMARY
  // ===========================================================================

  Widget _buildSelectedProductSummary(PlaceOrderState state) {
    final selectedProducts = _getSelectedProducts(state);

    if (selectedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalQuantity = 0;
    double totalAmount = 0.0;

    for (final product in selectedProducts) {
      final String productId = product.id.toString();

      final List<ProductRateEntity> rates =
          selectedRates[productId] ?? <ProductRateEntity>[];

      final Map<String, int> productPackingQuantities =
          state.packingQuantities[productId] ?? <String, int>{};

      for (final rate in rates) {
        final String detailsId = rate.productDetailsId.toString();

        final int quantity = productPackingQuantities[detailsId] ?? 1;

        totalQuantity += quantity;

        totalAmount += rate.amountForCases(quantity);
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 17.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedProducts.length} '
                  'product${selectedProducts.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                 
                  'Total quantity: $totalQuantity',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.shopping_cart_checkout_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Select dealer, products and order details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PRODUCT LOADING
  // ===========================================================================

  Widget _buildProductLoading() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _emptyBox({required String text, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25.sp, color: AppColors.primary),
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REMARK
  // ===========================================================================

  Widget _buildRemarkField() {
    return CustomTextFormField(
      controller: remarkController,
      hintText: 'Enter order remark...',
      prefixIcon: Icons.edit_note_rounded,
      suffixIcon: null,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      labelText: 'Enter order remark',
    );
  }

  // ===========================================================================
  // SUBMIT BUTTON
  // ===========================================================================

  Widget _buildSubmitButton(PlaceOrderState state) {
    final bool isSubmitting = state.status == PlaceOrderStatus.submitting;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submit(state),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: isSubmitting
            ? SizedBox(
                width: 23.w,
                height: 23.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout_rounded,
                    size: 19.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Preview Order',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
