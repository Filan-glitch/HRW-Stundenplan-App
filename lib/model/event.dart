import 'mode.dart';
import 'time.dart';
import 'weekday.dart';

class Event implements Comparable<Event> {
  String get eventID => "$abbreviation$weekFrom";
  String title;
  String abbreviation;
  Time start;
  Time end;
  String room;
  Weekday day;
  String weekFrom;

  Mode get mode {
    if (day.value == DateTime.now().weekday - 1) {
      Time now = Time(DateTime.now().hour, DateTime.now().minute);
      if (start.compareTo(now) <= 0 && end.compareTo(now) >= 0) {
        return Mode.active;
      } else if (end.compareTo(now) <= 0) {
        return Mode.done;
      } else {
        return Mode.normal;
      }
    } else {
      return Mode.normal;
    }
  }

  Event({
    this.title = "",
    this.abbreviation = "",
    this.start = const Time(0, 0),
    this.end = const Time(0, 0),
    this.room = "",
    this.day = Weekday.monday,
    this.weekFrom = "",
  });

  Event.fromDB(Map<String, dynamic> data)
      : title = data["Title"] ?? "",
        abbreviation = data["Abbreviation"] ?? "",
        room = data["Room"] ?? "",
        day = Weekday.getByValue(int.parse(data["Weekday"] ?? "0")),
        weekFrom = data["WeekFrom"] ?? "",
        start = Time(
          int.parse(data["Start"]?.toString().split(":")[0] ?? "0"),
          int.parse(data["Start"]?.toString().split(":")[1] ?? "0"),
        ),
        end = Time(
          int.parse(data["End"]?.toString().split(":")[1] ?? "0"),
          int.parse(data["End"]?.toString().split(":")[0] ?? "0"),
        );

  Map<String, dynamic> toDB() {
    return {
      "EventID": eventID,
      "Title": title,
      "Abbreviation": abbreviation,
      "Room": room,
      "Weekday": day.value.toString(),
      "Start": "${start.hour}:${start.minute}",
      "End": "${end.hour}:${end.minute}",
      "WeekFrom": weekFrom,
    };
  }

  @override
  int compareTo(Event other) {
    return start.compareTo(other.start);
  }
}
