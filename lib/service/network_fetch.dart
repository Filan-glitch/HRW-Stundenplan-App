import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';

import '../model/event.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import 'storage.dart';

Future<void> loadWeekInterval({DateTime? start, int weeks = 6}) {
  start ??= DateTime.now();

  start = start.subtract(Duration(days: start.weekday - 1));

  List<Future<void>> tasks = [
    for (int i = 0; i < weeks; i++)
      fetchData(
        start.add(
          Duration(days: i * 7),
        ),
      ),
  ];

  return Future.wait(tasks).then((_) {
    writeDataToStorage();
  });
}

Future<void> fetchData(DateTime monday) async {
  DateFormat formatter = DateFormat('dd/MM/yyyy');
  try {
    if (store.state.args == null || store.state.cnsc == null) return;

    store.dispatch(Action(ActionTypes.startTask));
    dom.Document body = await _fetchScheduleHTML(monday);
    List<Event> events = await _parse(body);

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
  } on Error catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    store.dispatch(Action(ActionTypes.stopTask));
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
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

Future<List<Event>> _parse(dom.Document document) async {
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

    String room = details
        .replaceAll(RegExp(r'(\d{2}):(\d{2}) - (\d{2}):(\d{2})'), "")
        .trim();

    String? title = element.querySelector("a")?.attributes["title"];

    if (title == null) continue;

    String? weekday = element.attributes["abbr"] ?? "Montag";

    Map<String, dynamic> event = {};
    event["title"] = title.trim();
    event["room"] = room.replaceAll(RegExp(r'\(\d+\)'), "").trim();

    event["start"] = "${timePeriod[0].group(1)}:${timePeriod[0].group(2)}";
    event["end"] = "${timePeriod[0].group(3)}:${timePeriod[0].group(4)}";

    if (weekday.contains("Montag")) {
      event["weekday"] = 0;
    } else if (weekday.contains("Dienstag")) {
      event["weekday"] = 1;
    } else if (weekday.contains("Mittwoch")) {
      event["weekday"] = 2;
    } else if (weekday.contains("Donnerstag")) {
      event["weekday"] = 3;
    } else if (weekday.contains("Freitag")) {
      event["weekday"] = 4;
    }

    events.add(Event.fromAPI(event));
  }

  return events;
}

Future<dom.Document> _fetchScheduleHTML(
  DateTime monday,
) async {
  String args = store.state.args!;
  args = "${args.split(",")[0]},${args.split(",")[1]}";
  http.Response registrations = await http.get(
      Uri.parse(
        "https://campusnet.hs-ruhrwest.de/scripts/mgrqispi.dll?APPNAME=CampusNet&PRGNAME=SCHEDULER&ARGUMENTS=$args,-A${monday.day.toString().padLeft(2, "0")}/${monday.month.toString().padLeft(2, "0")}/${monday.year},-A,-N1,-N0,-N0",
      ),
      headers: {"Cookie": "cnsc=${store.state.cnsc}"});

  return html.parse(utf8.decode(registrations.bodyBytes));
}
