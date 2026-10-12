import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';

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
                        separatorBuilder: (_, __) => SizedBox(height: 8),
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
                    child: Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                style: TextStyle(
                  color: context.onPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                dealer.outletName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.onPrimaryColor.withValues(alpha: 0.78),
                  fontSize: 11,
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
      color: context.appTheme.inputBackground,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.borderColor),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.appColors.primaryContainer,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: context.appColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${item.visitCount} Visits',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
        Text(
          'No monthly data available',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
