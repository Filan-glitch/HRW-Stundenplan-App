import 'dart:ui';

import 'package:flutter/material.dart';

class DialogWrapper extends StatelessWidget {
  const DialogWrapper({
    this.title = "Stundenplan",
    this.children,
    this.isSubPage = false,
    Key? key,
  }) : super(key: key);

  final bool isSubPage;
  final String title;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SimpleDialog(
        surfaceTintColor: Theme.of(context).colorScheme.background,
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: const Color.fromARGB(255, 97, 97, 97),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        contentPadding:
            isSubPage ? const EdgeInsets.all(0) : const EdgeInsets.all(25.0),
        title: isSubPage
            ? null
            : Text(
                title,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  fontSize: 25.0,
                ),
              ),
        children: children,
      ),
    );
  }
}
