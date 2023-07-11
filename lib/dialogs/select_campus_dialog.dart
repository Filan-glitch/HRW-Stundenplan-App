import 'package:flutter/material.dart';
import '../model/campus.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class SelectCampusDialog extends StatelessWidget {
  const SelectCampusDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Campus auswählen"),
      children: [
        SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setCampus,
                payload: Campus.muelheim,
              ),
            );
            writeCampus();
            Navigator.pop(context);
          },
          child: const Text("Mülheim"),
        ),
        SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setCampus,
                payload: Campus.bottrop,
              ),
            );
            writeCampus();
            Navigator.pop(context);
          },
          child: const Text("Bottrop"),
        ),
      ],
    );
  }
}
