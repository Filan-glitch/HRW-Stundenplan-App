import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/event.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';

Future<void> loadDataFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final RegExp dateRegExp = RegExp(r"\d{2}\/\d{2}\/\d{4}");

  List<String> toDelete = [];

  for (String date in prefs.getKeys()) {
    try {
      if (!dateRegExp.hasMatch(date)) continue;

      // remove past events
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      DateTime day = formatter.parse(date);
      if (day.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
        toDelete.add(date);
        continue;
      }

      // parse events
      List<dynamic> parsed = jsonDecode(prefs.getString(date) ?? "[]");
      List<Event> eventsOnDay = [];
      for (dynamic event in parsed) {
        if (event is! Map<String, dynamic>) continue;

        eventsOnDay.add(Event.fromAPI(event));
      }

      store.dispatch(Action(ActionTypes.setEvents, payload: {
        "date": date,
        "events": eventsOnDay,
      }));
    } catch (e, stackTrace) {
      showToast('Es ist ein Fehler aufgetreten');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      continue;
    }
  }

  for (String date in toDelete) {
    prefs.remove(date);
  }
}

Future<void> writeDataToStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  for (String date in store.state.events.keys) {
    List<Map<String, dynamic>> data =
        store.state.events[date]!.map((e) => e.toJSON()).toList();
    String json = jsonEncode(data);
    prefs.setString(date, json);
  }
}

Future<void> writeCredentialsToStorage() async {
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

Future<void> writeDarkmodeToStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("darkmode", store.state.darkmode);
}

Future<void> loadDarkmode() async {
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

Future<void> clearStorage() async {
  (await SharedPreferences.getInstance()).clear();
}
