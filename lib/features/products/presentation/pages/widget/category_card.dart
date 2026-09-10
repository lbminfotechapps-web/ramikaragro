import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:flutter/material.dart';

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

  static const List<Color> _backgroundColors = [
    Color(0xFFF1FAF4), // Green
    Color(0xFFFFF8ED), // Orange
    Color(0xFFF1F5FD), // Blue
    Color(0xFFF5F5F5), // Grey
    Color(0xFFF9F0FF), // Purple
    Color(0xFFFFF0F3), // Pink
  ];

  Color get backgroundColor {
    return _backgroundColors[index % _backgroundColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: backgroundColor,
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
              SizedBox(width: 150, height: 120, child: _buildImage()),

              const SizedBox(height: 12),

              // CATEGORY NAME
              Text(
                category.categoryName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              // PRODUCT COUNT
              Text(
                '${category.products.length} Products',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (category.categoryPath.isEmpty) {
      return _placeholderImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        '${ApiClient.imageBaseUrl}/category/${category.categoryPath}',
        width: 150,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _placeholderImage();
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.category_rounded, size: 60, color: Colors.grey),
      ),
    );
  }
}
