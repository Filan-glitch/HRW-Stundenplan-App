import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import '../model/redux/actions.dart';
import '../model/redux/store.dart';

Future<void> shouldShowChangelogIcon() async {
  String pubspec = await rootBundle.loadString("pubspec.yaml");
  String appVersion = loadYaml(pubspec)["version"].split("+")[0];

  SharedPreferences prefs = await SharedPreferences.getInstance();
  store.dispatch(Action(
    ActionTypes.showChangelog,
    payload: !prefs.containsKey("latestChangelogShownVersion") ||
        prefs.getString("latestChangelogShownVersion") != appVersion,
  ));
}
