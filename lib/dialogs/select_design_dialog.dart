import 'package:flutter/material.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class SelectDesignDialog extends StatelessWidget {
  const SelectDesignDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Design auswählen"),
      children: [
        SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setDesign,
                payload: ThemeMode.light,
              ),
            );
            writeDesign();
            Navigator.pop(context);
          },
          child: const Text("Hell"),
        ),
        SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setDesign,
                payload: ThemeMode.dark,
              ),
            );
            writeDesign();
            Navigator.pop(context);
          },
          child: const Text("Dunkel"),
        ),
        SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setDesign,
                payload: ThemeMode.system,
              ),
            );
            writeDesign();
            Navigator.pop(context);
          },
          child: const Text("System"),
        ),
      ],
    );
  }
}
