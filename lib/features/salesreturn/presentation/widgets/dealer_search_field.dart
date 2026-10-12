import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/features/salesreturn/domain/entities/dealer_entity.dart';

class DealerSearchField extends StatelessWidget {
  final TextEditingController controller;
  final List<DealerEntity> dealers;
  final DealerEntity? selectedDealer;

  final ValueChanged<String> onChanged;
  final ValueChanged<DealerEntity> onDealerSelected;
  final VoidCallback? onClearSelected;

  const DealerSearchField({
    super.key,
    required this.controller,
    required this.dealers,
    required this.onChanged,
    required this.onDealerSelected,
    this.selectedDealer,
    this.onClearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final query = value.text.trim();

        final bool showDealers =
            query.isNotEmpty && dealers.isNotEmpty && selectedDealer == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dealer *',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
            ),

            SizedBox(height: 8.h),

            TextField(
              controller: controller,
              onChanged: onChanged,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Type dealer name...',
                hintStyle: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 13.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.primaryColor,
                  size: 22.sp,
                ),

                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                          // Clear selected item also
                          onClearSelected?.call();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.secondaryTextColor,
                          size: 19.sp,
                        ),
                      )
                    : null,
                filled: true,

                fillColor: context.appTheme.inputBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 15.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: context.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            if (showDealers) ...[
              SizedBox(height: 8.h),

              Container(
                constraints: BoxConstraints(maxHeight: 260.h),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.shadow.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  itemCount: dealers.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      color: context.borderColor.withValues(alpha: 0.6),
                    );
                  },
                  itemBuilder: (context, index) {
                    final dealer = dealers[index];

                    return InkWell(
                      onTap: () {
                        onDealerSelected(dealer);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42.w,
                              height: 42.w,
                              decoration: BoxDecoration(
                                color: context.primaryColor.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: context.primaryColor,
                                size: 20.sp,
                              ),
                            ),

                            SizedBox(width: 11.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dealer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: context.primaryTextColor,
                                    ),
                                  ),

                                  if (dealer.mobile.isNotEmpty) ...[
                                    SizedBox(height: 3.h),
                                    Text(
                                      dealer.mobile,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: context.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.sp,
                              color: context.secondaryTextColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (selectedDealer != null) ...[SizedBox(height: 10.h)],
          ],
        );
      },
    );
  }
}
