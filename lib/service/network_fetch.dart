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
  String args = store.state.args!;
  args = args.split(",")[0];
  http.Response registrations = await http.get(
      Uri.parse(
        "$BASE_URL?APPNAME=CampusNet&PRGNAME=STUDENT_RESULT&ARGUMENTS=$args,-N000407,-N0,-N000000000000000,-N000000000000000,-N000000000000000,-N0,-N000000000000000",
      ),
      headers: {"Cookie": "cnsc=${store.state.cnsc}"});

  var temp = (utf8.decode(registrations.bodyBytes));
  temp = temp.replaceAll("\t", "");
  temp = temp.replaceAll("\n", "");
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
      int.parse(timePeriod[0].group(1) ?? "0"),
      int.parse(timePeriod[0].group(2) ?? "0"),
    );
    Time end = Time(
      int.parse(timePeriod[0].group(3) ?? "0"),
      int.parse(timePeriod[0].group(4) ?? "0"),
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
      identifier: data[0].text,
      title: data[1].querySelector("a")?.text ??
          data[1].text.replaceAll("\n", "").trim(),
      creditsAll: int.parse(
        data[3].text == "" ? "0" : data[3].text.split(",")[0],
      ),
      creditsCharged: int.parse(
        data[4].text == "" ? "0" : data[4].text.split(",")[0],
      ),
      grade: double.tryParse(
            data[5].text == "" ? "0" : data[5].text.replaceAll(",", "."),
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
    return double.parse(data[1].text.trimLeft().replaceAll(",", "."));
  } on FormatException {
    return 0.0;
  }
}
