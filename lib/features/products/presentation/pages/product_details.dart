import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/products/domain/entity/fertilizer_product_entity.dart';

// ============================================================
// THEME
// ============================================================

class ProductUI {
  static const Color primary = Color(0xFF16834B);
  static const Color darkGreen = Color(0xFF106539);
  static const Color lightGreen = Color(0xFFEAF6EE);
  static const Color background = Color(0xFFF5F8F6);
  static const Color textDark = Color(0xFF1D3027);
  static const Color textGrey = Color(0xFF718078);
  static const Color border = Color(0xFFE7EEE9);
}

// ============================================================
// LANGUAGES
// ============================================================

enum ProductLanguage { english, marathi, hindi, kannada }

// ============================================================
// RESPONSIVE HTML WEBVIEW
// ============================================================

class DynamicHtmlContent extends StatefulWidget {
  final Map<ProductLanguage, String> contents;
  final ProductLanguage selectedLanguage;

  const DynamicHtmlContent({
    super.key,
    required this.contents,
    required this.selectedLanguage,
  });

  @override
  State<DynamicHtmlContent> createState() => _DynamicHtmlContentState();
}

class _DynamicHtmlContentState extends State<DynamicHtmlContent> {
  late final WebViewController _controller;
  double _height = 120;
  bool _ready = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Height',
        onMessageReceived: (message) {
          if (!mounted) return;
          final parts = message.message.split(':');
          if (parts.length != 2 ||
              parts.first != widget.selectedLanguage.name) {
            return;
          }
          final height = double.tryParse(parts.last);
          if (height == null || !height.isFinite || height <= 0) return;
          final nextHeight = height.ceilToDouble() + 4;
          if (_loading || (_height - nextHeight).abs() > 0.5) {
            setState(() {
              _height = nextHeight;
              _loading = false;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _ready = true;
            _selectLanguage();
          },
        ),
      )
      ..loadHtmlString(
        _buildHtml(),
        baseUrl: '${ApiClient.imageBaseUrl}/products/',
      );
  }

