import 'package:flutter/material.dart';

class BreakWidget extends StatelessWidget {
  const BreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(children: <Widget>[
        Expanded(
            child: Divider(
          color: Theme.of(context).dividerColor,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Pause",
            style: TextStyle(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ]),
    );
  }
}
