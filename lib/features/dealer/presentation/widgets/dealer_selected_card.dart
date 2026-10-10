import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/features/place_order/domain/entities/dealer_entity.dart';

class DealerSelectorCard extends StatelessWidget {
  final TextEditingController controller;

  final List<DealerEntity> dealers;

  final DealerEntity? selectedDealer;

  final ValueChanged<String> onChanged;

  final ValueChanged<DealerEntity>
      onDealerSelected;

  final VoidCallback?
      onClearSelected;

  const DealerSelectorCard({
    super.key,
    required this.controller,
    required this.dealers,
    required this.onChanged,
    required this.onDealerSelected,
    required this.selectedDealer,
    required this.onClearSelected,
  });

  @override
  Widget build(BuildContext context) {
    // =======================================================================
    // DEALER ALREADY SELECTED
    // =======================================================================

    if (selectedDealer != null) {
      return Container(
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius:
              BorderRadius.circular(18.r),
          border: Border.all(
            color: context.appPrimary
                .withOpacity(0.18),
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
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration:
                  BoxDecoration(
                color:
                    Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                borderRadius:
                    BorderRadius.circular(
                        13.r),
              ),
              child: Icon(
                Icons
                    .storefront_rounded,
                color:
                    context.appPrimary,
                size: 22.sp,
              ),
            ),

            SizedBox(width: 11.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'DEALER',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 0.8,
                      color: context.appSubText,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    selectedDealer!.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          FontWeight.w800,
                      color: context.appOnCard,
                    ),
                  ),

                  if (selectedDealer!
                      .mobile
                      .isNotEmpty) ...[
                    SizedBox(
                        height: 2.h),
                    Text(
                      selectedDealer!
                          .mobile,
                      style:
                          TextStyle(
                        fontSize: 10.sp,
                        color: context.appSubText,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              width: 36.w,
              height: 36.w,
              decoration:
                  BoxDecoration(
                color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                borderRadius:
                    BorderRadius.circular(
                        10.r),
              ),
              child: IconButton(
                padding:
                    EdgeInsets.zero,
                onPressed:
                    onClearSelected,
                icon: Icon(
                  Icons.edit_rounded,
                  color:
                      context.appPrimary,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // =======================================================================
    // DEALER SEARCH
    // =======================================================================

    return ValueListenableBuilder<
        TextEditingValue>(
      valueListenable:
          controller,
      builder:
          (context, value, child) {
        final query =
            value.text.trim();

        final bool showDealers =
            query.isNotEmpty &&
                dealers.isNotEmpty;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons
                      .storefront_outlined,
                  size: 17.sp,
                  color:
                      context.appPrimary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Select Dealer',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                        FontWeight.w700,
                    color: context.appOnCard,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    color:
                        context.appError,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 7.h),

            Container(
              decoration:
                  BoxDecoration(
                color: context.appCard,
                borderRadius:
                    BorderRadius.circular(
                        14.r),
                border: Border.all(
                  color: context.appBorder,
                ),
              ),


              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search dealer name or mobile...',
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: context.appSubText,
                  ),

                  prefixIcon: Icon(
                    Icons.search,
                    color: context.appPrimary,
                    size: 20.sp,
                  ),

                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                          ),
                        )
                      : null,

                  helperText:
                      '    Search after 4 characters. After searching wait for 2 sec..!',
                  helperStyle: TextStyle(
                    fontSize: 9.sp,
                    color: context.appError,
                    fontWeight: FontWeight.w500,
                  ),
                  helperMaxLines: 1,

                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,

                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14.h,
                  ),
                ),
              ),


            ),

            if (showDealers) ...[
              SizedBox(height: 6.h),

              Container(
                constraints:
                    BoxConstraints(
                  maxHeight: 220.h,
                ),
                decoration:
                    BoxDecoration(
                  color: context.appCard,
                  borderRadius:
                      BorderRadius
                          .circular(
                              14.r),
                  border: Border.all(
                    color: context.appBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                              0.06),
                      blurRadius: 16,
                      offset:
                          const Offset(
                              0, 5),
                    ),
                  ],
                ),
                child:
                    ListView.separated(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets
                          .symmetric(
                    vertical: 5.h,
                  ),
                  itemCount:
                      dealers.length,
                  separatorBuilder:
                      (_, __) =>
                          Divider(
                    height: 1,
                    color:
                        context.appInputBackground,
                  ),
                  itemBuilder:
                      (context, index) {
                    final dealer =
                        dealers[index];

                    return InkWell(
                      onTap: () {
                        controller.text =
                            dealer.name;

                        controller
                                .selection =
                            TextSelection
                                .collapsed(
                          offset:
                              dealer
                                  .name
                                  .length,
                        );

                        onDealerSelected(
                          dealer,
                        );

                        FocusScope.of(
                                context)
                            .unfocus();
                      },
                      child: Padding(
                        padding:
                            EdgeInsets
                                .all(
                                    11.w),
                        child: Row(
                          children: [
                            Container(
                              width:
                                  39.w,
                              height:
                                  39.w,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            11.r),
                              ),
                              child:
                                  Icon(
                                Icons
                                    .storefront_rounded,
                                color:
                                    context.appPrimary,
                                size:
                                    19.sp,
                              ),
                            ),
                            SizedBox(
                                width:
                                    10.w),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    dealer
                                        .name,
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12.5.sp,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  if (dealer
                                      .mobile
                                      .isNotEmpty)
                                    Text(
                                      dealer
                                          .mobile,
                                      style:
                                          TextStyle(
                                        fontSize:
                                            10.5.sp,
                                        color:
                                            context.appSubText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons
                                  .arrow_forward_ios_rounded,
                              size:
                                  12.sp,
                              color: context.appSubText,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}