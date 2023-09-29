import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';

import '../model/constants.dart';
import '../model/login_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  static Completer<bool>? _loginCompleter;
  static Future<void> Function()? _onLoginSuccess;

  static Future<bool> hasActiveSession() async {
    store.dispatch(redux.Action(
      redux.ActionTypes.startTask,
    ));

    String identityPageContent = (await http
            .get(Uri.parse("https://dsf.hs-ruhrwest.de/IdentityServer/")))
        .body;

    store.dispatch(redux.Action(
      redux.ActionTypes.stopTask,
    ));

    return identityPageContent.contains("Logout");
  }

  static Future<bool> performLogin(
      {required Future<void> Function() onLoginSuccess}) async {
    if (store.state.loginFormState != LoginFormState.notShown) {
      return Future.value(false);
    }
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      return Future.value(false);
    }

    _onLoginSuccess = onLoginSuccess;
    _loginCompleter = Completer();
    store.dispatch(redux.Action(
      redux.ActionTypes.setLoginFormState,
      payload: LoginFormState.background,
    ));

    return _loginCompleter!.future;
  }

  void _cancelLogin() {
    store.dispatch(redux.Action(
      redux.ActionTypes.setLoginFormState,
      payload: LoginFormState.notShown,
    ));

    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      _loginCompleter!.complete(false);
    }
  }

  final GlobalKey _webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusNet Login'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _cancelLogin();
          return false;
        },
        child: InAppWebView(
          key: _webViewKey,
          initialUrlRequest: URLRequest(url: Uri.parse(LOGIN_URL)),
          shouldOverrideUrlLoading: _onNavigationRequest,
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              )),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'cancel',
              callback: (args) {
                _cancelLogin();
              },
            );
          },
          onLoadStop: (controller, url) {
            if (!url.toString().contains("IdentityServer/Account/Login")) {
              return;
            }
            _injectCancelJS(controller);
          },
        ),
      ),
    );
  }

  Future<NavigationActionPolicy> _onNavigationRequest(
      InAppWebViewController controller, NavigationAction action) async {
    String url = action.request.url.toString();

    if (url.startsWith(BASE_URL) && url.contains("PRGNAME=LOGINCHECK")) {
      _handleLogin(url);
      return NavigationActionPolicy.CANCEL;
    }

    if (url.contains("Account/Login") &&
        store.state.loginFormState != LoginFormState.inputRequired) {
      store.dispatch(redux.Action(
        redux.ActionTypes.setLoginFormState,
        payload: LoginFormState.inputRequired,
      ));
    }

    return NavigationActionPolicy.ALLOW;
  }

  void _handleLogin(String url) {
    String? args, cnsc;
    Uri link = Uri.parse(url);
    http.get(link).then((response) async {
      if (_loginCompleter!.isCompleted) return;

      // extract ARGUMENTS
      String startpageLink = response.headers["refresh"] ?? "";
      startpageLink = startpageLink.replaceAll("0; URL=", "");
      args =
          Uri.parse(startpageLink).queryParameters["ARGUMENTS"]?.split(",")[0];

      // extract CNSC
      if (response.headers["set-cookie"] != null) {
        for (String cookieString
            in response.headers["set-cookie"]!.split(",")) {
          if (!cookieString.contains("cnsc")) continue;
          cnsc = cookieString.split(";")[0].split("=")[1];
        }
      }

      store.dispatch(redux.Action(
        redux.ActionTypes.setLoginFormState,
        payload: LoginFormState.notShown,
      ));

      if (args != null && cnsc != null) {
        store.dispatch(redux.Action(
          redux.ActionTypes.setCredentials,
          payload: {"cnsc": cnsc, "args": args},
        ));

        await _onLoginSuccess!();

        writeCredentials().then((value) {
          if (!_loginCompleter!.isCompleted) _loginCompleter!.complete(true);
        });
      } else {
        if (!_loginCompleter!.isCompleted) _loginCompleter!.complete(false);
        showToast("Es ist ein Fehler aufgetreten");
      }
    });
  }

  void _injectCancelJS(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source:
          """document.querySelector('button[value=cancel]').onclick = () => window.flutter_inappwebview.callHandler('cancel');""",
    );
  }
}
