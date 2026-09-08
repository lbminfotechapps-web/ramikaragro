import 'package:flutter/material.dart';

import '../../domain/entities/pre_details.dart';
import '../../domain/entities/top_ten_dealer.dart';

void showMonthlyVisitDialog(
  BuildContext context,
  TopTenDealer dealer,
) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 30,
        ),
        child: Container(
          constraints:
              const BoxConstraints(
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(
                dialogContext,
                dealer,
              ),

              Flexible(
                child: dealer.preDetails.isEmpty
                    ? _empty()
                    : ListView.separated(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        shrinkWrap: true,
                        itemCount:
                            dealer.preDetails.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 8,
                        ),
                        itemBuilder:
                            (context, index) {
                          return _monthlyItem(
                            dealer.preDetails[index],
                          );
                        },
                      ),
              ),

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2E7D32),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
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

Widget _header(
  BuildContext dialogContext,
  TopTenDealer dealer,
) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF2E7D32),
          Color(0xFF1B5E20),
        ],
      ),
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
            color:
                Colors.white.withOpacity(0.18),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Visit Count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dealer.outletName,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.78),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _monthlyItem(
  PreDetails item,
) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius:
          BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFEEF0F3),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            size: 19,
            color: Color(0xFF2E7D32),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            item.formattedDate,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color: Color(0xFF17202A),
            ),
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFE8F5E9),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            '${item.visitCount} Visits',
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _empty() {
  return const Padding(
    padding: EdgeInsets.all(40),
    child: Column(
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 50,
          color: Color(0xFFB0B7C3),
        ),
        SizedBox(height: 12),
        Text(
          'No monthly data available',
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}