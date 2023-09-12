import 'package:flutter/material.dart';
import '../model/timetable_view.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class SelectDefaultViewDialog extends StatelessWidget {
  const SelectDefaultViewDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Startansicht auswählen"),
      children: TimetableView.values.map((e) {
        return SimpleDialogOption(
          onPressed: () {
            store.dispatch(
              redux.Action(
                redux.ActionTypes.setDefaultView,
                payload: e,
              ),
            );
            writeDefaultView();
            Navigator.pop(context);
          },
          child: Text(e.text),
        );
      }).toList(),
    );
  }
}
