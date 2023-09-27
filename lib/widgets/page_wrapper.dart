import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oktoast/oktoast.dart';

import '../model/biometrics.dart';
import '../model/login_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../pages/biometrics_page.dart';
import '../pages/loading_page.dart';
import '../pages/login_page.dart';
import '../pages/welcome_page.dart';
import 'action_menu.dart';

class PageWrapper extends StatefulWidget {
  PageWrapper({
    required this.body,
    this.bottomNavigationBar,
    this.actions = const [],
    this.menuActions = const [],
    this.title = "Stundenplan",
    this.canGoBack = false,
    this.simpleDesign = false,
    super.key,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget> menuActions;
  final List<Widget> actions;
  final String title;
  final bool canGoBack;
  final bool simpleDesign;

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused &&
        store.state.biometrics == Biometrics.ON) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setLockState,
          payload: true,
        ),
      );
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (store.state.activeTheme == ThemeMode.system) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setDesign,
          payload: ThemeMode.system,
        ),
      );
    }
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (widget.simpleDesign) {
      mainContent = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: widget.body,
      );
    } else {
      mainContent = Scaffold(
        bottomNavigationBar: widget.bottomNavigationBar,
        body: Container(
          color: Theme.of(context).colorScheme.primary,
          child: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.canGoBack)
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(
                                Icons.navigate_before,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Text(
                                widget.title,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (widget.menuActions.isNotEmpty)
                            Row(
                              children: [
                                ...widget.actions,
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _showActionMenu(context),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: widget.body,
                      ),
                    ),
                  ],
                );
              }),
        ),
      );
    }

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Stack(
          children: [
            SafeArea(
              child: OKToast(
                child: state.args == null || state.cnsc == null
                    ? const WelcomePage()
                    : mainContent,
              ),
            ),
            if (state.appLocked && state.biometrics != Biometrics.OFF)
              const BiometricsPage(),
            if (state.loginFormState != LoginFormState.notShown) LoginPage(),
            if (state.loading ||
                !state.dataLoaded ||
                state.loginFormState == LoginFormState.background &&
                    state.loginFormState != LoginFormState.inputRequired)
              const LoadingPage(),
          ],
        );
      },
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: const BoxConstraints(maxWidth: 400.0),
      builder: (context) => ActionMenu(
        children: [
          ...widget.menuActions,
        ],
      ),
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }
}
