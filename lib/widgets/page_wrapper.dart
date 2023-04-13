import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/redux/app_state.dart';
import 'action_menu.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({
    required this.child,
    this.actions = const [],
    this.title = "Stundenplan",
    this.canGoBack = false,
    super.key,
  });

  final Widget child;
  final List<Widget> actions;
  final String title;
  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                        if (actions.isNotEmpty)
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
                      child: child,
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: const BoxConstraints(maxWidth: 400.0),
      builder: (context) => ActionMenu(
        children: [
          ...actions,
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
