import 'package:demo/core/theme/app_colors.dart';

import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:demo/features/products/presentation/pages/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class ProductList extends StatelessWidget {
  final FertilizerCategoryEntity? category;
  const ProductList(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return const Scaffold(body: Center(child: Text('Category Not Found')));
    }

    final products = category!.products;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: category!.categoryName,
        showBackButton: true,
        onBackTap: () {
          context.pop();
        },
      ),

      body: products.isEmpty
          ? Center(
              child: Text(
                'No products found',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  index: index,
                  onTap: () {
                    context.push('/productDetails', extra: product);
                    // Open product details
                  },
                );
              },
            ),
    );
  }
}
