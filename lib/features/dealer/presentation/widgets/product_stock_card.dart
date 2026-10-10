import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/features/dealer/data/models/dealer_products.dart';
import 'package:solufine/features/place_order/domain/entities/product_entity.dart';
/*
class ProductStockCard extends StatelessWidget {
  final ProductEntity product;

  final int quantity;

  final VoidCallback onIncrease;

  final VoidCallback onDecrease;

  const ProductStockCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected =
        quantity > 0;

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 180,
      ),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius:
            BorderRadius.circular(17.r),
        border: Border.all(
          color: selected
              ? context.appPrimary
                  .withOpacity(0.35)
              : context.appBorder,
          width: selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.025),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // ===============================================================
          // LEFT PRODUCT INFORMATION
          // ===============================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,

                        /// Change to your actual field if needed.
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.2,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: context.appOnCard,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5.h),

                // CATEGORY
                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 3.h,
                  ),
                  decoration:
                      BoxDecoration(
                    color: context.appInputBackground,
                    borderRadius:
                        BorderRadius
                            .circular(
                                6.r),
                  ),
                  child: Text(
                    product.categoryName,

                    /// Change field name if required.
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          context.appPrimary,
                    ),
                  ),
                ),

                SizedBox(height: 11.h),

                // DETAILS
                Wrap(
                  spacing: 14.w,
                  runSpacing: 8.h,
                  children: [
                    _ProductInfoItem(
                      label:
                          'Unit/Case',
                      value: product
                          .unitPerCase
                          .toString(),
                    ),

                    _ProductInfoItem(
                      label: 'Unit',
                      value: product.unit
                          .toString(),
                    ),

                    _ProductInfoItem(
                      label:
                          'Pack Size',
                      value: product
                          .packagingSize
                          .toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // ===============================================================
          // QUANTITY
          // ===============================================================

          Column(
            children: [
              Text(
                'QTY',
                style: TextStyle(
                  fontSize: 9.sp,
                  letterSpacing: 0.5,
                  fontWeight:
                      FontWeight.w700,
                  color: context.appSubText,
                ),
              ),

              SizedBox(height: 5.h),

              Container(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 5.h,
                ),
                decoration:
                    BoxDecoration(
                  color: selected
                      ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
                      : context.appInputBackground,
                  borderRadius:
                      BorderRadius
                          .circular(12.r),
                  border: Border.all(
                    color: selected
                        ? context.appPrimary
                            .withOpacity(
                                0.18)
                        : context.appBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon:
                          Icons.remove,
                      enabled:
                          quantity > 0,
                      onTap:
                          onDecrease,
                    ),

                    SizedBox(
                      width: 35.w,
                      child: Text(
                        '$quantity',
                        textAlign:
                            TextAlign
                                .center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: selected
                              ? context.appPrimary
                              : context.appOnCard,
                        ),
                      ),
                    ),

                    _QuantityButton(
                      icon: Icons.add,
                      enabled: true,
                      onTap:
                          onIncrease,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProductInfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color:
                context.appSubText,
            fontWeight:
                FontWeight.w500,
          ),
        ),

        SizedBox(height: 2.h),

        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight:
                FontWeight.w700,
            color:
                context.appOnCard,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? context.appPrimary
          : context.appBorder,
      borderRadius:
          BorderRadius.circular(8.r),
      child: InkWell(
        onTap:
            enabled ? onTap : null,
        borderRadius:
            BorderRadius.circular(8.r),
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Icon(
            icon,
            size: 17.sp,
            color:
                context.appCard,
          ),
        ),
      ),
    );
  }
}

*/

class ProductStockCard extends StatefulWidget {
  final DealerStockProductModel product;

  final int quantity;

  final ValueChanged<int> onQuantityChanged;

  const ProductStockCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<ProductStockCard> createState() => _ProductStockCardState();
}

class _ProductStockCardState extends State<ProductStockCard> {
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();

