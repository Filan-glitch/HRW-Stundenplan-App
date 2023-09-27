import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

import '../model/constants.dart';
import '../model/date_time_calculator.dart';
import '../model/event.dart';
import '../model/module.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import '../model/time.dart';
import '../model/weekday.dart';
import 'db/events.dart';
import 'db/grades.dart';
import 'storage.dart';

Future<void> reloadAll() async {
  DateFormat formatter = DateFormat('dd/MM/yyyy');
  List<Future> futures = store.state.events.keys
      .map((week) => fetchTimetableData(formatter.parse(week)))
      .toList();
  futures.add(fetchGradeData());
  futures.add(fetchAccountData());
  await Future.wait(futures);

  await writeDataToStorage();
  await writeGradesToStorage();
  await writeGPA();
  await writeAccount();
}

Future<void> loadWeekInterval({DateTime? start, int weeks = 6}) {
  start ??= DateTime.now();

  start = DateTimeCalculator.getFirstDayOfWeek(
    DateTimeCalculator.clean(start),
  );

  List<Future<void>> tasks = [
    for (int i = 0; i < weeks; i++)
      fetchTimetableData(
        start.add(
          Duration(days: i * 7),
        ),
      ),
  ];

  return Future.wait(tasks).then((_) {
    writeDataToStorage();
  });
}

Future<void> fetchTimetableData(DateTime monday) async {
  DateFormat formatter = DateFormat('dd/MM/yyyy');
  try {
    if (store.state.args == null || store.state.cnsc == null) return;
    log("fetching ${formatter.format(monday)}");

    store.dispatch(Action(ActionTypes.startTask));
    dom.Document body = await _fetchScheduleHTML(monday);
    List<Event> events = await _parseTimetable(body, monday);

    store.dispatch(Action(ActionTypes.setEvents, payload: {
      "date": formatter.format(monday),
      "events": events,
    }));

    store.dispatch(Action(ActionTypes.stopTask));
  } on TimeoutException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } on SocketException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(Action(ActionTypes.stopTask));

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  } finally {
    if (!store.state.events.containsKey(formatter.format(monday))) {
      store.dispatch(Action(ActionTypes.setEvents, payload: {
        "date": formatter.format(monday),
        "events": <Event>[],
      }));
    }
  }
}

