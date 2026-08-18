import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fuodz/constants/sizes.dart';

class WebViewer extends StatefulWidget {
  final String url;
  final bool showAppBar;
  final String? title;
  final bool showProgressBar;
  final bool enableJavaScript;
  final bool allowZoom;
  final Map<String, String>? headers;
  final double height;
  final bool isScrollable;
  final bool showBackButton;
  final EdgeInsets? padding;

  const WebViewer({
    Key? key,
    required this.url,
    this.showAppBar = false,
    this.title,
    this.showProgressBar = true,
    this.enableJavaScript = true,
    this.allowZoom = true,
    this.headers,
    this.height = 300.0, // Default height when used in ScrollView
    this.isScrollable = false, // Disable WebView scrolling when in ScrollView
    this.showBackButton = false, // Hide back button by default when embedded
    this.padding,
  }) : super(key: key);

  @override
  State<WebViewer> createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double? contentHeight;

  @override
  Widget build(BuildContext context) {
    Widget webViewContent = Column(
      children: [
        if (widget.showProgressBar)
          progress < 1.0
              ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              )
              : Container(),
        Container(
          padding:
              widget.padding ??
              EdgeInsets.symmetric(horizontal: Sizes.paddingSizeDefault),
          height: contentHeight ?? widget.height,
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
              headers: widget.headers,
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: !Platform.isIOS,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: widget.enableJavaScript,
                supportZoom: widget.allowZoom,
                disableVerticalScroll: !widget.isScrollable,
                disableHorizontalScroll: !widget.isScrollable,
              ),
              android: AndroidInAppWebViewOptions(useHybridComposition: true),
              ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'heightChanged',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final height = double.tryParse(args[0].toString());
                    if (height != null && mounted) {
                      setState(() {
                        contentHeight = height;
                      });
                    }
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              // You can add custom logic when the page starts loading
            },
            onLoadStop: (controller, url) async {
              // Inject listener for heightChanged message
              await controller.evaluateJavascript(
                source: """
                window.addEventListener('message', function(event) {
                    if (event.data && event.data.type === 'heightChanged') {
                        window.flutter_inappwebview.callHandler('heightChanged', event.data.height);
                    }
                });
              """,
              );

              // Get content height for YouTube videos or other content
              if (!widget.isScrollable) {
                try {
                  final height = await controller.evaluateJavascript(
                    source: "document.documentElement.scrollHeight",
                  );
                  if (mounted && height != null) {
                    setState(() {
                      // Add a small buffer to the height to prevent cutting off content
                      contentHeight = double.parse(height.toString()) + 20;
                    });
                  }
                } catch (e) {
                  debugPrint("Error getting content height: $e");
                }
              }
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  this.progress = progress / 100;
                });
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              // Handle console messages if needed
              debugPrint("Console Message: ${consoleMessage.message}");
            },
          ),
        ),
      ],
    );

    // Return a full scaffold if showAppBar is true, otherwise just the content
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Web Viewer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                webViewController?.reload();
              },
            ),
          ],
        ),
        body: webViewContent,
        floatingActionButton:
            widget.showBackButton
                ? FloatingActionButton(
                  child: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await webViewController?.canGoBack() ?? false) {
                      await webViewController?.goBack();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                )
                : null,
      );
    } else {
      return webViewContent;
    }
  }
}
