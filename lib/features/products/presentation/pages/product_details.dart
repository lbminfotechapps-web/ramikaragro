import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/features/products/domain/entity/fertilizer_product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class ProductDetails extends StatelessWidget {
  final FertilizerProductEntity? product;

  const ProductDetails(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product Not Found')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        onBackTap: () {
          context.pop();
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------------------------------------------
            // PRODUCT IMAGE
            // ------------------------------------------
            //_buildProductImage(),
            _buildProductImage(context),

            const SizedBox(height: 20),

            // ------------------------------------------
            // PRODUCT NAME
            // ------------------------------------------
            Text(
              product!.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------
            // SHORT DETAILS
            // ------------------------------------------
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

            // ------------------------------------------
            // CONTENT
            // ------------------------------------------
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

            // ------------------------------------------
            // DOSAGE
            // ------------------------------------------
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

            // ------------------------------------------
            // PRODUCT CONTENT
            // ------------------------------------------
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

            // ------------------------------------------
            // DISEASE IMAGE / PATH
            // ------------------------------------------
            if (product!.diseasePath.isNotEmpty) _buildDiseaseImage(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  // Widget _buildProductImage() {
  //   if (product!.productPath.isEmpty) {
  //     return _imagePlaceholder();
  //   }

  //   return Container(
  //     height: 260,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     padding: const EdgeInsets.all(16),
  //     child: Image.network(
  //       '${ApiClient.imageBaseUrl}/products/${product!.productPath}',
  //       fit: BoxFit.contain,
  //       errorBuilder: (_, __, ___) {
  //         return _imagePlaceholder();
  //       },
  //     ),
  //   );
  // }

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
            // Zoomable image
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

            // Close button
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
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _imagePlaceholder();
              },
            ),
          ),

          // Zoom icon
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




  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({required String title, required Widget child}) {
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

  // ============================================================
  // DISEASE IMAGE
  // ============================================================

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

  // ============================================================
  // PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.inventory_2_rounded, size: 80, color: Colors.grey),
      ),
    );
  }

  // ============================================================
  // REMOVE HTML
  // ============================================================

  String _removeHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
}
