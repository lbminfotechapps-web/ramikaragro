import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';


import '../../domain/entities/top_ten_dealer.dart';

class DealerCard extends StatelessWidget {
  final TopTenDealer dealer;
  final int index;
  final VoidCallback onTap;

  const DealerCard({
    super.key,
    required this.dealer,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildRank(context),

              SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dealer.outletName.isNotEmpty
                          ? dealer.outletName
                          : 'Unknown Dealer',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.cardTextColor,
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: context.secondaryTextColor,
                        ),

                        SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            dealer.outletAddress.isNotEmpty
                                ? dealer.outletAddress
                                : 'Address not available',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8),

              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dealer.visitCount,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardValue.copyWith(
                        color: context.primaryColor,
                      ),
                    ),

                    Text(
                      'visits',
                      style: AppTextStyles.caption.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRank(BuildContext context) {
    final rank = index + 1;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: rank == 1
            ? context.appColors.secondary.withValues(alpha: 0.12)
            : rank == 2
            ? context.appColors.surfaceContainerHighest
            : rank == 3
            ? context.appColors.secondary.withValues(alpha: 0.12)
            : context.appColors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTextStyles.label.copyWith(
            color: rank == 1
                ? context.appColors.secondary
                : context.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}
