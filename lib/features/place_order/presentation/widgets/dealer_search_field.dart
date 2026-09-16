import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/dealer_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

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

        // Show dealer list ONLY when user is typing
        final bool showDealers =
            query.isNotEmpty &&
            dealers.isNotEmpty &&
            selectedDealer == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dealer',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type dealer name...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 19.sp,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 15.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Dealer result list
            if (showDealers) ...[
              SizedBox(height: 8.h),

              Container(
                constraints: BoxConstraints(
                  maxHeight: 260.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                    vertical: 6.h,
                  ),
                  itemCount: dealers.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      color: AppColors.border.withOpacity(0.6),
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
                                color: AppColors.lightGreen,
                                borderRadius:
                                    BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),

                            SizedBox(width: 11.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dealer.name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color:
                                          AppColors.textPrimary,
                                    ),
                                  ),

                                  if (dealer.mobile.isNotEmpty) ...[
                                    SizedBox(height: 3.h),
                                    Text(
                                      dealer.mobile,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color:
                                            AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Selected dealer
            if (selectedDealer != null) ...[
              SizedBox(height: 10.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(13.w),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 21.sp,
                      ),
                    ),

                    SizedBox(width: 11.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Dealer',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            selectedDealer!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (onClearSelected != null)
                      IconButton(
                        onPressed: onClearSelected,
                        icon: Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}