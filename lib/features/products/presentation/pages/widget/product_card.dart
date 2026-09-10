import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/products/domain/entity/fertilizer_product_entity.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final FertilizerProductEntity product;
  final VoidCallback onTap;
  final int index;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.index,
  });

  static const List<Color> _backgroundColors = [
    Color(0xFFF1FAF4),
    Color(0xFFFFF8ED),
    Color(0xFFF1F5FD),
    Color(0xFFF5F5F5),
    Color(0xFFF9F0FF),
    Color(0xFFFFF0F3),
  ];

  Color get backgroundColor {
    return _backgroundColors[index % _backgroundColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PRODUCT IMAGE
              SizedBox(width: 140, height: 140, child: _buildImage()),

              const SizedBox(height: 12),

              // PRODUCT NAME
              Text(
                product.productName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (product.productShortDetails.isNotEmpty) ...[
                const SizedBox(height: 5),

                Text(
                  product.productShortDetails,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.productPath.isEmpty) {
      return _placeholderImage();
    }

    return Image.network(
      '${ApiClient.imageBaseUrl}/products/${product.productPath}',
      width: 140,
      height: 140,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return _placeholderImage();
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.inventory_2_rounded, size: 55, color: Colors.grey),
      ),
    );
  }
}
