import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

import '../model/event.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import 'storage.dart';

Future<void> loadFourWeekInterval({DateTime? start}) {
  start ??= DateTime.now();

  start = start.subtract(Duration(days: start.weekday - 1));

  return Future.wait([
    fetchData(start),
    fetchData(start.add(const Duration(days: 7))),
    fetchData(start.add(const Duration(days: 14))),
    fetchData(start.add(const Duration(days: 21))),
  ]).then((_) {
    writeDataToStorage();
  });
}

Future<void> fetchData(DateTime monday) async {
  if (store.state.args == null || store.state.cnsc == null) return;

  store.dispatch(Action(ActionTypes.startTask));
  dom.Document body = await _fetchScheduleHTML(monday);
  List<Event> events = await _parse(body);

  DateFormat formatter = DateFormat('dd/MM/yyyy');
  store.dispatch(Action(ActionTypes.setEvents, payload: {
    "date": formatter.format(monday),
    "events": events,
  }));

  store.dispatch(Action(ActionTypes.stopTask));
}

Future<List<Event>> _parse(dom.Document document) async {
  List<Event> events = [];
  if (!document.outerHtml.contains("Stundenplan")) {
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

/*Future<List<Event>> _parseRegistrationTableOLD(
    String cnsc, dom.Document document) async {
  List<Event> result = [];

  for (dom.Element row in document
      .querySelectorAll("table.tb750")[1]
      .querySelectorAll("td.dl-inner")) {
    // parse title
    String? title = row.children.isNotEmpty
        ? row.children[0].text.trim().substring(9)
        : null;

    // parse start & end time
    String? timeString = row.children.length > 2 ? row.children[2].text : null;
    Time? startTime, endTime;

    if (timeString != null) {
      List<RegExpMatch> times =
          RegExp(r'\[\d{2}:\d{2}\]').allMatches(timeString).toList();

      if (times.length >= 2) {
        String? start = times[0].group(0)?.replaceAll(RegExp(r'\[|\]'), "");
        String? end = times[1].group(0)?.replaceAll(RegExp(r'\[|\]'), "");

        startTime = Time(
          int.parse(start?.toString().split(":")[0] ?? "0"),
          int.parse(start?.toString().split(":")[1] ?? "0"),
        );

        endTime = Time(
          int.parse(end?.toString().split(":")[0] ?? "0"),
          int.parse(end?.toString().split(":")[1] ?? "0"),
        );
      }
    }

    // parse room
    String? detailsURL = row.children[0].querySelector("a")?.attributes["href"];
    String? room;
    if (detailsURL != null) {
      dom.Document detailsDocument = await _fetchDetailsHTML(detailsURL, cnsc);
      room = detailsDocument
          .querySelector("span[name=appointmentRooms]")
          ?.text
          .trim()
          .replaceAll(RegExp(r'\(\d+\)'), "")
          .trim();
    }

    // parse weekday
    int weekday = 0;
    if (row.children[2].text.contains("Mo,")) {
      weekday = 0;
    } else if (row.children[2].text.contains("Di,")) {
      weekday = 1;
    } else if (row.children[2].text.contains("Mi,")) {
      weekday = 2;
    } else if (row.children[2].text.contains("Do,")) {
      weekday = 3;
    } else if (row.children[2].text.contains("Fr,")) {
      weekday = 4;
    }

    Event event = Event(
      title: title ?? "",
      start: startTime ?? const Time(0, 0),
      end: endTime ?? const Time(0, 0),
      day: Weekday.getByValue(weekday),
      room: room ?? "",
    );

    result.add(event);
  }

  return result;
}*/

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

/*Future<dom.Document> _fetchRegistrationHTML(String cnsc, String args) async {
  http.Response registrations = await http.get(
      Uri.parse(
        "https://campusnet.hs-ruhrwest.de/scripts/mgrqispi.dll?APPNAME=CampusNet&PRGNAME=MYREGISTRATIONS&ARGUMENTS=$args",
      ),
      headers: {"Cookie": "cnsc=$cnsc"});

  return html.parse(
    utf8.decode(registrations.bodyBytes),
  );
}

Future<dom.Document> _fetchDetailsHTML(String detailsURL, String cnsc) async {
  http.Response details = await http.get(
    Uri.parse('https://campusnet.hs-ruhrwest.de/$detailsURL'),
    headers: {"Cookie": "cnsc=$cnsc"},
  );
  return html.parse(
    utf8.decode(details.bodyBytes),
  );
}*/
