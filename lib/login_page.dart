import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage(
      {required this.onLoginSuccessful, required this.onFailure, super.key}) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (url == "https://dsf.hs-ruhrwest.de/IdentityServer/") {
              // delete dsf session
              _controller.runJavaScript(
                'document.cookie.split(";").forEach(function(c) { document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); });',
              );

              await Future.delayed(const Duration(milliseconds: 500));

              _controller.loadRequest(
                Uri.parse(
                  'https://dsf.hs-ruhrwest.de/IdentityServer/connect/authorize?client_id=ClassicWeb&scope=openid%20DSF&response_mode=query&response_type=code&nonce=kQEKs7lCwN2CEXvCDeD1Zw==&redirect_uri=https%3A%2F%2Fcampusnet.hs-ruhrwest.de%2Fscripts%2Fmgrqispi.dll%3FAPPNAME%3DCampusNet%26PRGNAME%3DLOGINCHECK%26ARGUMENTS%3D-N000000000000001%2Cids_mode%26ids_mode%3DY',
                ),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith(
                    "https://campusnet.hs-ruhrwest.de/scripts/mgrqispi.dll") &&
                request.url.contains("PRGNAME=LOGINCHECK")) {
              performLogin(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  late final WebViewController _controller;
  final void Function(String args, String cnsc) onLoginSuccessful;
  final void Function() onFailure;

  void performLogin(String url) {
    String? args, cnsc;
    Uri link = Uri.parse(url);
    http.get(link).then((response) {
      // extract ARGUMENTS
      String startpageLink = response.headers["refresh"] ?? "";
      startpageLink = startpageLink.replaceAll("0; URL=", "");
      args = Uri.parse(startpageLink).queryParameters["ARGUMENTS"];

      // extract CNSC
      if (response.headers["set-cookie"] != null) {
        for (String cookieString
            in response.headers["set-cookie"]!.split(",")) {
          Cookie cookie = Cookie.fromSetCookieValue(cookieString);
          if (cookie.name == "cnsc") {
            cnsc = cookie.value;
          }
        }
      }

      if (args != null && cnsc != null) {
        onLoginSuccessful(args!, cnsc!);
      } else {
        onFailure();
      }
    });
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    widget._controller.loadRequest(
      Uri.parse('https://dsf.hs-ruhrwest.de/IdentityServer/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusNet Login'),
      ),
      body: WebViewWidget(
        controller: widget._controller,
      ),
    );
  }
}
