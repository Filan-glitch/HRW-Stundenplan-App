import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/redux/actions.dart' as redux;
import '../pages/login_page.dart';
import '../service/network_fetch.dart';
import '../service/storage.dart';
import '../widgets/dialog_wrapper.dart';

class ConfirmRefreshDialog extends StatelessWidget {
  const ConfirmRefreshDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: "Daten aktualisieren",
      children: [
        const Text(
          "Sollen die Daten aktualisiert werden?",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                LoginPage.performLogin(onLoginSuccess: reloadAll);
                Navigator.pop(context);
              },
              child: const Text("Ja"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nein"),
            ),
          ],
        ),
        StoreConnector<AppState, AppState>(
          builder: (context, state) {
            return CheckboxListTile(
              title: const Text(
                "Nicht erneut fragen",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              value: !state.enableConfirmRefreshDialog,
              onChanged: (value) {
                store.dispatch(
                  redux.Action(
                    redux.ActionTypes.setEnableConfirmRefreshDialog,
                    payload: value == false ? true : false,
                  ),
                );
                writeEnableConfirmRefreshDialog();
              },
            );
          },
          converter: (store) => store.state,
        ),
      ],
    );
  }
}
