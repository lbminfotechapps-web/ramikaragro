import 'package:flutter/material.dart';
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
        ),
      )
      ..setBackgroundColor(
        const Color(0xFFF7F9F8),
      )
      ..loadHtmlString(
        _buildHtml(widget.html),
      );
  }

  String _buildHtml(String content) {
    return '''
<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0,
maximum-scale=1.0">

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

</style>

</head>

<body>

$content

</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}