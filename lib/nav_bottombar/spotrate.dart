import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Spotrate extends StatefulWidget {
  const Spotrate({super.key});

  @override
  State<Spotrate> createState() => _SpotrateState();
}

class _SpotrateState extends State<Spotrate> {
  double _progress=0;
  final uri = Uri.parse("https://aurifyae.github.io/royalvista-app/");
  late InAppWebViewController inAppWebViewController;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(uri),
              ),
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
          ],
        ),
      ),
    );

  }
}
