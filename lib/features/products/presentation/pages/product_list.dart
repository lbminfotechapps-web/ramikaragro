import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:solufine/features/products/presentation/pages/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductList extends StatelessWidget {
  final FertilizerCategoryEntity? category;
  const ProductList(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: Text(
            'Category Not Found',
            style: AppTextStyles.body.copyWith(color: context.primaryTextColor),
          ),
        ),
      );
    }

    final products = category!.products;

    return Scaffold(
      backgroundColor: context.backgroundColor,
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
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.secondaryTextColor,
                ),
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
