import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:demo/features/products/presentation/bloc/product_bloc.dart';
import 'package:demo/features/products/presentation/bloc/product_event.dart';
import 'package:demo/features/products/presentation/bloc/product_state.dart';
import 'package:demo/features/products/presentation/pages/widget/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load all categories
    context.read<ProductBloc>().add(const ProductListingEvent(''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCategories(String value) {
    context.read<ProductBloc>().add(ProductListingEvent(value.trim()));
  }

  void openProducts(FertilizerCategoryEntity category) {
    context.push('/productList', extra: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Product Category',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            _buildSearchBar(),

            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state.productStatus == ProductStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.productStatus == ProductStatus.failure) {
                    return Center(
                      child: Text(state.message, textAlign: TextAlign.center),
                    );
                  }

                  if (state.fertilizerCategoryList.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }

                  return _buildCategoryGrid(state.fertilizerCategoryList);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _searchCategories,
        decoration: InputDecoration(
          hintText: 'Search category...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();

                    context.read<ProductBloc>().add(
                      const ProductListingEvent(''),
                    );

                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFF087C3A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<FertilizerCategoryEntity> categories) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];

        return CategoryCard(
          category: category,
          index: index,

          // IMPORTANT
          onTap: () => openProducts(category),
        );
      },
    );
  }
}
