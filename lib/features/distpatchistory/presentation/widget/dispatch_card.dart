import 'package:solufine/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DispatchCard extends StatelessWidget {
  final dynamic dispatch;
  final VoidCallback onDetails;

  const DispatchCard({
    super.key,
    required this.dispatch,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 12.h),

                      _buildInfoRow(
                        icon: Icons.storefront_outlined,
                        label: 'Dealer',
                        value: _dealerName(),
                      ),

                      SizedBox(height: 7.h),

                      _buildInfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Order No.',
                        value: _orderNumber(),
                      ),

                      SizedBox(height: 12.h),

                      _buildQuantitySection(),

                      SizedBox(height: 10.h),

                      _buildInfoRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'LR No.',
                        value: _lrNumber(),
                      ),

                      SizedBox(height: 7.h),

                      _buildInfoRow(
                        icon: Icons.fire_truck_outlined,
                        label: 'Transport',
                        value: _transportDetails(),
                      ),

                      SizedBox(height: 10.h),

                      SizedBox(height: 10.h),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),

                      SizedBox(height: 5.h),

                      _buildBottomAction(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: _statusColor().withOpacity(0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(_statusIcon(), color: _statusColor(), size: 19.sp),
        ),

        SizedBox(width: 9.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusText(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: _statusColor(),
                ),
              ),
            ],
          ),
        ),

        _buildStatusBadge(),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge() {
    final color = _statusColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _statusBadgeText(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 27.w,
          height: 27.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 15.sp, color: Colors.grey.shade600),
        ),

        SizedBox(width: 8.w),

        SizedBox(
          width: 62.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(width: 4.w),

        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF26332C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUANTITY SECTION
  // ============================================================

  Widget _buildQuantitySection() {
    return Row(
      children: [
        Expanded(
          child: _quantityCard(
            title: 'Order Case Qty',
            value: _orderQty(),
            icon: Icons.inventory_2_outlined,
            background: const Color(0xFFF4F7F5),
            valueColor: AppColors.darkPrimaryColor,
          ),
        ),

        SizedBox(width: 7.w),

        Expanded(
          child: _quantityCard(
            title: 'Dispatch',
            value: _dispatchQty(),
            icon: Icons.local_shipping_outlined,
            background: const Color(0xFFF0F8F2),
            valueColor: const Color(0xFF2E7D32),
          ),
        ),

        SizedBox(width: 7.w),

        Expanded(
          child: _quantityCard(
            title: 'Remaining',
            value: _remainingQty(),
            icon: Icons.pending_actions_outlined,
            background: const Color(0xFFFFF7ED),
            valueColor: const Color(0xFFE65100),
          ),
        ),
      ],
    );
  }

  Widget _quantityCard({
    required String title,
    required String value,
    required IconData icon,
    required Color background,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: Colors.grey.shade600),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

  Widget _buildBottomAction() {
    return Row(
      children: [
        if (_isCancelled())
          Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 14.sp,
                color: Colors.red.shade600,
              ),
              SizedBox(width: 4.w),
              Text(
                'Cancelled',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),

        const Spacer(),

        TextButton(
          onPressed: onDetails,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Details',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkPrimaryColor,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15.sp,
                color: AppColors.darkPrimaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATA HELPERS
  // ============================================================

  String _dealerName() {
    return _getValue([
      'dealerName',
      'dealer_name',
      'outletName',
      'outlet_name',
      'orderBy',
    ]);
  }

  String _orderNumber() {
    return _getValue(['orderNo', 'order_no', 'orderNumber', 'order_number']);
  }

  String _orderQty() {
    return _getValue([
      'totalQty',
      'orderCaseQty',
      'order_case_qty',
      'orderQty',
      'order_qty',
      'caseQty',
    ]);
  }

  String _dispatchQty() {
    return _getValue([
      'dispatchQty',
      'dispatch_qty',
      'totalDispatchQty',
      'total_dispatch_qty',
    ]);
  }

  String _remainingQty() {
    return _getValue([
      'remainingDispatchQty',
      'remaining_dispatch_qty',
      'remainingQty',
      'remaining_qty',
    ]);
  }

  String _lrNumber() {
    return _getValue(['lrNo', 'lr_no', 'lrNumber', 'lr_number']);
  }

  String _transportDetails() {
    return _getValue([
      'transportationName',
      'transportation_name',
      'fld_transportation_name',
      'transNameVehicleNo',
      'transportationNameVehicleNo',
      'transport_name_vehicle_no',
      'vehicleNo',
      'vehicle_no',
    ]);
  }

  String _srNo() {
    return _getValue(['srNo', 'sr_no', 'serialNo', 'serial_no']);
  }

  String _statusText() {
    final value = _getValue([
      'orderStatus',
      'order_status',
      'statusName',
      'status_name',
      'status',
    ]);

    switch (value.trim()) {
      case '0':
        return 'Pending';

      case '1':
        return 'Approved';

      case '2':
        return 'Partial Dispatched';

      case '3':
        return 'Cancelled';

      case '5':
        return 'Dispatch';

      default:
        return value.isEmpty ? 'Dispatch' : value;
    }
  }

  String _statusBadgeText() {
    final value = _statusText().toLowerCase();

    if (value.contains('cancel')) {
      return 'CANCELLED';
    }

    if (value.contains('dispatch')) {
      return 'DISPATCHED';
    }

    if (value.contains('approve')) {
      return 'APPROVED';
    }

    if (value.contains('hold')) {
      return 'HOLD';
    }

    if (value.contains('pending')) {
      return 'PENDING';
    }

    return 'ACTIVE';
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _day() {
    final date = _getDate();

    if (date == null) {
      return '--';
    }

    return date.day.toString().padLeft(2, '0');
  }

  String _month() {
    final date = _getDate();

    if (date == null) {
      return '---';
    }

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[date.month - 1];
  }

  String _year() {
    final date = _getDate();

    if (date == null) {
      return '';
    }

    return date.year.toString();
  }

  DateTime? _getDate() {
    final value = _getValue([
      'orderDate',
      'order_date',
      'dispatchDate',
      'dispatch_date',
      'date',
    ]);

    if (value.isEmpty) {
      return null;
    }

    try {
      return DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  Color _statusColor() {
    final status = _statusText().toLowerCase();

    if (status.contains('cancel')) {
      return const Color(0xFFD32F2F);
    }

    if (status.contains('pending')) {
      return const Color(0xFFF57C00);
    }

    if (status.contains('hold')) {
      return const Color(0xFF7B1FA2);
    }

    if (status.contains('partial')) {
      return const Color(0xFF1976D2);
    }

    if (status.contains('dispatch')) {
      return const Color(0xFF2E7D32);
    }

    if (status.contains('approve')) {
      return const Color(0xFF2E7D32);
    }

    return AppColors.darkPrimaryColor;
  }

  IconData _statusIcon() {
    final status = _statusText().toLowerCase();

    if (status.contains('cancel')) {
      return Icons.cancel_outlined;
    }

    if (status.contains('pending')) {
      return Icons.hourglass_empty_rounded;
    }

    if (status.contains('hold')) {
      return Icons.pause_circle_outline_rounded;
    }

    if (status.contains('partial')) {
      return Icons.timelapse_rounded;
    }

    if (status.contains('dispatch')) {
      return Icons.local_shipping_outlined;
    }

    if (status.contains('approve')) {
      return Icons.check_circle_outline_rounded;
    }

    return Icons.inventory_2_outlined;
  }

  bool _isCancelled() {
    return _statusText().toLowerCase().contains('cancel');
  }

  // ============================================================
  // GENERIC VALUE READER
  // ============================================================

  String _getValue(List<String> names) {
    for (final name in names) {
      try {
        final value = _readProperty(name);

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      } catch (_) {}
    }

    return '';
  }

  dynamic _readProperty(String name) {
    switch (name) {
      case 'dealerName':
        return dispatch.dealerName;
      case 'dealer_name':
        return dispatch.dealer_name;
      case 'outletName':
        return dispatch.outletName;
      case 'outlet_name':
        return dispatch.outlet_name;
      case 'orderBy':
        return dispatch.orderBy;

      case 'orderNo':
        return dispatch.orderNo;
      case 'order_no':
        return dispatch.order_no;
      case 'orderNumber':
        return dispatch.orderNumber;
      case 'order_number':
        return dispatch.order_number;

      case 'orderCaseQty':
        return dispatch.orderCaseQty;
      case 'order_case_qty':
        return dispatch.order_case_qty;
      case 'orderQty':
        return dispatch.orderQty;
      case 'order_qty':
        return dispatch.order_qty;
      case 'caseQty':
        return dispatch.caseQty;
      case 'totalQty':
        return dispatch.totalQty;

      case 'dispatchQty':
        return dispatch.dispatchQty;
      case 'dispatch_qty':
        return dispatch.dispatch_qty;
      case 'totalDispatchQty':
        return dispatch.totalDispatchQty;
      case 'total_dispatch_qty':
        return dispatch.total_dispatch_qty;

      case 'remainingDispatchQty':
        return dispatch.remainingDispatchQty;
      case 'remaining_dispatch_qty':
        return dispatch.remaining_dispatch_qty;
      case 'remainingQty':
        return dispatch.remainingQty;
      case 'remaining_qty':
        return dispatch.remaining_qty;

      case 'lrNo':
        return dispatch.lrNo;
      case 'lr_no':
        return dispatch.lr_no;
      case 'lrNumber':
        return dispatch.lrNumber;
      case 'lr_number':
        return dispatch.lr_number;

      case 'transNameVehicleNo':
        return dispatch.transNameVehicleNo;
      case 'transportationNameVehicleNo':
        return dispatch.transportationNameVehicleNo;
      case 'transport_name_vehicle_no':
        return dispatch.transport_name_vehicle_no;
      case 'vehicleNo':
        return dispatch.vehicleNo;
      case 'vehicle_no':
        return dispatch.vehicle_no;

      case 'transportationName':
        return dispatch.transportationName;

      case 'transportation_name':
        return dispatch.transportation_name;

      case 'fld_transportation_name':
        return dispatch.fld_transportation_name;

      case 'srNo':
        return dispatch.srNo;
      case 'sr_no':
        return dispatch.sr_no;
      case 'serialNo':
        return dispatch.serialNo;
      case 'serial_no':
        return dispatch.serial_no;

      case 'orderStatus':
        return dispatch.orderStatus;
      case 'order_status':
        return dispatch.order_status;
      case 'statusName':
        return dispatch.statusName;
      case 'status_name':
        return dispatch.status_name;
      case 'status':
        return dispatch.status;

      case 'orderDate':
        return dispatch.orderDate;
      case 'order_date':
        return dispatch.order_date;
      case 'dispatchDate':
        return dispatch.dispatchDate;
      case 'dispatch_date':
        return dispatch.dispatch_date;
      case 'date':
        return dispatch.date;

      default:
        return null;
    }
  }
}
