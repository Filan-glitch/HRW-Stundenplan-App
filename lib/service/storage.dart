import 'package:flutter/material.dart' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yaml/yaml.dart';

import '../model/biometrics.dart';
import '../model/campus.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import '../model/timetable_view.dart';

Future<void> writeCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.args != null && store.state.cnsc != null) {
    prefs.setString("args", store.state.args!);
    prefs.setString("cnsc", store.state.cnsc!);
  }
}

Future<void> loadCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("args") && prefs.containsKey("cnsc")) {
    store.dispatch(Action(ActionTypes.setCredentials, payload: {
      "args": prefs.getString("args"),
      "cnsc": prefs.getString("cnsc"),
    }));
  }
}

Future<void> writeDesign() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.activeTheme == ui.ThemeMode.system) {
    if (prefs.containsKey("darkmode")) {
      prefs.remove("darkmode");
    }
  } else {
    prefs.setBool("darkmode", store.state.activeTheme == ui.ThemeMode.dark);
  }
}

Future<void> loadDesign() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ui.ThemeMode themeMode = ui.ThemeMode.system;

  if (prefs.getBool("darkmode") == true) {
    themeMode = ui.ThemeMode.dark;
  } else if (prefs.getBool("darkmode") == false) {
    themeMode = ui.ThemeMode.light;
  }

  store.dispatch(
    Action(
      ActionTypes.setDesign,
      payload: themeMode,
    ),
  );
}

Future<void> writeCampus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("campus", store.state.campus.text);
}

Future<void> loadCampus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("campus")) {
    store.dispatch(
      Action(
        ActionTypes.setCampus,
        payload: Campus.getByValue(prefs.getString("campus")!),
      ),
    );
  }
}

Future<void> crashlyticsDialogShown() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("crashlyticsDialogShown", "1");
}

Future<bool> didShowCrashlyticsDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey("crashlyticsDialogShown");
}

Future<void> writeGPA() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble("gpa", store.state.gpa);
}

Future<void> loadGPA() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("gpa")) {
    store.dispatch(
      Action(
        ActionTypes.setGPA,
        payload: prefs.getDouble("gpa"),
      ),
    );
  }
}

Future<void> writeDownloadedRange(String monday) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("downloadedRange", monday);
}

Future<String?> loadDownloadedRange() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("downloadedRange");
}

Future<void> writeBiometrics() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("biometrics", store.state.biometrics.index);
}

Future<void> loadBiometrics() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("biometrics")) {
    store.dispatch(
      Action(
        ActionTypes.setBiometricsType,
        payload: Biometrics.values[prefs.getInt("biometrics")!],
      ),
    );
  }
}

Future<void> writeNotificationsEnabled() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("notificationsEnabled", store.state.notificationsEnabled);
}

Future<void> loadNotificationsEnabled() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("notificationsEnabled")) {
    store.dispatch(
      Action(
        ActionTypes.setNotificationsEnabled,
        payload: prefs.getBool("notificationsEnabled"),
      ),
    );
  }
}

Future<void> writeDefaultView() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("defaultView", store.state.defaultView.index);
}

Future<void> loadDefaultView() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("defaultView")) {
    store.dispatch(
      Action(
        ActionTypes.setDefaultView,
        payload: TimetableView.values[prefs.getInt("defaultView")!],
      ),
    );
    store.dispatch(
      Action(
        ActionTypes.setView,
        payload: TimetableView.values[prefs.getInt("defaultView")!],
      ),
    );
  }
}

Future<void> writeAccount() async {
  if (store.state.account == null) return;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("account", store.state.account!);
}

Future<void> loadAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("account")) {
    store.dispatch(
      Action(
        ActionTypes.setAccount,
        payload: prefs.getString("account"),
      ),
    );
  }
}

Future<void> writeEnableConfirmRefreshDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(
      "enableConfirmRefreshDialog", store.state.enableConfirmRefreshDialog);
}

Future<void> loadEnableConfirmRefreshDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("enableConfirmRefreshDialog")) {
    store.dispatch(
      Action(
        ActionTypes.setEnableConfirmRefreshDialog,
        payload: prefs.getBool("enableConfirmRefreshDialog"),
      ),
    );
  }
}

Future<void> writeLastUpdated() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.lastUpdated == null) return;
  prefs.setString("lastUpdated", store.state.lastUpdated!);
}

Future<void> loadLastUpdated() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("lastUpdated")) {
    store.dispatch(
      Action(
        ActionTypes.setLastUpdated,
        payload: prefs.getString("lastUpdated"),
      ),
    );
  }
}

Future<bool> clearStorageIfUpdated() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String pubspec = await rootBundle.loadString("pubspec.yaml");
  String appVersion = loadYaml(pubspec)["version"].split("+")[0];

  if (prefs.getString("version") != appVersion) {
    await clearStorage();
    prefs.setString("version", appVersion);
    return true;
  }

  return false;
}

Future<void> clearStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  String path = join(await getDatabasesPath(), "timetable.db");
  await deleteDatabase(path);
  CookieManager.instance().deleteAllCookies();
}
