import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import '../widgets/dialog_wrapper.dart';
import '../widgets/markdown_widget.dart';

class ChangelogDialog extends StatelessWidget {
  ChangelogDialog({super.key}) {
    SharedPreferences.getInstance().then((prefs) async {
      String pubspec = await rootBundle.loadString("pubspec.yaml");
      String appVersion = loadYaml(pubspec)["version"].split("+")[0];
      prefs.setString("latestChangelogShownVersion", appVersion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: "Was ist neu?",
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: const MarkdownWidget(
            source: "CHANGELOG.md",
            isUrl: false,
          ),
        )
      ],
    );
  }
}
