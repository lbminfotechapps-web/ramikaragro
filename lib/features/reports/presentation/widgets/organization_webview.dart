import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrganizationWebView extends StatefulWidget {
  final String html;

  const OrganizationWebView({
    super.key,
    required this.html,
  });

  @override
  State<OrganizationWebView> createState() =>
      _OrganizationWebViewState();
}

class _OrganizationWebViewState
    extends State<OrganizationWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint(
              'WebView started: $url',
            );
          },

          onPageFinished: (url) {
            debugPrint(
              'WebView finished: $url',
            );
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

          onNavigationRequest: (
            NavigationRequest request,
          ) async {
            final String url =
                request.url.trim();

            debugPrint(
              'CLICKED URL: $url',
            );

            // ------------------------------------------------------------
            // INTERNAL HTML
            // ------------------------------------------------------------

            if (url.startsWith('about:') ||
                url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }

            // ------------------------------------------------------------
            // PHONE NUMBER
            // Example: tel:+919876543210
            // ------------------------------------------------------------

            if (url.startsWith('tel:')) {
              await _openPhone(
                url,
              );

              return NavigationDecision.prevent;
            }

            // ------------------------------------------------------------
            // EMAIL
            // Example: mailto:info@solufine.com
            // ------------------------------------------------------------

            if (url.startsWith('mailto:')) {
              await _openExternal(
                url,
                'Unable to open email application',
              );

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

            if (url.startsWith('http://') ||
                url.startsWith('https://')) {
              await _openBrowser(
                url,
              );

              return NavigationDecision.prevent;
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..setBackgroundColor(
        const Color(
          0xFFF7F9F8,
        ),
      )
      ..loadHtmlString(
        _buildHtml(
          widget.html,
        ),
      );
  }

  // =========================================================================
  // OPEN PHONE
  // =========================================================================

  Future<void> _openPhone(
    String url,
  ) async {
    try {
      final Uri uri =
          Uri.parse(
        url,
      );

      debugPrint(
        'OPEN PHONE: $uri',
      );

      final bool launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open phone dialer',
        );
      }
    } catch (e) {
      debugPrint(
        'PHONE ERROR: $e',
      );

      _showMessage(
        'Unable to open phone dialer',
      );
    }
  }

  // =========================================================================
  // OPEN BROWSER
  // =========================================================================

  Future<void> _openBrowser(
    String url,
  ) async {
    try {
      String finalUrl =
          url.trim();

      // Just additional safety
      if (!finalUrl.startsWith(
            'http://',
          ) &&
          !finalUrl.startsWith(
            'https://',
          )) {
        finalUrl =
            'https://$finalUrl';
      }

      final Uri uri =
          Uri.parse(
        finalUrl,
      );

      debugPrint(
        'OPEN BROWSER: $uri',
      );

      final bool launched =
          await launchUrl(
        uri,

        // IMPORTANT:
        // Opens Chrome/default browser
        // instead of loading inside WebView.
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open website',
        );
      }
    } catch (e) {
      debugPrint(
        'BROWSER ERROR: $e',
      );

      _showMessage(
        'Unable to open website',
      );
    }
  }

  // =========================================================================
  // OPEN EXTERNAL URI
  // =========================================================================

  Future<void> _openExternal(
    String url,
    String errorMessage,
  ) async {
    try {
      final Uri uri =
          Uri.parse(
        url,
      );

      final bool launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(
          errorMessage,
        );
      }
    } catch (e) {
      debugPrint(
        'OPEN EXTERNAL ERROR: $e',
      );

      _showMessage(
        errorMessage,
      );
    }
  }

  // =========================================================================
  // MESSAGE
  // =========================================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(
            message,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================================
  // BUILD HTML
  // =========================================================================

  String _buildHtml(
    String content,
  ) {
    return '''
<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<meta
  name="viewport"
  content="width=device-width,
  initial-scale=1.0,
  maximum-scale=1.0"
/>

<style>

html,
body {
    margin: 0;
    padding: 0;
    background: #F7F9F8;
}

body {
    padding: 18px;
    color: #333333;
    font-family: Arial, sans-serif;
    font-size: 15px;
    line-height: 1.7;
}

img {
    max-width: 100% !important;
    height: auto !important;
}

table {
    max-width: 100% !important;
}

div {
    max-width: 100% !important;
}

/* ===========================================================
   CLICKABLE LINKS
   =========================================================== */

a {
    color: #0F723A !important;
    text-decoration: none !important;
    font-weight: 600;
    word-break: break-word;
}

</style>

</head>

<body>

$content

</body>

</html>
''';
  }

  // =========================================================================
  // HTML UPDATE
  // =========================================================================

  @override
  void didUpdateWidget(
    covariant OrganizationWebView oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.html !=
        widget.html) {
      controller.loadHtmlString(
        _buildHtml(
          widget.html,
        ),
      );
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return WebViewWidget(
      controller:
          controller,
    );
  }
}