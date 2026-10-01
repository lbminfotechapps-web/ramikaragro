import 'package:solufine/core/api_constant/api_client.dart';

import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import 'package:solufine/features/products/domain/entity/fertilizer_product_entity.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum ProductLanguage { english, marathi, hindi, kannada }

class DynamicHtmlContent extends StatefulWidget {
  final String htmlContent;

  const DynamicHtmlContent({super.key, required this.htmlContent});

  @override
  State<DynamicHtmlContent> createState() => _DynamicHtmlContentState();
}

class _DynamicHtmlContentState extends State<DynamicHtmlContent> {
  late final WebViewController _controller;

  double _webViewHeight = 1;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Height',
        onMessageReceived: (message) {
          final height = double.tryParse(message.message);

          if (height == null) {
            return;
          }

          if (!mounted) {
            return;
          }

          if (height <= 0) {
            return;
          }

          setState(() {
            _webViewHeight = height + 4;
          });
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _calculateHeight();
          },
        ),
      )
      ..loadHtmlString(_buildHtml(widget.htmlContent));
  }

  // ============================================================
  // CALCULATE HTML HEIGHT
  // ============================================================

  Future<void> _calculateHeight() async {
    try {
      await _controller.runJavaScript('''
        setTimeout(function() {
          var body = document.body;
          var html = document.documentElement;

          var height = Math.max(
            body.scrollHeight,
            body.offsetHeight,
            html.clientHeight,
            html.scrollHeight,
            html.offsetHeight
          );

          Height.postMessage(height.toString());
        }, 100);
      ''');
    } catch (e) {
      debugPrint('WEBVIEW HEIGHT ERROR: $e');
    }
  }

  // ============================================================
  // BUILD HTML
  // ============================================================

  String _buildHtml(String htmlContent) {
    return '''
<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<meta
  name="viewport"
  content="width=device-width,
  initial-scale=1.0,
  maximum-scale=1.0,
  user-scalable=no">

<style>

html,
body {
  width: 100%;
  margin: 0;
  padding: 0;
  background: transparent;
}

body {
  font-family:
    Arial,
    "Noto Sans",
    sans-serif;

  font-size: 14px;

  line-height: 1.55;

  color: #424242;

  overflow: hidden;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  margin-top: 4px;
  margin-bottom: 6px;
}

h4 {
  font-size: 17px;
}

p {
  margin-top: 4px;
  margin-bottom: 7px;
}

ul,
ol {
  margin-top: 4px;
  margin-bottom: 8px;
  padding-left: 22px;
}

li {
  margin-top: 0;
  margin-bottom: 4px;
  padding: 0;
}

img {
  max-width: 100%;
  height: auto;
  display: block;
}

.greenLine {
  width: 50px;
  border-bottom: 3px solid #228B22;
  margin: 4px 0 8px 0;
}

.languageBlock {
  margin: 0;
  padding: 0;
}

.languageSeparator {
  width: 100%;
  height: 1px;
  background-color: #E5E5E5;

  margin-top: 12px;
  margin-bottom: 12px;
}

meta,
title,
link,
style {
  display: none;
}

</style>

</head>

<body>

$htmlContent

<script>

function sendHeight() {

  var body = document.body;

  var html = document.documentElement;

  var height = Math.max(
    body.scrollHeight,
    body.offsetHeight,
    html.clientHeight,
    html.scrollHeight,
    html.offsetHeight
  );

  Height.postMessage(
    height.toString()
  );
}

window.onload = function() {

  sendHeight();

  setTimeout(
    sendHeight,
    100
  );

  setTimeout(
    sendHeight,
    300
  );
};

</script>

</body>

</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _webViewHeight,
      child: WebViewWidget(controller: _controller),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final FertilizerProductEntity? product;

  const ProductDetails(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product Not Found')));
    }

    // ============================================================
    // PREPARE PRODUCT CONTENT
    // ============================================================

    final String productContent = _prepareProductContent(
      product!.productContents,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        onBackTap: () {
          context.pop();
        },
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ======================================================
            // PRODUCT IMAGE
            // ======================================================
            _buildProductImage(context),

            const SizedBox(height: 16),

            // ======================================================
            // PRODUCT NAME
            // ======================================================
            Text(
              product!.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // PRODUCT ENQUIRY
            // ======================================================
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openProductEnquiry(context);
                },
                icon: const Icon(
                  Icons.contact_support_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Product Enquiry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // SHORT DETAILS
            // ======================================================
            if (product!.productShortDetails.trim().isNotEmpty)
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

            // ======================================================
            // DOSAGE
            // ======================================================
            if (product!.productDosage.trim().isNotEmpty)
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

            // ======================================================
            // PRODUCT CONTENT
            // ======================================================
            if (productContent.isNotEmpty)
              _buildSection(
                title: 'Product Contents',
                child: DynamicHtmlContent(htmlContent: productContent),
              ),

            // ======================================================
            // DISEASE IMAGE
            // ======================================================
            if (product!.diseasePath.trim().isNotEmpty) _buildDiseaseImage(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PREPARE PRODUCT CONTENT
  //
  // API:
  //
  // English *_* Marathi *_* Hindi *_* Kannada
  //
  // OR sometimes only one language.
  //
  // This method:
  // 1. Splits *_*
  // 2. Removes empty blocks
  // 3. Removes duplicate blocks
  // 4. Shows every available block once
  // ============================================================

  String _prepareProductContent(String content) {
    if (content.trim().isEmpty) {
      return '';
    }

    final List<String> parts = content
        .split('*_*')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '';
    }

    final List<String> uniqueParts = [];

    final Set<String> alreadyAdded = {};

    for (final part in parts) {
      final String comparableContent = _normalizeHtmlForComparison(part);

      if (comparableContent.isEmpty) {
        continue;
      }

      if (!alreadyAdded.contains(comparableContent)) {
        alreadyAdded.add(comparableContent);

        uniqueParts.add(part);
      }
    }

    if (uniqueParts.isEmpty) {
      return '';
    }

    // Only one language from API.
    if (uniqueParts.length == 1) {
      return uniqueParts.first;
    }

    // Multiple unique languages.
    return uniqueParts
        .map(
          (content) =>
              '''
<div class="languageBlock">
  $content
</div>
''',
        )
        .join('''
<div class="languageSeparator"></div>
''');
  }

  // ============================================================
  // NORMALIZE HTML FOR DUPLICATE CHECK
  // ============================================================

  String _normalizeHtmlForComparison(String html) {
    return html
        .replaceAll(
          RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'<link[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<meta[^>]*>', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'<title[^>]*>[\s\S]*?</title>', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&bull;', '•')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  // ============================================================
  // PRODUCT ENQUIRY
  // ============================================================

  Future<void> _openProductEnquiry(BuildContext context) async {
    final userData = await SecureStorage.instance.getUserData();

    if (!context.mounted) {
      return;
    }

    final String userId = userData?['user_id']?.toString() ?? '';

    debugPrint('======================================');
    debugPrint('OPEN PRODUCT ENQUIRY');
    debugPrint('USER ID      : $userId');
    debugPrint('PRODUCT ID   : ${product!.productId}');
    debugPrint('PRODUCT NAME : ${product!.productName}');
    debugPrint('======================================');

    context.push(
      '/productEnquiry',
      extra: {
        'productId': product!.productId.toString(),
        'productName': product!.productName.toString(),
      },
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(BuildContext context) {
    if (product!.productPath.trim().isEmpty) {
      return _imagePlaceholder();
    }

    final imageUrl =
        '${ApiClient.imageBaseUrl}/products/${product!.productPath}';

    return GestureDetector(
      onTap: () {
        _showZoomImage(context, imageUrl);
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

            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ZOOM IMAGE
  // ============================================================

  void _showZoomImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
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

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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

          const SizedBox(height: 8),

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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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

          const SizedBox(height: 10),

          Image.network(
            '${ApiClient.imageBaseUrl}/disease/${product!.diseasePath}',
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const SizedBox(
                height: 140,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
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
}
