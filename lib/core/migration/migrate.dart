import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'v152.dart' as v152;

final List<Future<void> Function()?> _migrations = [
  null, // version code 1
  null, // version code 2
  null, // version code 3
  null, // version code 4
  null, // version code 5
  v152.migrate, // version code 6
];

Future<void> performMigration() async {
  String pubspec = await rootBundle.loadString("pubspec.yaml");
  int appVersionCode = int.parse(loadYaml(pubspec)["version"].split("+")[1]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int previousVersionCode = prefs.getInt("versionCode") ?? 0;

  for (int i = previousVersionCode; i <= appVersionCode; i++) {
    Future<void> Function()? migration = _migrations[i - 1];
    if (migration == null) continue;
    await migration();
  }
  prefs.setInt("versionCode", appVersionCode);
}
