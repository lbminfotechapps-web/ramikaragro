import 'package:solufine/core/api_constant/api_client.dart';

import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';


import 'package:solufine/features/products/domain/entity/fertilizer_product_entity.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

// IMPORTANT:
// Use the file where your existing global `sl = GetIt.instance` is defined.

class ProductDetails extends StatelessWidget {
  final FertilizerProductEntity? product;

  const ProductDetails(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(
        body: Center(
          child: Text('Product Not Found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        onBackTap: () {
          context.pop();
        },
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================================
            // PRODUCT IMAGE
            // ========================================================
            _buildProductImage(context),

            const SizedBox(height: 20),

            // ========================================================
            // PRODUCT NAME
            // ========================================================
            Text(
              product!.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // ========================================================
            // PRODUCT ENQUIRY BUTTON
            // ========================================================
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openProductEnquiry(context);
                },
                icon: const Icon(
                  Icons.contact_support_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Product Enquiry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========================================================
            // SHORT DETAILS
            // ========================================================
            if (product!.productShortDetails.isNotEmpty)
              _buildSection(
                title: 'Product Details',
                child: Text(
                  product!.productShortDetails,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

            // ========================================================
            // DESCRIPTION
            // ========================================================
            if (product!.productContents.isNotEmpty)
              _buildSection(
                title: 'Description',
                child: Text(
                  _removeHtml(product!.productContents),
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

            // ========================================================
            // DOSAGE
            // ========================================================
            if (product!.productDosage.isNotEmpty)
              _buildSection(
                title: 'Dosage',
                child: Text(
                  product!.productDosage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

            // ========================================================
            // PRODUCT CONTENT
            // ========================================================
            if (product!.productContents.isNotEmpty)
              _buildSection(
                title: 'Product Contents',
                child: Text(
                  _removeHtml(product!.productContents),
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

            // ========================================================
            // DISEASE IMAGE
            // ========================================================
            if (product!.diseasePath.isNotEmpty)
              _buildDiseaseImage(),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // OPEN PRODUCT ENQUIRY
  // ==============================================================

  Future<void> _openProductEnquiry(BuildContext context) async {
    final userData = await SecureStorage.instance.getUserData();

    if (userData == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User information not found. Please login again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final String userId = userData['user_id']?.toString() ?? '';

    if (userId.isEmpty) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User ID not found. Please login again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (!context.mounted) return;

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => BlocProvider<EnquiryBloc>(
    //       create: (_) => sl<EnquiryBloc>(),
    //       child: EnquiryPage(
    //         productId: product!.productId,
    //         productName: product!.productName,
    //         userId: userId,
    //       ),
    //     ),
    //   ),
    // );
  context.push('/productEnquiry', extra: {
    'productId': product!.productId.toString(),
    'productName': product!.productName.toString(),
  },);

  }

  // ==============================================================
  // SHOW ZOOM IMAGE
  // ==============================================================

  void _showZoomImage(
    BuildContext context,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // ====================================================
              // ZOOMABLE IMAGE
              // ====================================================
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                        size: 70,
                      );
                    },
                  ),
                ),
              ),

              // ====================================================
              // CLOSE BUTTON
              // ====================================================
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================================================
  // PRODUCT IMAGE
  // ==============================================================

  Widget _buildProductImage(BuildContext context) {
    if (product!.productPath.isEmpty) {
      return _imagePlaceholder();
    }

    final imageUrl =
        '${ApiClient.imageBaseUrl}/products/${product!.productPath}';

    return GestureDetector(
      onTap: () {
        _showZoomImage(
          context,
          imageUrl,
        );
      },
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // ======================================================
            // IMAGE
            // ======================================================
            Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return _imagePlaceholder();
                },
              ),
            ),

            // ======================================================
            // ZOOM ICON
            // ======================================================
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SECTION
  // ==============================================================

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF087C3A),
            ),
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  // ==============================================================
  // DISEASE IMAGE
  // ==============================================================

  Widget _buildDiseaseImage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disease',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF087C3A),
            ),
          ),

          const SizedBox(height: 12),

          Image.network(
            '${ApiClient.imageBaseUrl}/disease/${product!.diseasePath}',
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // IMAGE PLACEHOLDER
  // ==============================================================

  Widget _imagePlaceholder() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ==============================================================
  // REMOVE HTML
  // ==============================================================

  String _removeHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
}