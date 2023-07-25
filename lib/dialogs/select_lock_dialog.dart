import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../model/biometrics.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class SelectLockDialog extends StatelessWidget {
  const SelectLockDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Biometrie"),
      children: [
        SimpleDialogOption(
          onPressed: () {
            setBiometricsMode(Biometrics.OFF);
            Navigator.pop(context);
          },
          child: const Text("Ohne Sperre"),
        ),
        SimpleDialogOption(
          onPressed: () {
            setBiometricsMode(Biometrics.ONLY_EXAM_RESULTS);
            Navigator.pop(context);
          },
          child: const Text("Biometrie nur für Prüfungsergebnisse"),
        ),
        SimpleDialogOption(
          onPressed: () {
            setBiometricsMode(Biometrics.ON);
            Navigator.pop(context);
          },
          child: const Text("Biometrie aktivieren"),
        ),
      ],
    );
  }

  void setBiometricsMode(Biometrics type) async {
    store.dispatch(redux.Action(
      redux.ActionTypes.setLockState,
      payload: false,
    ));

    bool success = await LocalAuthentication().authenticate(
      localizedReason: "Bitte authentifizieren Sie sich",
    );

    if (!success) return;

    store.dispatch(redux.Action(
      redux.ActionTypes.setBiometricsType,
      payload: type,
    ));

    writeBiometrics();
  }
}
