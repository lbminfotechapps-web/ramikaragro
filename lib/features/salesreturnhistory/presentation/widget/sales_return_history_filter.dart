import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class SalesReturnHistoryFilter extends StatelessWidget {
  final TextEditingController dealerController;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;

  final String selectedStatus;

  final ValueChanged<String> onStatusChanged;

  final VoidCallback onFromDate;
  final VoidCallback onToDate;
  final VoidCallback onSearch;
  final VoidCallback onReset;
  final ValueChanged<String> onDealerChanged;

  final List<String> dealerSuggestions;
  final ValueChanged<String> onDealerSelected;

  const SalesReturnHistoryFilter({
    super.key,
    required this.dealerController,
    required this.fromDateController,
    required this.toDateController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onFromDate,
    required this.onToDate,
    required this.onSearch,
    required this.onReset,
    required this.onDealerChanged,
    required this.dealerSuggestions,
    required this.onDealerSelected,
  });

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (value) {
            if (dealerSuggestions.isEmpty) {
              return const Iterable<String>.empty();
            }

            return dealerSuggestions;
          },
          onSelected: onDealerSelected,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = dealerController.text;

            controller.addListener(() {
              if (dealerController.text != controller.text) {
                dealerController.text = controller.text;
              }
            });

            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onDealerChanged,
              decoration: _decoration('Dealer', Icons.store_outlined),
            );
          },
        ),

        SizedBox(height: 10.h),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: fromDateController,
                readOnly: true,
                onTap: onFromDate,
                decoration: _decoration(
                  'From Date',
                  Icons.calendar_today_outlined,
                ),
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: TextField(
                controller: toDateController,
                readOnly: true,
                onTap: onToDate,
                decoration: _decoration(
                  'To Date',
                  Icons.calendar_month_outlined,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: _decoration('Status', Icons.filter_alt_outlined),
          items: const [
            DropdownMenuItem(
              value: 'Select Status',
              child: Text('Select Status'),
            ),
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Approved', child: Text('Approved')),
            DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
          ],
          onChanged: (value) {
            if (value != null) {
              onStatusChanged(value);
            }
          },
        ),

        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B4332),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
