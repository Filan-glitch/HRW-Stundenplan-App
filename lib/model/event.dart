import 'time.dart';

class Event implements Comparable<Event> {
  late String title;
  late String abbreviation;
  late Time start;
  late Time end;
  late String room;
  late Weekday day;

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
  });

  Event.fromAPI(Map<String, dynamic> data) {
    title = data["title"] ?? "";
    abbreviation = data["abbreviation"] ?? "";
    room = data["room"] ?? "";
    day = Weekday.getByValue(data["weekday"] ?? 0);

    start = Time(
      int.parse(data["start"]?.toString().split(":")[0] ?? "0"),
      int.parse(data["start"]?.toString().split(":")[1] ?? "0"),
    );

    end = Time(
      int.parse(data["end"]?.toString().split(":")[0] ?? "0"),
      int.parse(data["end"]?.toString().split(":")[1] ?? "0"),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "title": title,
      "abbreviation": abbreviation,
      "room": room,
      "weekday": day.value,
      "start": "${start.hour}:${start.minute}",
      "end": "${end.hour}:${end.minute}",
    };
  }

  @override
  int compareTo(Event other) {
    return start.compareTo(other.start);
  }
}

enum Weekday {
  monday(0),
  tuesday(1),
  wednesday(2),
  thursday(3),
  friday(4);

  const Weekday(this.value);
  final int value;
  String get text {
    switch (value) {
      case 0:
        return "Montag";
      case 1:
        return "Dienstag";
      case 2:
        return "Mittwoch";
      case 3:
        return "Donnerstag";
      case 4:
        return "Freitag";
      default:
        return "";
    }
  }

  static Weekday getByValue(int value) {
    return Weekday.values.firstWhere(
      (x) => x.value == value,
      orElse: () => Weekday.monday,
    );
  }
}

enum Mode { normal, active, done }
