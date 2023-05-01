import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import '../model/redux/actions.dart';
import '../model/redux/store.dart';

Future<void> checkForUpdate() async {
  try {
    String pubspec = await rootBundle.loadString("pubspec.yaml");
    String appVersion = loadYaml(pubspec)["version"].split("+")[0];

    String latestPubspec = (await http.get(
      Uri.parse(
        "https://gitlab.janbellenberg.de/janbellenberg/timetable/-/raw/main/pubspec.yaml",
      ),
    ))
        .body;

    String latestVersion = loadYaml(latestPubspec)["version"].split("+")[0];

    if (appVersion.trim() != latestVersion.trim()) {
      showToast("Es ist ein Update verfügbar!");
      store.dispatch(Action(ActionTypes.updateAvailable));
    }
  } on TimeoutException {
    return;
  } on SocketException {
    return;
  } on Error catch (e, stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  } catch (e, stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

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
