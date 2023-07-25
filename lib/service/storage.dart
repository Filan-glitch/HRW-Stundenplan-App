import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/biometrics.dart';
import '../model/campus.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';

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
  prefs.setBool("darkmode", store.state.darkmode);
}

Future<void> loadDesign() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("darkmode")) {
    store.dispatch(
      Action(
        ActionTypes.setDarkmode,
        payload: prefs.getBool("darkmode"),
      ),
    );
  }
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

Future<void> clearStorage() async {
  (await SharedPreferences.getInstance()).clear();
  String path = join(await getDatabasesPath(), "timetable.db");
  await deleteDatabase(path);
  CookieManager.instance().deleteAllCookies();
}