    _quantityController = TextEditingController(
      text: widget.quantity > 0 ? widget.quantity.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant ProductStockCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep text field synced with parent state.
    if (oldWidget.quantity != widget.quantity) {
      final String newValue = widget.quantity > 0
          ? widget.quantity.toString()
          : '';

      if (_quantityController.text != newValue) {
        _quantityController.text = newValue;

        _quantityController.selection = TextSelection.collapsed(
          offset: newValue.length,
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.quantity > 0;

    final DealerStockProductModel product = widget.product;

    final String packingText = product.packing.trim().isEmpty
        ? '-'
        : product.packing;

    final String unitText = product.unit.trim().isEmpty ? '-' : product.unit;

    final String packSize = '${product.packing} ${product.unit}'.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),

      padding: EdgeInsets.all(12.w),

      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: selected
              ? context.appPrimary.withOpacity(0.35)
              : context.appBorder,
          width: selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ============================================================
          // PRODUCT INFORMATION
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------------
                // PRODUCT NAME
                // --------------------------------------------------------
                Text(
                  product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: context.appOnCard,
                  ),
                ),

                SizedBox(height: 5.h),

                // --------------------------------------------------------
                // PACKING BADGE
                // --------------------------------------------------------
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: context.appInputBackground,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    packSize.isEmpty ? 'No packing' : packSize,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: context.appPrimary,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // --------------------------------------------------------
                // PRODUCT INFO
                // --------------------------------------------------------
                Wrap(
                  spacing: 16.w,
                  runSpacing: 5.h,
                  children: [
                    _ProductInfoItem(
                      label: 'Unit/Case',
                      value: product.unitsPerCase.trim().isEmpty
                          ? '-'
                          : product.unitsPerCase,
                    ),

                    _ProductInfoItem(label: 'Unit', value: unitText),

                    _ProductInfoItem(
                      label: 'Pack Size',
                      value: '$packingText $unitText',
                    ),

                    // _ProductInfoItem(
                    //   label: 'Rate',
                    //   value: product.rateWithGst.trim().isEmpty
                    //       ? '-'
                    //       : '₹${product.rateWithGst}',
                    // ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CASE',
                style: TextStyle(
                  fontSize: 8.5.sp,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: context.appSubText,
                ),
              ),

              SizedBox(height: 5.h),
              Container(
                width: 76.w,
                height: 40.h,

                decoration: BoxDecoration(
                  color: selected
                      ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
                      : context.appInputBackground,

                  borderRadius: BorderRadius.circular(10.r),

                  border: Border.all(
                    color: selected
                        ? context.appPrimary
                        : context.appBorder,
                    width: selected ? 1.3 : 1,
                  ),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9.r),

                  child: TextField(
                    controller: _quantityController,

                    keyboardType: TextInputType.number,

                    textAlign: TextAlign.center,

                    maxLines: 1,

                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: context.appPrimary,
                    ),

                    decoration: InputDecoration(
                      hintText: '0',

                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: context.appSubText,
                      ),

                      filled: true,

                      fillColor: selected
                          ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
                          : context.appInputBackground,

                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,

                      isDense: true,

                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 5.w,
                      ),
                    ),

                    onChanged: (value) {
                      final int qty = int.tryParse(value.trim()) ?? 0;

                      debugPrint('PRODUCT ID: ${product.productId}');

                      debugPrint(
                        'PRODUCT DETAILS ID: ${product.productDetailsId}',
                      );

                      debugPrint('QUANTITY: $qty');

                      widget.onQuantityChanged(qty);
                    },
                  ),
                ),
              ),

              /*
              Container(
                width: 76.w,
                height: 40.h,

                decoration: BoxDecoration(
                  color: selected
                      ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
                      : context.appInputBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: selected
                        ? context.appPrimary.withOpacity(0.30)
                        : context.appBorder,
                  ),
                ),

                child: TextField(
                  controller: _quantityController,

                  keyboardType: TextInputType.number,

                  textAlign: TextAlign.center,

                  maxLines: 1,

                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: context.appPrimary,
                  ),

                  decoration: InputDecoration(
                    hintText: '0',

                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.appSubText,
                    ),

                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,

                    isDense: true,

                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 5.w,
                    ),
                  ),

                  onChanged: (value) {
                    final int qty = int.tryParse(value.trim()) ?? 0;

                    debugPrint('PRODUCT ID: ${product.productId}');

                    debugPrint(
                      'PRODUCT DETAILS ID: ${product.productDetailsId}',
                    );

                    debugPrint('QUANTITY: $qty');

                    widget.onQuantityChanged(qty);
                  },
                ),
              ),
              */
            ],
          ),
        ],
      ),
    );
  }
}

/*

class ProductStockCard extends StatelessWidget {
  final int quantity;

    final ValueChanged<int> onQuantityChanged;

  const ProductStockCard({
    super.key,
    required this.quantity,
    // required this.onIncrease,
        required this.onQuantityChanged,
    // required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: selected
              ? context.appPrimary.withOpacity(0.35)
              : context.appBorder,
          width: selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solufine Premium Fertilizer',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: context.appOnCard,
                  ),
                ),

                SizedBox(height: 6.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.appInputBackground,
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Text(
                    'Fertilizer',
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w600,
                      color: context.appPrimary,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                Wrap(
                  spacing: 18.w,
                  runSpacing: 8.h,
                  children: const [
                    _ProductInfoItem(
                      label: 'Unit/Case',
                      value: '20',
                    ),
                    _ProductInfoItem(
                      label: 'Unit',
                      value: 'KG',
                    ),
                    _ProductInfoItem(
                      label: 'Pack Size',
                      value: '50 KG',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          Column(
            children: [
              Text(
                'QTY',
                style: TextStyle(
                  fontSize: 9.sp,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: context.appSubText,
                ),
              ),

              SizedBox(height: 6.h),

              Container(
  width: 82.w,
  height: 42.h,
  padding: EdgeInsets.symmetric(
    horizontal: 10.w,
  ),
  decoration: BoxDecoration(
    color: selected
        ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
        : context.appInputBackground,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(
      color: selected
          ? context.appPrimary.withOpacity(0.30)
          : context.appBorder,
    ),
  ),
  child: TextField(
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    maxLines: 1,
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w800,
      color: context.appPrimary,
    ),
    decoration: InputDecoration(
      hintText: '0',
      hintStyle: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: context.appSubText,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        vertical: 11.h,
      ),
    ),
    onChanged: (value) {
      final int qty = int.tryParse(value) ?? 0;

      debugPrint('Quantity: $qty');

      // update quantity here
    },
  ),
),


/*
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard)
                      : context.appInputBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected
                        ? context.appPrimary.withOpacity(0.18)
                        : context.appBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      enabled: quantity > 0,
                      onTap: onDecrease,
                    ),

                    SizedBox(
                      width: 36.w,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? context.appPrimary
                              : context.appOnCard,
                        ),
                      ),
                    ),

                    _QuantityButton(
                      icon: Icons.add,
                      enabled: true,
                      onTap: onIncrease,
                    ),
                  ],
                ),
              ),

              */
            ],
          ),
        ],
      ),
    );
  }
}

*/

class _ProductInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProductInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: context.appSubText,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: context.appOnCard,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? context.appPrimary : context.appBorder,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Icon(icon, size: 17.sp, color: context.appOnPrimary),
        ),
      ),
    );
  }
}
