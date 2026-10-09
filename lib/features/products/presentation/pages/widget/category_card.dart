import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class CategoryCard extends StatelessWidget {
  final FertilizerCategoryEntity category;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.index,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.06), context.appCard),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IMAGE
              SizedBox(width: 150, height: 100, child: _buildImage(context)),

              //  SizedBox(height: 5.h),

              // CATEGORY NAME
              Text(
                category.categoryName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.appOnCard,
                ),
              ),

              // const SizedBox(height: 5),

              // PRODUCT COUNT
              Text(
                '${category.products.length} Products',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.appSubText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (category.categoryPath.isEmpty) {
      return _placeholderImage(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        '${ApiClient.imageBaseUrl}/category/${category.categoryPath}',
        width: 150,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _placeholderImage(context);
        },
      ),
    );
  }

  Widget _placeholderImage(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: context.appInputBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(Icons.category_rounded, size: 60, color: context.appSubText),
      ),
    );
  }
}
