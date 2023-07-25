import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timetable/loading_page.dart';
import 'package:timetable/login_page.dart';
import 'package:timetable/model/biometrics.dart';

import '../biometrics_page.dart';
import '../model/login_state.dart';
import '../model/redux/app_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../welcome_page.dart';
import 'action_menu.dart';

class PageWrapper extends StatelessWidget with WidgetsBindingObserver {
  PageWrapper({
    required this.body,
    this.bottomNavigationBar,
    this.actions = const [],
    this.menuActions = const [],
    this.title = "Stundenplan",
    this.canGoBack = false,
    this.simpleDesign = false,
    super.key,
  }) {
    WidgetsBinding.instance.addObserver(this);
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

  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget> menuActions;
  final List<Widget> actions;
  final String title;
  final bool canGoBack;
  final bool simpleDesign;

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (simpleDesign) {
      mainContent = Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: body,
      );
    } else {
      mainContent = Scaffold(
        bottomNavigationBar: bottomNavigationBar,
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
                          if (canGoBack)
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
                                title,
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
                          if (menuActions.isNotEmpty)
                            Row(
                              children: [
                                ...actions,
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
                        child: body,
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
          ...menuActions,
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
