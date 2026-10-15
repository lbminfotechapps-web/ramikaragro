import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import '../../domain/entities/pre_details.dart';
import '../../domain/entities/top_ten_dealer.dart';

void showMonthlyVisitDialog(BuildContext context, TopTenDealer dealer) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(dialogContext, dealer),

              Flexible(
                child: dealer.preDetails.isEmpty
                    ? _empty(context)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: dealer.preDetails.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _monthlyItem(
                            context,
                            dealer.preDetails[index],
                          );
                        },
                      ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: context.onPrimaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Close', style: AppTextStyles.labelLarge),
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

Widget _header(BuildContext context, TopTenDealer dealer) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.primaryColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.onPrimaryColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            color: context.onPrimaryColor,
          ),
        ),

        SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Visit Count',
                style: AppTextStyles.dialogTitle.copyWith(
                  color: context.onPrimaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                dealer.outletName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: context.onPrimaryColor.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close_rounded, color: context.onPrimaryColor),
        ),
      ],
    ),
  );
}

Widget _monthlyItem(BuildContext context, PreDetails item) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.appColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.borderColor),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            size: 19,
            color: context.primaryColor,
          ),
        ),

        SizedBox(width: 12),

        Expanded(
          child: Text(
            item.formattedDate,
            style: AppTextStyles.labelLarge.copyWith(
              color: context.cardTextColor,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${item.visitCount} Visits',
            style: AppTextStyles.labelSmall.copyWith(
              color: context.primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _empty(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(40),
    child: Column(
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 50,
          color: context.secondaryTextColor,
        ),
        SizedBox(height: 12),
        Text('No monthly data available', style: AppTextStyles.labelLarge),
      ],
    ),
  );
}
