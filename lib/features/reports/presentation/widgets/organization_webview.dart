import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrganizationWebView extends StatefulWidget {
  final String html;
  final bool removeHtmlBackground;

  const OrganizationWebView({
    super.key,
    required this.html,
    this.removeHtmlBackground = false,
  });

  @override
  State<OrganizationWebView> createState() => _OrganizationWebViewState();
}

class _OrganizationWebViewState extends State<OrganizationWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('WebView started: $url');
          },

          onPageFinished: (url) {
            debugPrint('WebView finished: $url');
          },

          onWebResourceError: (error) {
            debugPrint(
              'WebView error: '
              '${error.description}',
            );
          },

          // ================================================================
          // HANDLE LINK CLICK
          // ================================================================
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url.trim();

            debugPrint('CLICKED URL: $url');

            // ------------------------------------------------------------
            // INTERNAL HTML
            // ------------------------------------------------------------

            if (url.startsWith('about:') || url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }

            // ------------------------------------------------------------
            // PHONE NUMBER
            // Example: tel:+919876543210
            // ------------------------------------------------------------

            if (url.startsWith('tel:')) {
              await _openPhone(url);

              return NavigationDecision.prevent;
            }

            // ------------------------------------------------------------
            // EMAIL
            // Example: mailto:info@solufine.com
            // ------------------------------------------------------------

            if (url.startsWith('mailto:')) {
              await _openExternal(url, 'Unable to open email application');

              return NavigationDecision.prevent;
            }

            // ------------------------------------------------------------
            // WEBSITE
            //
            // solufineagritecch.com
            // https://solufineagritecch.com
            //
            // OPEN IN EXTERNAL BROWSER
            // ------------------------------------------------------------

            if (url.startsWith('http://') || url.startsWith('https://')) {
              await _openBrowser(url);

              return NavigationDecision.prevent;
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..setBackgroundColor(
        widget.removeHtmlBackground
            ? Colors.transparent
            : const Color(0xFFF7F9F8),
      )
      ..loadHtmlString(_buildHtml(widget.html));
  }

  // =========================================================================
  // OPEN PHONE
  // =========================================================================

  Future<void> _openPhone(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      debugPrint('OPEN PHONE: $uri');

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage('Unable to open phone dialer');
      }
    } catch (e) {
      debugPrint('PHONE ERROR: $e');

      _showMessage('Unable to open phone dialer');
    }
  }

  // =========================================================================
  // OPEN BROWSER
  // =========================================================================

  Future<void> _openBrowser(String url) async {
    try {
      String finalUrl = url.trim();

      // Just additional safety
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }

      final Uri uri = Uri.parse(finalUrl);

      debugPrint('OPEN BROWSER: $uri');

      final bool launched = await launchUrl(
        uri,

        // IMPORTANT:
        // Opens Chrome/default browser
        // instead of loading inside WebView.
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage('Unable to open website');
      }
    } catch (e) {
      debugPrint('BROWSER ERROR: $e');

      _showMessage('Unable to open website');
    }
  }

  // =========================================================================
  // OPEN EXTERNAL URI
  // =========================================================================

  Future<void> _openExternal(String url, String errorMessage) async {
    try {
      final Uri uri = Uri.parse(url);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(errorMessage);
      }
    } catch (e) {
      debugPrint('OPEN EXTERNAL ERROR: $e');

      _showMessage(errorMessage);
    }
  }

  // =========================================================================
  // MESSAGE
  // =========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.body),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================================
  // BUILD HTML
  // =========================================================================

String _buildHtml(String content) {
  final html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0"
/>

<style>
  html, body {
    margin: 0;
    padding: 0;
    width: 100%;
    overflow-x: hidden;
    background: #F7F9F8;
  }

  * {
    box-sizing: border-box;
  }

  body {
    padding: 18px;
    color: #333333;
    font-family: Arial, sans-serif;
    font-size: 15px;
    line-height: 1.7;
    overflow-wrap: break-word;
  }

  /* Prevent API content from overlapping */
  div {
    max-width: 100% !important;
    box-sizing: border-box !important;
  }

  /* Fixed/sticky headings must flow with content */
  .guideline-heading {
    position: static !important;
    float: none !important;
    width: 100% !important;
    height: auto !important;
    min-height: 0 !important;
    margin-bottom: 18px !important;
    clear: both !important;
  }

  h2, h3, h4 {
    max-width: 100%;
    overflow-wrap: break-word;
  }

  h3 {
    clear: both;
  }

  ul, ol {
    padding-left: 22px;
    margin: 10px 0 18px;
  }

  li {
    margin-bottom: 8px;
    overflow-wrap: break-word;
  }

  img, iframe, video {
    max-width: 100% !important;
    height: auto;
  }

  table {
    max-width: 100% !important;
  }

  a {
    color: #0F723A !important;
    text-decoration: none !important;
    font-weight: 600;
    overflow-wrap: anywhere;
  }

  ${widget.removeHtmlBackground ? '''
  html, body, body *, body *::before, body *::after {
    background: transparent !important;
  }
  ''' : ''}
</style>
</head>

<body>
$content
</body>
</html>
''';

  final document = html_parser.parse(html);

  // Fix fixed/sticky positioned elements only in guidelines.
  if (content.contains('Guidelines For Using App')) {
    for (final element in document.querySelectorAll('div')) {
      final style = element.attributes['style'] ?? '';

      if (RegExp(
        r'position\s*:\s*(fixed|sticky)',
        caseSensitive: false,
      ).hasMatch(style)) {
        element.classes.add('guideline-heading');

        // Remove inline positioning so CSS can
        // restore normal document flow.
        element.attributes['style'] = style.replaceAll(
          RegExp(
            r'position\s*:\s*(fixed|sticky)\s*;?',
            caseSensitive: false,
          ),
          '',
        );
      }
    }
  }

  if (widget.removeHtmlBackground) {
    for (final element in document.querySelectorAll('*')) {
      element.attributes.remove('bgcolor');
      element.attributes.remove('background');

      final style = element.attributes['style'] ?? '';

      element.attributes['style'] =
          '$style; background: transparent !important;';
    }
  }

  return document.outerHtml;
}

  // =========================================================================
  // HTML UPDATE
  // =========================================================================

  @override
  void didUpdateWidget(covariant OrganizationWebView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.html != widget.html ||
        oldWidget.removeHtmlBackground != widget.removeHtmlBackground) {
      controller.setBackgroundColor(
        widget.removeHtmlBackground
            ? Colors.transparent
            : const Color(0xFFF7F9F8),
      );
      controller.loadHtmlString(_buildHtml(widget.html));
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
