import 'package:flutter/material.dart';

import '../widgets/markdown_widget.dart';
import '../widgets/dialog_wrapper.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: "Was ist neu?",
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: const MarkdownWidget(
            source:
                "https://gitlab.janbellenberg.de/janbellenberg/timetable/-/raw/main/CHANGELOG.md",
            isUrl: true,
          ),
        )
      ],
    );
  }
}
