import 'package:demo/core/api_constant/api_client.dart';
import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
        ? imageUrl
        : '${ApiClient.imageBaseUrl}Scheme/$imageUrl';

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: InteractiveViewer(child: Image.network(resolvedImageUrl)),
      ),
    );
  }
}
