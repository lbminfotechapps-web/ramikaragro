import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/features/salesreturn/domain/entities/product_entity.dart';
import 'package:solufine/features/salesreturn/domain/entities/product_rate_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  final Map<String, int> packingQuantities;

  final List<ProductRateEntity> selectedRates;

  final VoidCallback onAdd;

  final VoidCallback onAddMore;

  final VoidCallback onDelete;

  final void Function(ProductRateEntity rate, int quantity) onQuantityChanged;

  /// Delete only one selected packing
  final void Function(ProductRateEntity rate) onDeletePacking;

  const ProductCard({
    super.key,
    required this.product,
    required this.packingQuantities,
    required this.selectedRates,
    required this.onAdd,
    required this.onAddMore,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onDeletePacking,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRates = selectedRates.isNotEmpty;

    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(bottom: 6.h),

      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(12.r),

        border: Border.all(
          color: hasRates
              ? context.primaryColor.withValues(alpha: 0.22)
              : context.borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: context.primaryColor,
                  size: 17.sp,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.listTitle.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Icon(
                          hasRates
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 11.sp,
                          color: hasRates
                              ? context.primaryColor
                              : context.secondaryTextColor,
                        ),

                        SizedBox(width: 3.w),

                        Flexible(
                          child: Text(
                            hasRates
                                ? '${selectedRates.length} packing${selectedRates.length == 1 ? '' : 's'} selected'
                                : 'Select packing / rate',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.badge.copyWith(
                              color: hasRates
                                  ? context.primaryColor
                                  : context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5.w),

              _buildCompactActionButton(context, hasRates: hasRates),

              SizedBox(width: 4.w),

              _buildDeleteButton(context, onTap: onDelete),
            ],
          ),

          if (hasRates) ...[
            SizedBox(height: 7.h),

            Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),

              decoration: BoxDecoration(
                color: context.backgroundColor,

                borderRadius: BorderRadius.circular(9.r),

                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.45),
                ),
              ),

              child: Column(
                children: [
                  for (
                    int index = 0;
                    index < selectedRates.length;
                    index++
                  ) ...[
                    _buildPackingRow(context, selectedRates[index]),

                    if (index < selectedRates.length - 1)
                      Divider(
                        height: 1,
                        color: context.borderColor.withValues(alpha: 0.35),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackingRow(BuildContext context, ProductRateEntity rate) {
    final String productDetailsId = rate.productDetailsId.toString();

    final int quantity = packingQuantities[productDetailsId] ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              color: context.primaryColor,
              size: 12.sp,
            ),
          ),

          SizedBox(width: 5.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PACKING + PRICE
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${rate.packing} ${rate.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 5.w),

                    Text(
                      '₹${rate.rateWithGst}',
                      style: AppTextStyles.badge.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.5.h,
                  ),

                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5.r),
                  ),

                  child: Text(
                    rate.displayCase,
                    style: AppTextStyles.helperText.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 5.w),

          _buildQuantityControl(context, rate: rate, quantity: quantity),

          SizedBox(width: 4.w),

          _buildDeletePackingButton(
            context,
            onTap: () {
              onDeletePacking(rate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(
    BuildContext context, {
    required ProductRateEntity rate,
    required int quantity,
  }) {
    return _ProductQuantityField(
      key: ValueKey('product_${product.id}_case_${rate.productDetailsId}'),

      quantity: quantity,

      onChanged: (enteredQuantity) {
        onQuantityChanged(rate, enteredQuantity);
      },
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context, {
    required bool hasRates,
  }) {
    return Material(
      color: hasRates
          ? context.primaryColor.withValues(alpha: 0.08)
          : context.primaryColor,

      borderRadius: BorderRadius.circular(8.r),

      child: InkWell(
        onTap: hasRates ? onAddMore : onAdd,

        borderRadius: BorderRadius.circular(8.r),

        child: Container(
          height: 30.h,

          padding: EdgeInsets.symmetric(horizontal: 8.w),

          alignment: Alignment.center,

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasRates ? Icons.add_circle_outline_rounded : Icons.add_rounded,

                size: 14.sp,

                color: hasRates ? context.primaryColor : context.onPrimaryColor,
              ),

              SizedBox(width: 3.w),

              Text(
                hasRates ? 'More' : 'Add',

                style: AppTextStyles.badge.copyWith(
                  color: hasRates
                      ? context.primaryColor
                      : context.onPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.appColors.error.withValues(alpha: 0.06),

      borderRadius: BorderRadius.circular(8.r),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(8.r),

        child: SizedBox(
          width: 30.w,
          height: 30.w,

          child: Icon(
            Icons.delete_outline_rounded,

            color: context.appColors.error,

            size: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDeletePackingButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.appColors.error.withValues(alpha: 0.07),

      borderRadius: BorderRadius.circular(7.r),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(7.r),

        child: SizedBox(
          width: 28.w,
          height: 28.h,

          child: Icon(
            Icons.close_rounded,

            color: context.appColors.error,

            size: 15.sp,
          ),
        ),
      ),
    );
  }
}

class _ProductQuantityField extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _ProductQuantityField({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  State<_ProductQuantityField> createState() => _ProductQuantityFieldState();
}

class _ProductQuantityFieldState extends State<_ProductQuantityField> {
  late final TextEditingController _controller;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.quantity > 0 ? widget.quantity.toString() : '',
    );

    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      return;
    }

    _syncController(widget.quantity);
  }

  @override
  void didUpdateWidget(covariant _ProductQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Quantity didn't change.
    if (oldWidget.quantity == widget.quantity) {
      return;
    }

    if (_focusNode.hasFocus) {
      return;
    }

    _syncController(widget.quantity);
  }

  void _syncController(int quantity) {
    final String newText = quantity > 0 ? quantity.toString() : '';

    if (_controller.text == newText) {
      return;
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);

    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95.w,
      height: 34.h,
      child: TextFormField(
        controller: _controller,

        focusNode: _focusNode,

        keyboardType: TextInputType.number,

        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

        textInputAction: TextInputAction.done,

        textAlign: TextAlign.center,

        style: AppTextStyles.input.copyWith(color: context.primaryTextColor),

        decoration: InputDecoration(
          hintText: 'Enter Case',

          hintStyle: AppTextStyles.inputHint.copyWith(
            color: context.secondaryTextColor,
          ),

          isDense: true,

          contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),

          filled: true,

          fillColor: context.appTheme.inputBackground,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(
              color: context.primaryColor.withValues(alpha: 0.18),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(color: context.primaryColor, width: 1.2),
          ),
        ),

        onChanged: (value) {
          final String cleanValue = value.trim();

          if (cleanValue.isEmpty) {
            widget.onChanged(0);
            return;
          }

          final int? quantity = int.tryParse(cleanValue);

          if (quantity == null) {
            return;
          }

          widget.onChanged(quantity);
        },

        onFieldSubmitted: (_) {
          _focusNode.unfocus();
        },

        onTapOutside: (_) {
          _focusNode.unfocus();
        },
      ),
    );
  }
}