  @override
  void didUpdateWidget(covariant DynamicHtmlContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.contents.length != widget.contents.length ||
        widget.contents.entries.any(
          (entry) => oldWidget.contents[entry.key] != entry.value,
        );
    if (changed) {
      _ready = false;
      _loading = true;
      _controller.loadHtmlString(
        _buildHtml(),
        baseUrl: '${ApiClient.imageBaseUrl}/products/',
      );
    } else if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      _selectLanguage();
    }
  }

  Future<void> _selectLanguage() async {
    if (!_ready) return;
    try {
      await _controller.runJavaScript(
        'window.selectLanguage(${jsonEncode(widget.selectedLanguage.name)});',
      );
    } catch (error) {
      debugPrint('HTML LANGUAGE ERROR: $error');
    }
  }

  String _bodyHtml(String content) {
    final document = html_parser.parse(content);
    // API descriptions can be complete documents. Keep only body content
    // so their head styles and scripts cannot override the shared viewport.
    for (final node in document.querySelectorAll(
      'script, style, link, meta, title, iframe',
    )) {
      node.remove();
    }
    return document.body?.innerHtml ?? '';
  }

  String _buildHtml() {
    final blocks = widget.contents.entries.map((entry) {
      final hidden = entry.key == widget.selectedLanguage ? '' : ' hidden';
      final lang = switch (entry.key) {
        ProductLanguage.english => 'en',
        ProductLanguage.marathi => 'mr',
        ProductLanguage.hindi => 'hi',
        ProductLanguage.kannada => 'kn',
      };
      return '<section data-language="${entry.key.name}" lang="$lang"$hidden>'
          '${_bodyHtml(entry.value)}</section>';
    }).join();
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<style>
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; width: 100%; background: transparent; }
body { font-family: Arial, "Noto Sans", sans-serif; font-size: 14px;
  line-height: 1.65; color: #506057; overflow-wrap: anywhere; }
#content { display: flow-root; width: 100%; }
section { display: flow-root; width: 100%; }
section[hidden] { display: none !important; }
section * { max-width: 100% !important; }
h1,h2,h3,h4,h5,h6 { color: #1D3027; margin: 6px 0; }
p { margin: 4px 0 8px; }
ul,ol { padding-left: 22px; margin: 4px 0 8px; }
li { margin-bottom: 4px; }
img,video { max-width: 100%; height: auto !important; }
table { width: 100% !important; border-collapse: collapse; table-layout: fixed; }
td,th { border: 1px solid #E6ECE8; padding: 7px; text-align: left;
  overflow-wrap: anywhere; }
pre { white-space: pre-wrap; }
.greenLine { width: 42px; border-bottom: 3px solid #16834B; margin: 6px 0; }
</style>
</head>
<body>
<div id="content">$blocks</div>
<script>
var content = document.getElementById('content');
var selected = ${jsonEncode(widget.selectedLanguage.name)};
function sendHeight() {
  var height = Math.ceil(content.getBoundingClientRect().height);
  Height.postMessage(selected + ':' + Math.max(1, height));
}
window.selectLanguage = function(language) {
  selected = language;
  content.querySelectorAll('section[data-language]').forEach(function(block) {
    block.hidden = block.dataset.language !== language;
  });
  sendHeight();
  requestAnimationFrame(sendHeight);
};
if (window.ResizeObserver) new ResizeObserver(sendHeight).observe(content);
window.addEventListener('load', sendHeight);
window.addEventListener('resize', sendHeight);
content.querySelectorAll('img').forEach(function(img) {
  img.addEventListener('load', sendHeight);
  img.addEventListener('error', sendHeight);
});
if (document.fonts) document.fonts.ready.then(sendHeight);
sendHeight();
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAILS PAGE
// ============================================================

class ProductDetails extends StatefulWidget {
  final FertilizerProductEntity? product;

  const ProductDetails(this.product, {super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  FertilizerProductEntity? get product => widget.product;

  ProductLanguage _selectedLanguage = ProductLanguage.english;

  bool _isSharing = false;
  Map<ProductLanguage, String> _contents = {};

  @override
  void initState() {
    super.initState();
    if (product != null) _contents = _languageContents(product!);
  }

  @override
  void didUpdateWidget(covariant ProductDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != product) {
      _contents = product == null ? {} : _languageContents(product!);
      _selectedLanguage = ProductLanguage.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = product;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Product Not Found')));
    }

    final languages = _contents;
    final availableLanguages = languages.keys.toList();

    final selectedLanguage = languages.containsKey(_selectedLanguage)
        ? _selectedLanguage
        : (availableLanguages.isNotEmpty
              ? availableLanguages.first
              : ProductLanguage.english);

    return Scaffold(
      backgroundColor: ProductUI.background,
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        onBackTap: () => context.pop(),
      ),

      // FIXED BOTTOM ACTIONS
      bottomNavigationBar: _buildBottomActions(),

      // SINGLE SCROLLABLE BODY
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductHero(item),

              const SizedBox(height: 12),

              if (item.productShortDetails.trim().isNotEmpty)
                _buildInfoCard(
                  icon: Icons.description_outlined,
                  title: 'Product Details',
                  child: Text(item.productShortDetails, style: _bodyStyle()),
                ),

              if (item.productDosage.trim().isNotEmpty)
                _buildInfoCard(
                  icon: Icons.science_outlined,
                  title: 'Recommended Dosage',
                  child: Text(item.productDosage, style: _bodyStyle()),
                ),

              if (availableLanguages.isNotEmpty)
                _buildContentCard(
                  availableLanguages,
                  selectedLanguage,
                  languages,
                ),

              if (item.diseasePath.trim().isNotEmpty) _buildDiseaseCard(item),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCT HERO
  // ==========================================================

  Widget _buildProductHero(FertilizerProductEntity item) {
    final hasImage = item.productPath.trim().isNotEmpty;

    final imageUrl = hasImage
        ? '${ApiClient.imageBaseUrl}/products/${item.productPath}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProductUI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 174,
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F4),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: hasImage
                        ? GestureDetector(
                            onTap: () => _showZoomImage(imageUrl),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }

                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: ProductUI.primary,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            ),
                          )
                        : _imagePlaceholder(),
                  ),
                ),

                Positioned(
                  left: 10,
                  top: 10,
                  child: _smallTag(Icons.eco_outlined, 'Product'),
                ),

                if (hasImage)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _showZoomImage(imageUrl),
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.zoom_out_map_rounded,
                            color: ProductUI.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: Text(
              item.productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: ProductUI.textDark,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ProductUI.primary, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ProductUI.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMATION CARD
  // ==========================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ProductUI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon, title),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: ProductUI.lightGreen,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: ProductUI.primary),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: ProductUI.textDark,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _bodyStyle() {
    return const TextStyle(
      fontSize: 13.5,
      height: 1.55,
      color: ProductUI.textGrey,
      fontWeight: FontWeight.w400,
    );
  }

  // ==========================================================
  // PRODUCT CONTENT CARD
  // ==========================================================

  Widget _buildContentCard(
    List<ProductLanguage> languages,
    ProductLanguage selected,
    Map<ProductLanguage, String> contents,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ProductUI.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LANGUAGE SELECTOR
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: languages.map((language) {
                final isSelected = language == selected;

                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    label: Text(_languageLabel(language)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                    backgroundColor: ProductUI.background,
                    selectedColor: ProductUI.lightGreen,
                    side: BorderSide(
                      color: isSelected ? ProductUI.primary : ProductUI.border,
                    ),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? ProductUI.primary
                          : ProductUI.textGrey,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          _sectionTitle(Icons.menu_book_outlined, 'Product Contents'),

          const SizedBox(height: 12),

          Container(height: 1, color: ProductUI.border),

          const SizedBox(height: 12),

          DynamicHtmlContent(
            key: ValueKey(product!.productId),
            contents: contents,
            selectedLanguage: selected,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DISEASE IMAGE CARD
  // ==========================================================

  Widget _buildDiseaseCard(FertilizerProductEntity item) {
    final imageUrl = '${ApiClient.imageBaseUrl}/disease/${item.diseasePath}';

    return _buildInfoCard(
      icon: Icons.coronavirus_outlined,
      title: 'Disease Information',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => _showZoomImage(imageUrl),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM FIXED ACTION BAR
  // ==========================================================

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: ProductUI.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _openProductEnquiry(context),
                  icon: const Icon(Icons.headset_mic_outlined, size: 19),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Product Enquiry'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProductUI.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              flex: 3,
              child: Builder(
                builder: (shareContext) {
                  return SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _isSharing
                          ? null
                          : () => _shareProduct(shareContext),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ProductUI.primary,
                              ),
                            )
                          : const Icon(Icons.ios_share_outlined, size: 18),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ProductUI.primary,
                        side: const BorderSide(color: ProductUI.primary),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LANGUAGE LABELS
  // ==========================================================

  String _languageLabel(ProductLanguage language) {
    switch (language) {
      case ProductLanguage.english:
        return 'English';

      case ProductLanguage.marathi:
        return 'मराठी';

      case ProductLanguage.hindi:
        return 'हिन्दी';

      case ProductLanguage.kannada:
        return 'ಕನ್ನಡ';
    }
  }

  // ==========================================================
  // LANGUAGE CONTENT FROM API
  // ==========================================================

  Map<ProductLanguage, String> _languageContents(FertilizerProductEntity item) {
    final contents = <ProductLanguage, String>{};

    // Order: English * _ * Marathi * _ * Hindi * _ * Kannada
    // Actual separator: *_*

    final parts = item.productContents.split('*_*');

    for (
      var i = 0;
      i < parts.length && i < ProductLanguage.values.length;
      i++
    ) {
      if (_normalizeHtmlForComparison(parts[i]).isNotEmpty) {
        contents[ProductLanguage.values[i]] = parts[i].trim();
      }
    }

    final separate = <ProductLanguage, String>{
      ProductLanguage.marathi: item.productContentMarathi,
      ProductLanguage.hindi: item.productContentHindi,
      ProductLanguage.kannada: item.productContentKannad ?? '',
    };

    for (final entry in separate.entries) {
      if (_normalizeHtmlForComparison(entry.value).isNotEmpty) {
        contents[entry.key] = entry.value.trim();
      }
    }

    return {
      for (final language in ProductLanguage.values)
        if (contents.containsKey(language)) language: contents[language]!,
    };
  }

  String _normalizeHtmlForComparison(String html) {
    return _plainText(
      html,
    ).replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  // ==========================================================
  // HTML TO PLAIN TEXT
  // ==========================================================

  String _plainText(String content) {
    final document = html_parser.parse(content);

    for (final node in document.querySelectorAll(
      'style,script,title,meta,link',
    )) {
      node.remove();
    }

    for (final node in document.querySelectorAll('br')) {
      node.replaceWith(html_dom.Text('\n'));
    }

    for (final node in document.querySelectorAll(
      'p,div,li,h1,h2,h3,h4,h5,h6',
    )) {
      node.nodes.add(html_dom.Text('\n'));
    }

    return (document.body?.text ?? '')
        .replaceAll(RegExp(r'[^\S\n]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // ==========================================================
  // PRODUCT ENQUIRY
  // ==========================================================

  Future<void> _openProductEnquiry(BuildContext context) async {
    final currentProduct = product;

    if (currentProduct == null) return;

    final userData = await SecureStorage.instance.getUserData();

    if (!context.mounted) return;

    final userId = userData?['user_id']?.toString() ?? '';

    debugPrint('OPEN PRODUCT ENQUIRY');
    debugPrint('USER ID: $userId');
    debugPrint('PRODUCT ID: ${currentProduct.productId}');

    context.push(
      '/productEnquiry',
      extra: {
        'productId': currentProduct.productId.toString(),
        'productName': currentProduct.productName.toString(),
      },
    );
  }

  // ==========================================================
  // SHARE PRODUCT
  // ==========================================================

  Future<void> _shareProduct(BuildContext shareContext) async {
    final item = product;

    if (item == null || _isSharing) return;

    final renderObject = shareContext.findRenderObject();

    final box = renderObject is RenderBox ? renderObject : null;

    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    setState(() => _isSharing = true);

    try {
      final sections = <String>[item.productName];

      void addSection(String title, String value) {
        final text = _plainText(value);

        if (text.isNotEmpty) {
          sections.add('$title:\n$text');
        }
      }

      addSection('Product Details', item.productShortDetails);

      addSection('Dosage', item.productDosage);

      final contentMap = _languageContents(item);

      for (final entry in contentMap.entries) {
        addSection(
          'Product Contents (${_languageLabel(entry.key)})',
          entry.value,
        );
      }

      final files = <XFile>[];
      final fileNames = <String>[];

      // SHARE IMAGE WHEN AVAILABLE
      if (item.productPath.trim().isNotEmpty) {
        try {
          final uri = Uri.parse(
            '${ApiClient.imageBaseUrl}/products/${item.productPath}',
          );

          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            final mimeType = response.headers['content-type']
                ?.split(';')
                .first
                .trim();

            if (mimeType != null && mimeType.startsWith('image/')) {
              files.add(XFile.fromData(response.bodyBytes, mimeType: mimeType));

              fileNames.add(uri.pathSegments.last);
            }
          }
        } catch (e) {
          debugPrint('SHARE IMAGE ERROR: $e');
          // Text sharing can still proceed.
        }
      }

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          text: sections.join('\n\n'),
          files: files.isEmpty ? null : files,
          fileNameOverrides: fileNames.isEmpty ? null : fileNames,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('SHARE ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share product. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  // ==========================================================
  // ZOOM PRODUCT OR DISEASE IMAGE
  // ==========================================================

  void _showZoomImage(String imageUrl) {
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
                  maxScale: 5,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 65,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 40,
                right: 18,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // IMAGE PLACEHOLDER
  // ==========================================================

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 60,
        color: Color(0xFFB1C5B7),
      ),
    );
  }
}
