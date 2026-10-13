import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/features/products/domain/entity/fertilizer_product_entity.dart';
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: context.cardBackgroundColor,
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
              SizedBox(width: 140, height: 140, child: _buildImage(context)),

              const SizedBox(height: 12),

              // PRODUCT NAME
              Text(
                product.productName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.cardTextColor,
                ),
              ),

              if (product.productShortDetails.isNotEmpty) ...[
                const SizedBox(height: 5),

                Text(
                  product.productShortDetails,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (product.productPath.isEmpty) {
      return _placeholderImage(context);
    }

    return Image.network(
      '${ApiClient.imageBaseUrl}/products/${product.productPath}',
      width: 140,
      height: 140,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return _placeholderImage(context);
      },
    );
  }

  Widget _placeholderImage(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 55,
          color: context.secondaryTextColor,
        ),
      ),
    );
  }
}