Future<void> fetchGradeData() async {
  try {
    if (store.state.args == null || store.state.cnsc == null) return;

    store.dispatch(Action(ActionTypes.startTask));
    dom.Document body = await _fetchGradesHTML();
    List<Module> modules = await _parseGrades(body);
    double gpa = await _parseGPA(body);

    store.dispatch(Action(
      ActionTypes.setGrades,
      payload: modules,
    ));

    store.dispatch(Action(
      ActionTypes.setGPA,
      payload: gpa,
    ));

    store.dispatch(Action(ActionTypes.stopTask));
  } on TimeoutException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } on SocketException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(Action(ActionTypes.stopTask));

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<void> fetchAccountData() async {
  try {
    if (store.state.args == null || store.state.cnsc == null) return;

    store.dispatch(Action(ActionTypes.startTask));
    dom.Document body = await _fetchAccountHTML();
    String account = await _parseAccount(body);

    store.dispatch(Action(
      ActionTypes.setAccount,
      payload: account,
    ));

    store.dispatch(Action(ActionTypes.stopTask));
  } on TimeoutException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } on SocketException {
    showToast('Keine Verbindung');
    store.dispatch(Action(ActionTypes.stopTask));
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(Action(ActionTypes.stopTask));

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<dom.Document> _fetchScheduleHTML(
  DateTime monday,
) async {
  String args = store.state.args!;
  args = args.split(",")[0];
  http.Response registrations = await http.get(
      Uri.parse(
        "$BASE_URL?APPNAME=CampusNet&PRGNAME=SCHEDULER&ARGUMENTS=$args,-N000403,-A${monday.day.toString().padLeft(2, "0")}/${monday.month.toString().padLeft(2, "0")}/${monday.year},-A,-N1,-N0,-N1",
      ),
      headers: {"Cookie": "cnsc=${store.state.cnsc}"});

  return html.parse(utf8.decode(registrations.bodyBytes));
}

Future<dom.Document> _fetchGradesHTML() async {
  String? args = store.state.args;
  String? cnsc = store.state.cnsc;
  args = args?.split(",")[0];
  http.Response registrations = await http.get(
      Uri.parse(
        "$BASE_URL?APPNAME=CampusNet&PRGNAME=STUDENT_RESULT&ARGUMENTS=$args,-N000407,-N0,-N000000000000000,-N000000000000000,-N000000000000000,-N0,-N000000000000000",
      ),
      headers: {"Cookie": "cnsc=$cnsc"});

  var temp = _cleanString(utf8.decode(registrations.bodyBytes));
  return html.parse(temp);
}

Future<dom.Document> _fetchAccountHTML() async {
  String? args = store.state.args;
  String? cnsc = store.state.cnsc;
  args = args?.split(",")[0];
  http.Response registrations = await http.get(
      Uri.parse(
        "$BASE_URL?APPNAME=CampusNet&PRGNAME=PERSADDRESS&ARGUMENTS=$args,-N000426,",
      ),
      headers: {"Cookie": "cnsc=$cnsc"});

  var temp = _cleanString(utf8.decode(registrations.bodyBytes));
  return html.parse(temp);
}

Future<List<Event>> _parseTimetable(
    dom.Document document, DateTime monday) async {
  List<Event> events = [];
  if (!document.outerHtml.contains("Stundenplan")) {
    showToast("Bitte melden Sie sich erneut an");
    store.dispatch(Action(
      ActionTypes.setCredentials,
      payload: {"cnsc": null, "args": null},
    ));
    return [];
  }

  for (dom.Element element in document.querySelectorAll("td.appointment")) {
    String details =
        element.querySelectorAll(".timePeriod").map((e) => e.text).join();

    List<RegExpMatch> timePeriod = RegExp(r'(\d{2}):(\d{2}) - (\d{2}):(\d{2})')
        .allMatches(details)
        .toList();

    String room;

    if (element.querySelectorAll(".timePeriod a").isEmpty) {
      // Variante 1
      var allText = element.text.trim();
      var texts = allText.split('\n').map((e) => e.trim()).toList();

      if (texts.length > 1) {
        room = texts[1].replaceAll(RegExp("\(\d+\)"), "").trim();
      } else {
        room = ""; // Für den Fall, dass das Format unerwartet ist
      }
    } else {
      // Variante 2
      room = element
          .querySelectorAll(".timePeriod a")
          .map((e) => e.text.replaceAll(RegExp("\(\d+\)"), "").trim())
          .join(", ");
    }

    String? title = element.querySelector("a.link")?.attributes["title"];

    // Lies den Text zwischen dem <a></a> Tag aus und speicher ihn in einer Variable abbr
    String? abbr = element
        .querySelector("a.link")
        ?.text
        .replaceAll("\t", "")
        .replaceAll("\n", "");

    if (title == null) continue;

    Time start = Time(
      int.tryParse(timePeriod.first.group(1) ?? "0") ?? 0,
      int.tryParse(timePeriod.first.group(2) ?? "0") ?? 0,
    );
    Time end = Time(
      int.tryParse(timePeriod.first.group(3) ?? "0") ?? 0,
      int.tryParse(timePeriod.first.group(4) ?? "0") ?? 0,
    );

    events.add(
      Event(
        title: title.trim(),
        room: room.replaceAll(RegExp(r'\(\d+\)'), "").trim(),
        abbreviation: abbr ?? "",
        start: start,
        end: end,
        day: Weekday.getByText(element.attributes["abbr"] ?? ""),
        weekFrom: DateFormat('dd/MM/yyyy').format(monday),
      ),
    );
  }

  return events;
}

Future<List<Module>> _parseGrades(dom.Document document) async {
  if (!document.outerHtml.contains("Studienergebnisse")) {
    showToast("Bitte melden Sie sich erneut an");
    store.dispatch(Action(
      ActionTypes.setCredentials,
      payload: {"cnsc": null, "args": null},
    ));
    return [];
  }
  List<Module> modules = [];
  for (dom.Element element in document.querySelectorAll("tr")) {
    var data = element.querySelectorAll('.tbdata');
    if (data.isEmpty) continue;

    Module module = Module(
      identifier: data.first.text,
      title: data[1].querySelector("a")?.text ??
          data[1].text.replaceAll("\n", "").trim(),
      creditsAll: int.tryParse(data[3].text.split(",").firstOrNull ?? "0") ?? 0,
      creditsCharged:
          int.tryParse(data[4].text.split(",").firstOrNull ?? "0") ?? 0,
      grade: double.tryParse(
            data[5].text.replaceAll(",", "."),
          ) ??
          0.0,
    );

    switch (data[6].querySelector("img")?.attributes["src"]) {
      case "/img/individual/pass.gif":
        module.status = Status.passed;
        break;
      case "/img/individual/incomplete.gif":
        module.status = Status.failed;
        break;
      default:
        module.status = Status.open;
        break;
    }

    modules.add(module);
  }
  return modules;
}

Future<double> _parseGPA(dom.Document document) async {
  try {
    var data = document.querySelectorAll(
        'table.nb.list.students_results th.tbsubhead[style="text-align:right;"]');
    if (data.length > 1) {
      return double.tryParse(data[1].text.trim().replaceAll(",", ".")) ?? 0.0;
    }
  } on FormatException {
    return 0.0;
  }
  return 0.0;
}

Future<String> _parseAccount(dom.Document document) async {
  var firstName =
      _cleanString(document.querySelector('td[name="firstName"]')!.text).trim();
  var lastName =
      _cleanString(document.querySelector('td[name="middleName"]')!.text)
          .trim();
  var matriculationNumber = _cleanString(
          document.querySelector('td[name="matriculationNumber"]')!.text)
      .trim();
  return "$firstName $lastName ($matriculationNumber)";
}

String _cleanString(String input) {
  return input.replaceAll("\t", "").replaceAll("\n", "");
}
