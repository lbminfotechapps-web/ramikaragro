import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Products'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Products Screen'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/productDetails');
              },
              child: const Text('Go to Product Details'),
            ),
          ],
        ),
      ),
    );
  }
}
