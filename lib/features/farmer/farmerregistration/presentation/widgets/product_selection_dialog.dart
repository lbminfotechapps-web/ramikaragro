import 'package:solufine/core/utility/app_toast.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/entity/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<ProductEntity> productList;
  final List<String> selectedProductIds;

  const ProductSelectionDialog({
    super.key,
    required this.productList,
    required this.selectedProductIds,
  });

  @override
  State<ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  late List<String> _selectedProductIds;

  @override
  void initState() {
    super.initState();

    _selectedProductIds = List<String>.from(
      widget.selectedProductIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 24.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 0.75.sh,
        ),
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: widget.productList.isEmpty
                  ? Center(
                      child: Text(
                        'No product available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(14.w),
                      itemCount: widget.productList.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final product = widget.productList[index];

                        return _buildProductItem(product);
                      },
                    ),
            ),

            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF087C3A),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 25.sp,
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              'Select Suggested Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductEntity product) {
    final productId = product.fldProductId;

    final isSelected = _selectedProductIds.contains(productId);

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedProductIds.remove(productId);
          } else {
            _selectedProductIds.add(productId);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF087C3A)
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: const Color(0xFF087C3A),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    if (!_selectedProductIds.contains(productId)) {
                      _selectedProductIds.add(productId);
                    }
                  } else {
                    _selectedProductIds.remove(productId);
                  }
                });
              },
            ),

            SizedBox(width: 4.w),

            Expanded(
              child: Text(
                product.fldProductName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  double.infinity,
                  48.h,
                ),
                side: const BorderSide(
                  color: Color(0xFF087C3A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF087C3A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_selectedProductIds.isEmpty) {

                     AppToast.error('Please select at least one product',);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text(
                  //       'Please select at least one product',
                  //     ),
                  //     backgroundColor: Colors.red,
                  //   ),
                  // );
                  return;
                }

                Navigator.pop(
                  context,
                  _selectedProductIds,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  double.infinity,
                  48.h,
                ),
                backgroundColor: const Color(0xFF087C3A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}